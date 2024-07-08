//
//  MockStoksAPI.swift
//  stockgrid
//
//  Created by Le Bon B' Bauma on 15/03/2023.
//

import Foundation
import StocksAPI

#if DEBUG

struct MockStocksAPI: StockAPI {
    
    var stubbedSearchTickersCallback: (() async throws -> [Ticker])!
    func searchTickers(query: String, isEquityTypeOnly: Bool) async throws -> [Ticker] {
        try await stubbedSearchTickersCallback()
    }
    
    var stubbedFetchQuotesCallback: (() async throws -> [Quote])!
    func fetchQuotes(symbols: String) async throws -> [Quote] {
        try await stubbedFetchQuotesCallback()
    }
    
    var stubFetchChartDataCallback: ((ChartRange) async throws -> ChartData?)! = { $0.stubs }
    
    func fetchChartData(symbol: String, range: ChartRange) async throws -> ChartData? {
        try await stubFetchChartDataCallback(range)
    }
    
}

#endif
