

import SwiftUI
import StocksAPI

struct SearchView: View {
    @EnvironmentObject var appVM: AppViewModel
    @StateObject var quotesVm = QuotesViewModel()
    @ObservedObject var searchVM: SearchViewModel
    
    var body: some View {
        List(searchVM.tickers) { ticker in
            
            TickerListRowView(
                data: .init(
                    symbol: ticker.symbol,
                    name: ticker.shortname,
                    price: quotesVm.priceForTicker(ticker),
                    type: .search(
                        isSaved: appVM.isAddedToMyTickers(ticker: ticker),
                        onButtonTapped: { appVM.toggleTicker(ticker) }
                    )
                )
            )
            .contentShape(Rectangle())
            .onTapGesture {
                appVM.selectedTicker = ticker
            }
        }
        .listStyle(.plain)
        .refreshable{ await quotesVm.fetchQuotes(tickers: searchVM.tickers) }
        .task(id: searchVM.tickers) { await quotesVm.fetchQuotes(tickers: searchVM.tickers)}
        .overlay { listSearchOverlay }
    }
    
    @ViewBuilder
    private var listSearchOverlay: some View {
        switch searchVM.phase {
        case .failure(let error) :
            ErrorStateView(error: error.localizedDescription) {
                Task { await searchVM.searchTickers()}
            }
        case .empty:
            EmptyStateView(text: searchVM.emptyListText)
        case .fetching:
            LoadingStateView()
        default: EmptyView()
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    
    @StateObject static var stubbedSearchVM: SearchViewModel = {
        var mock = MockStocksAPI()
        mock.stubbedSearchTickersCallback = {  Ticker.stubs }
        return SearchViewModel(query: "Tesla", stockAPI: mock)
        
    }()
    
    @StateObject static var emptySearchVM : SearchViewModel = {
        var mock = MockStocksAPI()
        mock.stubbedSearchTickersCallback = { [] }
        return SearchViewModel(query: "Theranos", stockAPI: mock)
    }()
    
    @StateObject static var loadingSearchVM: SearchViewModel = {
        var mock = MockStocksAPI()
        mock.stubbedSearchTickersCallback = {
            await withCheckedContinuation { _ in }
        }
        return SearchViewModel(query: "Tesla", stockAPI: mock)
    }()
    
    @StateObject static var errorSearchVM: SearchViewModel = {
        var mock = MockStocksAPI()
        mock.stubbedSearchTickersCallback = { throw  NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "An Error has occured"]) }
        return SearchViewModel(query: "Tesla", stockAPI: mock)
    }()
    
    @StateObject static var appVM: AppViewModel = {
        var mock = MoockTickerListRepository()
        mock.stubbedLoad = { Array(Ticker.stubs.prefix(upTo: 2)) }
        return AppViewModel(repository: mock)
    }()
    
    static var quotesVM: QuotesViewModel = {
        var mock = MockStocksAPI()
        mock.stubbedFetchQuotesCallback = { Quote.stubs }
        return QuotesViewModel(stockAPI: mock)
    }()
    
    static var previews: some View {
        
        Group {
            NavigationStack {
                SearchView(quotesVm: quotesVM, searchVM: stubbedSearchVM)
            }
            .searchable(text: $stubbedSearchVM.query)
            .previewDisplayName("Results")
            
            NavigationStack {
                SearchView(quotesVm: quotesVM, searchVM: emptySearchVM)
            }
            .searchable(text: $emptySearchVM.query)
            .previewDisplayName("Empty Results")
            
            NavigationStack {
                SearchView(quotesVm: quotesVM, searchVM: loadingSearchVM)
            }
            .searchable(text: $loadingSearchVM.query)
            .previewDisplayName("Loading State")
            
            NavigationStack {
                SearchView(quotesVm: quotesVM, searchVM: errorSearchVM)
            }
            .searchable(text: $errorSearchVM.query)
            .previewDisplayName("Error State")
            
        }.environmentObject(appVM)
    }
}
