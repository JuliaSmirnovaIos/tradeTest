//
//  QuoteItem.swift
//  TradeNetTest
//
//  Created by Julia Smirnova on 17.12.2022.
//

import Foundation

struct QuoteItem {
    let ticker: String?
    let name: String?
    let closeChange: Double?
    let lastTradeChange: Double?
    let exchangeName: String?
    let lastTradePrice: Double?
    let lastPriceMinStep: Double?
    
    init(
        ticker: String?,
        longName: String?,
        closeChange: Double?,
        openChange: Double?,
        exchangeName: String?,
        lastTradePrice: Double?,
        lastPriceMinStep: Double?
    ) {
        self.ticker = ticker
        self.name = longName
        self.closeChange = closeChange
        self.lastTradeChange = openChange
        self.exchangeName = exchangeName
        self.lastTradePrice = lastTradePrice
        self.lastPriceMinStep = lastPriceMinStep
    }
    
    init(networkItem: QuoteItemNetwork) {
        self.init(
            ticker: networkItem.c,
            longName: networkItem.name,
            closeChange: networkItem.pcp,
            openChange: networkItem.chg,
            exchangeName: networkItem.ltr,
            lastTradePrice: networkItem.ltp,
            lastPriceMinStep: networkItem.min_step
        )
    }
    
    func update(with new: QuoteItem) -> QuoteItem {
        QuoteItem(
            ticker: new.ticker ?? ticker,
            longName: new.name ?? name,
            closeChange: new.closeChange ?? closeChange,
            openChange: new.lastTradeChange ?? lastTradeChange,
            exchangeName: new.exchangeName ?? exchangeName,
            lastTradePrice: new.lastTradePrice ?? lastTradePrice,
            lastPriceMinStep: new.lastPriceMinStep ?? lastPriceMinStep
        )
    }
}

extension QuoteItem {
    var description: String {
        String(format: "%@ | %@", exchangeName ?? "", name ?? "")
    }
    
    var change: String {
        closeChange?.percent ?? ""
    }
    
    var lastTradeInfo: String {
        String(format: "%g ( %@ )", roundedLastPrice ?? 0, roundedLastTradeChange?.percent ?? "")
    }
    
    private var roundedLastPrice: Double? {
        guard let lastPriceMinStep = lastPriceMinStep else { return lastTradePrice }
        return lastTradePrice?.round(nearest: lastPriceMinStep)
    }
    
    private var roundedLastTradeChange: Double? {
        guard let lastPriceMinStep = lastPriceMinStep else { return lastTradeChange }
        return lastTradeChange?.round(nearest: lastPriceMinStep)
    }
}
