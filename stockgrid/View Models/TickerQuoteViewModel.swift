

import Foundation
import SwiftUI
import StocksAPI


@MainActor
class TickerQuoteViewModel: ObservableObject {
    
    @Published var phase = FetchPase<Quote>.initial
    var quote: Quote? { phase.value }
    var error: Error? { phase.error }
    
    let ticker: Ticker
    let stockAPI: StockAPI
    
    init(ticker: Ticker, stockAPI: StockAPI = StocksAPI()) {
        self.ticker = ticker
        self.stockAPI = stockAPI
    }
    
    func fetchQuote() async {
        phase = .fetching
        
        do {
            let response = try await stockAPI.fetchQuotes(symbols: ticker.symbol)
            if let quote = response.first {
                phase = .success(quote)
            } else {
                phase = .empty
            }
            
        } catch  {
            print(error.localizedDescription)
            phase = .failure(error)
        }
    }
}
