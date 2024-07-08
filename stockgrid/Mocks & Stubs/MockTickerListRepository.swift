//
//  MockTickerListRepository.swift
//  stockgrid
//
//  Created by Le Bon B' Bauma on 16/03/2023.
//

import Foundation
import StocksAPI

#if DEBUG

struct MoockTickerListRepository: TickerListRepository {
    
    var stubbedLoad: (() async throws -> [Ticker])!
    
    func load() async throws -> [Ticker] {
        try await stubbedLoad()
    }
    
    func save(_ current: [Ticker]) async throws {}
    
    
}

#endif
