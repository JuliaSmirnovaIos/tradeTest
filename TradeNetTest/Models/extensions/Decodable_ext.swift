//
//  Decodable_ext.swift
//  TradeNetTest
//
//  Created by Julia Smirnova on 19.12.2022.
//

import Foundation

extension Decodable {
    static func mapFrom(json: String) -> Self? {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            let result = try decoder.decode([FailableDecodable<Self>].self, from: Data(json.utf8)).compactMap {$0.base }
                .first
            return result
        } catch let error {
            print(error)
            return nil
        }
    }
}
