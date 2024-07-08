

import Foundation
import StocksAPI

extension Quote {
    
    var isTrading: Bool {
        guard let marketState, marketState == "REGULAR" else  {
            return false
        }
        return false
    }
    
    var regularPriceText: String? {
        Utils.format(value: regularMarketPrice)
    }
    
    var regularDiffText: String? {
        guard let text = Utils.format(value: regularMarketChange) else { return nil }
        return text.hasPrefix("-") ? text : "+\(text)"
    }
    
    var postPriceText: String? {
        Utils.format(value: postMarketPrice)
    }
    
    var postPriceDiffText: String? {
        guard let text = Utils.format(value: postMarketChange) else { return nil }
        return text.hasPrefix("-") ? text : "+\(text)"
    }
    
    var highText: String {
        Utils.format(value: regularMarketDayHigh) ?? "-"
    }
    
    var lowText: String {
        Utils.format(value: regularMarketDayLow) ?? "-"
    }
    
    var openText: String {
        Utils.format(value: regularMarketOpen) ?? "-"
    }
    
    var volText: String {
        regularMarketVolume?.formatUsingAbbrevation() ?? "-"
    }
    
    var peText: String {
        Utils.format(value: trailingPE) ?? "-"
    }
    var marketCapitolText: String {
        marketCap?.formatUsingAbbrevation() ?? "-"
    }
    
    var fiftyTwoWeekLowText: String {
        Utils.format(value: fiftyTwoWeekLow) ?? "-"
    }
    
    var fiftyTwoWeekHightText: String {
        Utils.format(value: fiftyTwoWeekHigh) ?? "-"
    }
    
    var averageVolumeText: String {
        averageDailyVolume3Month?.formatUsingAbbrevation() ?? "-"
    }
    
    var yieldText: String {
        Utils.format(value: trailingAnnualDividendYield) ?? "-"
    }
    
    var betaText: String {"-"}
    
    
    var epsText: String {
        Utils.format(value: epsTrailingTwelveMonths) ?? "-"
    }
    
    
    
    var columnItems: [QuoteDetailRowColumnItem] {
        [
            QuoteDetailRowColumnItem(rows: [
                QuoteDetailRowColumnItem.RowItem(title: "Open", value: openText),
                QuoteDetailRowColumnItem.RowItem(title: "High", value: highText),
                QuoteDetailRowColumnItem.RowItem(title: "Low", value: lowText)
            ]), QuoteDetailRowColumnItem(rows: [
                QuoteDetailRowColumnItem.RowItem(title: "Vol", value: volText),
                QuoteDetailRowColumnItem.RowItem(title: "P/E", value: peText),
                QuoteDetailRowColumnItem.RowItem(title: "Mkt Cap", value: marketCapitolText)
            ]), QuoteDetailRowColumnItem(rows: [
                QuoteDetailRowColumnItem.RowItem(title: "52W H", value: fiftyTwoWeekHightText),
                QuoteDetailRowColumnItem.RowItem(title: "52W L", value: fiftyTwoWeekLowText),
                QuoteDetailRowColumnItem.RowItem(title: "Avg Vol", value: averageVolumeText)
            ]), QuoteDetailRowColumnItem(rows: [
                QuoteDetailRowColumnItem.RowItem(title: "Yield", value: yieldText),
                QuoteDetailRowColumnItem.RowItem(title: "Beta", value: betaText),
                QuoteDetailRowColumnItem.RowItem(title: "EPS", value: epsText)
            ])
        ]
    }
}
