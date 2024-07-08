

import Foundation
import StocksAPI

protocol StockAPI {
    func searchTickers(query: String, isEquityTypeOnly: Bool) async throws -> [Ticker]
    func fetchQuotes(symbols: String) async throws -> [Quote]
    func fetchChartData (symbol: String, range: ChartRange) async throws -> ChartData?
    
}


extension StocksAPI: StockAPI {}
