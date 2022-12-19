//
//  QuoteItemNetwork.swift
//  TradeNetTest
//
//  Created by Julia Smirnova on 17.12.2022.
//

import Foundation

class QuoteItemNetwork: Decodable {
    let c: String?
    let name: String?
    let ltr: String?
    let pcp: Double?
    let chg: Double?
    let ltp: Double?
    let min_step: Double?
}

class QuoteMessageNetwork: Decodable {
    let q: String?
    let item: QuoteItemNetwork?
}
