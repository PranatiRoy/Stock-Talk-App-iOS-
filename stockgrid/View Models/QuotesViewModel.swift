

import Foundation
import SwiftUI
import StocksAPI

@MainActor
class QuotesViewModel: ObservableObject {
    
    @Published var quotesDict: [String: Quote] = [:]
    let stockAPI: StockAPI
    
    init(stockAPI: StockAPI = StocksAPI()) {
        self.stockAPI = stockAPI
    }
    
    func fetchQuotes(tickers: [Ticker]) async {
        guard !tickers.isEmpty else { return}
        
        do {
            let symbols = tickers.map { $0.symbol }.joined(separator: ",")
            let quotes = try await stockAPI.fetchQuotes(symbols: symbols)
            var dict = [String: Quote]()
            quotes.forEach { dict[$0.symbol]  = $0 }
            self.quotesDict = dict
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func priceForTicker(_ ticker: Ticker) ->  PriceChange? {
        guard let quote = quotesDict[ticker.symbol],
              let price = quote.regularPriceText,
              let change = quote.regularDiffText
                
        else { return nil }
        return (price, change)
    }
}

