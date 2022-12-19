//
//  TickersListPresenter.swift
//  TradeNetTest
//
//  Created by Julia Smirnova on 17.12.2022.
//

import Foundation
import Combine

class TickersListPresenter {
    
    lazy var allQuotes = ["SP500.IDX", "AAPL.US", "RSTI", "GAZP", "MRKZ", "RUAL", "HYDR", "MRKS", "SBER", "FEES", "TGKA", "VTBR", "ANH.US", "VICL.US", "BURG.US", "NBL.US", "YETI.US", "WSFS.US", "NIO.US", "DXC.US", "MIC.US", "HSBC.US", "EXPN.EU", "GSK.EU", "SHP.EU", "MAN.EU", "DB1.EU", "MUV2.EU", "TATE.EU", "KGF.EU", "MGGT.EU", "SGGD.EU"] 
        .map{ QuoteItem(ticker: $0, longName: nil, closeChange: nil, openChange: nil, exchangeName: nil, lastTradePrice: nil, lastPriceMinStep: nil) }
    
    private let getQuotesUseCase: GetQuotesUseCase
    var cancellables = Set<AnyCancellable>()
    
    let itemsSubject = PassthroughSubject<[QuoteItem], Error>()
    private var items = [QuoteItem]()
    
    let updatedItem = PassthroughSubject<QuoteItemWithIndex, Error>()
    
    init(getQuotesUseCase: GetQuotesUseCase) {
        self.getQuotesUseCase = getQuotesUseCase
    }
    
    func getData(for indexes: Array<Int>) {
        let quotes = items.enumerated()
            .filter { indexes.contains($0.offset) }
            .map(\.element)
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.getQuotes(quotes: quotes)
        }
    }
    
    func getData() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.getQuotes()
        }
    }
    
    private func getQuotes() {
        getQuotes(quotes: allQuotes)
    }
    
    private func getQuotes(quotes: [QuoteItem]) {
       getQuotesUseCase.getQuotes(quotes: quotes.compactMap(\.ticker))
            .sink(receiveCompletion: { error in
                print(error)
            }, receiveValue: { [weak self] event in
                switch event {
                case .updated(let updated):
                    guard let itemAndIndex = self?.items.enumerated().first(where: { index, item in
                        item.ticker == updated.ticker
                    }) else { return }
                    let updatedItem = itemAndIndex.element.update(with: updated)
                    
                    self?.items.update(with: updatedItem, index: itemAndIndex.offset)
                    self?.updatedItem.send(QuoteItemWithIndex(item: updatedItem, index: itemAndIndex.offset))
                case .new(let item):
                    self?.items.update(with: item)
                    self?.itemsSubject.send(self?.items ?? [])
                }
            })
            .store(in: &cancellables)
    }
}

struct QuoteItemWithIndex {
    let item: QuoteItem
    let index: Int
}


private extension Array where Element == QuoteItem {
    mutating func update(with new: QuoteItem, index: Int) {
        self[index] = new
    }
    
    mutating func update(with new: QuoteItem) {
        if let item = enumerated()
            .first(where: { $0.element.ticker == new.ticker }) {
                self[item.offset] = new
            return 
        }
        append(new)
    }
}
