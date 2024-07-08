//
//  Stubs.swift
//  stockgrid
//
//  Created by Le Bon B' Bauma on 07/03/2023.
//

import Foundation
import StocksAPI


#if DEBUG
extension Ticker {
    
    static var stubs: [Ticker] {
        [
            Ticker(symbol: "AMD", shortname: "Advanced Micro Device", exchDisp: "NASDAQ"),
            Ticker(symbol: "AAPL", shortname: "Apple Inc."),
            Ticker(symbol: "BA", shortname: "The Boeing Company"),
            Ticker(symbol: "TSLA", shortname: "Tesla"),
            Ticker(symbol: "NVDA", shortname: "Nvidia Corp")
        ]
    }
    
    static var stub: Ticker {
        stubs[0]
    }
}

extension Quote {
    
    
    static var stubs: [Quote] {
        [
            Quote(symbol: "AMD", regularMarketPrice: 83.32, regularMarketChange: -0.65),
            Quote(symbol: "AAPL", regularMarketPrice: 152.27, regularMarketChange: 3.78),
            Quote(symbol: "BA", regularMarketPrice: 205.14, regularMarketChange: -1.94),
            Quote(symbol: "TSLA", regularMarketPrice: 176.29, regularMarketChange: 2.85),
            Quote(symbol: "NVDA", regularMarketPrice: 231.27, regularMarketChange: 1.50)
        ]
    }
    
    static var stubsDict: [String: Quote] {
        var dict = [String: Quote]()
        stubs.forEach { dict[$0.symbol] = $0}
        return dict 
        
    }
    
    static func stub(istrading: Bool) -> Quote {
        Quote(symbol: "AMD",
              currency: "USD",
              marketState: istrading ? "REGULAR" : "CLOSED",
              
              regularMarketPrice: 97.84,
              regularMarketChange: 1.24,
              postMarketPrice: 97.80,
              postMarketChange: -0.04,
              regularMarketOpen: 96.66,
              regularMarketDayHigh: 98.75,
              regularMarketDayLow: 95.94,
              regularMarketVolume: 91_220_000.0,
              trailingPE: 105.20,
              marketCap: 157_007_000_000.0,
              fiftyTwoWeekLow: 54.57,
              fiftyTwoWeekHigh: 125.67,
              averageDailyVolume3Month: 58_030_000.0,
              epsTrailingTwelveMonths: 0.93)
    }
}

#endif
