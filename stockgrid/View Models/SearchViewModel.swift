

import Combine
import Foundation
import SwiftUI
import StocksAPI


@MainActor
class SearchViewModel: ObservableObject {
    
    
    @Published var query: String = ""
    @Published var phase: FetchPase<[Ticker]> = .initial
    
    
    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var tickers: [Ticker] { phase.value ?? [] }
    var error: Error?  { phase.error }
    var isSearching: Bool  { !trimmedQuery.isEmpty }
    
    var emptyListText: String {
        "Symbols not found for\n\"\(query)\""
    }
    private var cancellables = Set<AnyCancellable>()
    private let stockAPI: StockAPI
    
    init(query: String = "", stockAPI: StockAPI = StocksAPI() ) {
        self.query = query
        self.stockAPI = stockAPI
        
        startObserving()
    }
    
    
    private func startObserving() {
        $query
            .debounce(for: 0.25, scheduler: DispatchQueue.main)
            .sink { _ in
                Task { [weak self] in await self?.searchTickers()}
            }
            .store(in: &cancellables)
    }
    
    func searchTickers() async {
        let searchQuery = trimmedQuery
        guard !searchQuery.isEmpty else { return }
        phase = .fetching
        
        do {
            let tickers = try await stockAPI.searchTickers(query: searchQuery, isEquityTypeOnly: true)
            if searchQuery != trimmedQuery { return }
            if tickers.isEmpty {
                phase = .empty
            }else {
                phase = .success(tickers)
            }
            
        } catch {
            if searchQuery != trimmedQuery { return }
            print(error.localizedDescription)
            phase = .failure(error)
        }
    }
}

