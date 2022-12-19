//
//  GetQuotesUseCase.swift
//  TradeNetTest
//
//  Created by Julia Smirnova on 17.12.2022.
//

import Foundation
import Combine

class GetQuotesUseCase {
    enum Event {
        case new(QuoteItem)
        case updated(QuoteItem)
        
        static func from(item: QuoteItem) -> Event {
            if item.exchangeName != nil {
                return .new(item)
            }
            return .updated(item)
        }
    }
    
    private let networkService: QuotesService
    
    init(networkService: QuotesService) {
        self.networkService = networkService
    }
    
    func getQuotes(quotes: [String]) -> AnyPublisher<Event, Error> {
        let result = PassthroughSubject<Event, Error>()
        networkService.subscribe(toQuotes: quotes) { [weak self] message in
            guard let quoteItemNetwork = self?.mapObject(from: message)
            else { return }
            let quoteItem = QuoteItem(networkItem: quoteItemNetwork)
            result.send(Event.from(item: quoteItem))
        } onError: { error in
            result.send(completion: .failure(error))
        }
        return result.eraseToAnyPublisher()
    }
    
    private func mapObject(from message: String) -> QuoteItemNetwork? {
        guard let item = QuoteItemNetwork.mapFrom(json: message)
        else { return nil }
        return item
    }
}

struct FailableDecodable<Base: Decodable>: Decodable {

    let base: Base?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.base = try? container.decode(Base.self)
    }
}
