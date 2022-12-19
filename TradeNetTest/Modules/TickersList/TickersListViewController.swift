//
//  TickersListViewController.swift
//  TradeNetTest
//
//  Created by Julia Smirnova on 15.12.2022.
//

import UIKit
import Combine
import SnapKit

class TickersListViewController: UIViewController {
    
    var presenter: TickersListPresenter!
    
    private lazy var tableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.register(TickersListTableViewCell.self, forCellReuseIdentifier: TickersListTableViewCell.cellId)
        table.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        return table
    }()
    
    private var items = [QuoteItem]()
    
    private var cancellables = Set<AnyCancellable>()
    private var visibleIndexes = Set<Int>()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Quotes"
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(view.snp.edges)
            make.center.equalTo(view)
        }
        presenter.itemsSubject
            .sink { error in
                print(error)
            } receiveValue: { [weak self] items in
                DispatchQueue.main.async {
                    self?.items = items
                    self?.tableView.reloadData()
                }
            }
            .store(in: &cancellables)
        
        presenter.updatedItem
            .sink { error in
                print(error)
            } receiveValue: { [weak self] item in
                DispatchQueue.main.async {
                    guard let cell = self?.tableView.cellForRow(at: IndexPath(row: item.index, section: 0)) as? TickersListTableViewCell else { return }
                    cell.update(with: item.item)
                }
            }
            .store(in: &cancellables)
        
        presenter.getData()
    }
}

extension TickersListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TickersListTableViewCell.cellId) as? TickersListTableViewCell
        cell?.configure(with: items[indexPath.row])
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        presenter.getData(for: tableView.indexPathsForVisibleRows?.map(\.row) ?? [])
    }
}

class TickersListTableViewCell: UITableViewCell {
    
    static let cellId = "TickersListTableViewCell"
    
    private lazy var tickerLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var fullNameLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = .gray
        return label
    }()
    
    private lazy var changeValue = {
        let label = PaddingLabel()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        return label
    }()
    
    private lazy var valueLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(tickerLabel)
        tickerLabel.snp.makeConstraints { make in
            make.left.equalTo(contentView.snp.left).offset(8)
            make.top.equalTo(contentView.snp.top).offset(8)
        }
        
        contentView.addSubview(fullNameLabel)
        fullNameLabel.snp.makeConstraints { make in
            make.left.equalTo(contentView.snp.left).offset(8)
            make.top.equalTo(tickerLabel.snp.bottom).offset(8)
            make.bottom.equalTo(contentView.snp.bottom).inset(8)
        }
        
        contentView.addSubview(changeValue)
        changeValue.snp.makeConstraints { make in
            make.right.equalTo(contentView.snp.right).inset(8)
            make.top.equalTo(contentView.snp.top).offset(8)
            make.height.equalTo(24)
        }
        
        contentView.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.right.equalTo(contentView.snp.right).inset(8)
            make.bottom.equalTo(contentView.snp.bottom).inset(8)
            make.top.equalTo(changeValue.snp.bottom).offset(8)
        }
        
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        changeValue.backgroundColor = .clear
    }
    
    func configure(with item: QuoteItem) {
        tickerLabel.text = item.ticker
        fullNameLabel.text = item.description
        changeValue.text = item.change
        changeValue.textColor = item.lastTradeChange ?? 0 > 0 ? .green : .red
        valueLabel.text = item.lastTradeInfo
    }
    
    func update(with item: QuoteItem) {
        changeValue.text = item.change
        changeValue.backgroundColor = item.lastTradeChange ?? 0 > 0 ? .green : .red
        changeValue.textColor = .white
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.changeValue.backgroundColor = .clear
            self?.changeValue.textColor = item.lastTradeChange ?? 0 > 0 ? .green : .red
        }
        valueLabel.text = item.lastTradeInfo
    }
}
