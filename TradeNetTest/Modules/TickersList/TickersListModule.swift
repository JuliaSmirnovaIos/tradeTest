//
//  TickersListModule.swift
//  TradeNetTest
//
//  Created by Julia Smirnova on 19.12.2022.
//

import Foundation
import UIKit

class TickersListModule {
    var viewController: UIViewController {
        let presenter = TickersListPresenter(getQuotesUseCase: GetQuotesUseCase(networkService: QuotesServiceImpl()))
        let viewController = TickersListViewController()
        viewController.presenter = presenter
        return viewController
    }
}
