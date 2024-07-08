

import Foundation
import Charts
import SwiftUI
import StocksAPI

@MainActor
class ChartViewModel: ObservableObject {
    
    @Published var fetchPhase = FetchPase<ChartViewData>.initial
    var chart: ChartViewData? { fetchPhase.value }
    
    let ticker: Ticker
    let apiService: StockAPI
    
    @AppStorage("selectedRange") private var _range = ChartRange.oneDay.rawValue
    
    @Published var selectedRange = ChartRange.oneDay {
        didSet {
            _range = selectedRange.rawValue
        }
    }
    
    @Published var selectedX: (any Plottable)?
    
    var selectedRuleMark: (value: Int, text: String)? {
        
        guard let selectedX = selectedX as? Int,
              let chart
        else { return nil }
 
        return (selectedX, chart.items[selectedX].value.rounderString)
    }
    
    var foregroundMarkColor: Color {
        (selectedX != nil) ? .cyan : (chart?.lineColor ?? .cyan)
    }
    
    init(ticker: Ticker, apiService: StockAPI = StocksAPI()) {
        self.ticker = ticker
        self.apiService = apiService
        self.selectedRange = ChartRange(rawValue: _range) ?? .oneDay
    }
    
    private let selectedValueDateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()
    
    private let dateFormatter = DateFormatter()
    
    var selectedXDateText: String {
        guard let selectedX = selectedX as? Int, let chart else  { return "" }
        if selectedRange == .oneDay || selectedRange == .oneWeek {
            selectedValueDateFormatter.timeStyle = .short
        } else {
            selectedValueDateFormatter.timeStyle = .none
        }
        let item = chart.items[selectedX]
        return selectedValueDateFormatter.string(from: item.timestamp)
    }
    
    var selectedXOpacity: Double {
        selectedX == nil ? 1 : 0
    }
 
    func fetchData() async {
        
        do {
            
            fetchPhase = .fetching
            let rangeType = self.selectedRange
            let chatData = try await apiService.fetchChartData(symbol: ticker.symbol, range: rangeType)
            
            guard rangeType == self.selectedRange else { return }
            if let chatData {
                fetchPhase = .success(transformChartViewData(chatData))
            } else   {
                fetchPhase = .empty
            }
            
        } catch  {
            fetchPhase = .failure(error)
        }
    }
    
    func transformChartViewData(_ data: ChartData)  -> ChartViewData {
        let (xAxisChartData, items) = xAxisChartDataAndItems(data)
        let yAxisChartData = yAxisChartData(data)
        return ChartViewData(
            xAxisData: xAxisChartData,
            yAxisData: yAxisChartData,
            items: items,
            lineColor: getLineColor(data: data),
            previousCloseRuleMarkValue: previousCloseRuleMarkValue(data: data, yAxisData: yAxisChartData)
        )
    }
    
    func xAxisChartDataAndItems(_ data: ChartData) -> (ChartAxisData, [ChartViewItem]) {
        let timezone = TimeZone(secondsFromGMT: data.meta.gmtoffset) ?? .gmt
        dateFormatter.timeZone = timezone
        selectedValueDateFormatter.timeZone = timezone
        dateFormatter.dateFormat = selectedRange.dateFormat
        
        var xAxisDateComponents = Set<DateComponents>()
        if let startTimestamp = data.indicators.first?.timestamp {
            if selectedRange == .oneDay {
                xAxisDateComponents = selectedRange.getDateComponents(startDate: startTimestamp, endDate: data.meta.regularTradingPeriodEndDate, timezone: timezone)
            }
            else if let endTimestamp = data.indicators.last?.timestamp {
                xAxisDateComponents = selectedRange.getDateComponents(startDate: startTimestamp, endDate: endTimestamp, timezone: timezone)
            }
        }
        
        var map = [String: String]()
        var axisEnd: Int
        
        
        var items = [ChartViewItem]()
        
        for (index, value) in data.indicators.enumerated() {
            let dc = value.timestamp.dateComponents(timeZone: timezone, rangeType: selectedRange)
            if xAxisDateComponents.contains(dc) {
                map[String(index)] = dateFormatter.string(from: value.timestamp)
                xAxisDateComponents.remove(dc)
            }
            
            items.append(ChartViewItem(timestamp: value.timestamp, value: value.close))
        }
        axisEnd = items.count - 1
        
        if selectedRange == .oneDay,
           var date = items.last?.timestamp,
            date >= data.meta.regularTradingPeriodStartDate &&
            date < data.meta.regularTradingPeriodEndDate {
            while date < data.meta.regularTradingPeriodEndDate {
                axisEnd += 1
                date = Calendar.current.date(byAdding: .minute, value: 2, to: date)!
                let dc = date.dateComponents(timeZone: timezone, rangeType: selectedRange)
                if xAxisDateComponents.contains(dc) {
                    map[String(axisEnd)] = dateFormatter.string(from: date)
                    xAxisDateComponents.remove(dc)
                }
            }
        }
            
            
        let xAxisData = ChartAxisData(
            axisStart: 0,
            axisEnd: Double(axisEnd),
            strideBy: 1,
            map: map)
        
        return (xAxisData, items)
    }
    
    
    func yAxisChartData(_ data : ChartData) -> ChartAxisData {
        
        let closes = data.indicators.map { $0.close }
        var lowest = closes.min() ?? 0
        var highest = closes.max() ?? 0
        
        if let prevClose = data.meta.previousClose, selectedRange == .oneDay {
            if prevClose < lowest {
                lowest = prevClose
            } else if prevClose > highest{
                highest = prevClose
            }
        }
        
        let diff = highest - lowest
        let numberOfLines: Double = 4
        let shouldCeilIncrement: Bool
        let strideBy: Double
        
        if diff < numberOfLines {
            shouldCeilIncrement = false
            strideBy = 0.01
        } else {
            shouldCeilIncrement = true
            lowest = floor(lowest)
            highest = ceil(highest)
            strideBy = 1.0
        }
        
        let increment = ((highest - lowest) / numberOfLines)
        var map =  [String : String]()
        map[highest.rounderString] = formatYAxisValueLabel(value: highest, shouldCeilIncrement: shouldCeilIncrement)
        
        var current = lowest
        (0..<Int(numberOfLines) - 1).forEach { i in
            current += increment
            map[(shouldCeilIncrement ? ceil(current) : current).rounderString] = formatYAxisValueLabel(value: current, shouldCeilIncrement: shouldCeilIncrement)
        }
     
        return ChartAxisData(
            axisStart: lowest + 0.01 ,
            axisEnd: highest + 0.01,
            strideBy: strideBy,
            map: map
        )
    }
    
    func formatYAxisValueLabel(value: Double,  shouldCeilIncrement: Bool) -> String {
        if shouldCeilIncrement {
            return String(Int(ceil(value)))
        } else {
            return Utils.numberFormatter.string(from: NSNumber(value: value)) ?? value.rounderString
        }
    }
    
    func previousCloseRuleMarkValue(data: ChartData, yAxisData: ChartAxisData) -> Double? {
        
        guard let previousClose = data.meta.previousClose, selectedRange == .oneDay else { return nil }
        return (yAxisData.axisStart <= previousClose && previousClose <= yAxisData.axisEnd) ? previousClose : nil
        
    }
    
    
    func getLineColor(data: ChartData) -> Color {
        
        if let last = data.indicators.last?.close {
            if selectedRange == .oneDay, let prevClose = data.meta.previousClose {
                return last >= prevClose ? .green : .red
            } else if let first = data.indicators.first?.close {
                return last >= first ? .green : .red
            }
        }
        return .blue
    }
}
