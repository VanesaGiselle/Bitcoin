//
//  BitcoinViewController.swift
//  Bitcoin
//
//  Created by Vanesa Korbenfeld on 21/06/2023.
//

import UIKit

class BitcoinViewController: UIViewController {
    struct ViewModel {
        let bitcoinPrice: String
        let timezone: String
    }
    
    private var dispatchGroup: DispatchGroup = DispatchGroup()
    private var bitcoinProvider: BitcoinProvider
    private var timezoneProvider: TimezoneProvider
    private var bitcoinPrices: [Int] = []
    private var timezone: String = ""
    
    init(bitcoinProvider: BitcoinProvider, timezoneProvider: TimezoneProvider) {
        self.bitcoinProvider = bitcoinProvider
        self.timezoneProvider = timezoneProvider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var bitcoinLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    private lazy var timezoneLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        getDataFromApi()
    }
    
    func render(viewModel: ViewModel) {
        bitcoinLabel.text = viewModel.bitcoinPrice
        timezoneLabel.text = viewModel.timezone
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(bitcoinLabel)
        view.addSubview(timezoneLabel)
        
        bitcoinLabel.translatesAutoresizingMaskIntoConstraints = false
        timezoneLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bitcoinLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bitcoinLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            timezoneLabel.topAnchor.constraint(equalTo: bitcoinLabel.bottomAnchor, constant:  20),
            timezoneLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func getDataFromApi() {
        getBitcoinPriceFromCoincap()
        getBitcoinPriceFromCoingecko()
        getTimezoneFromApi()
        
        self.dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            let bitcoinAverage = self.bitcoinPrices.reduce(0) { $0 + $1 } / self.bitcoinPrices.count
            let viewModel = ViewModel(bitcoinPrice: String(bitcoinAverage), timezone: self.timezone)
            self.render(viewModel: viewModel)
        }
    }
    
    private func getTimezoneFromApi() {
        dispatchGroup.enter()
        timezoneProvider.getTimezone(completionHandler: { [weak self] (result: Result<Country, ErrorType>) in
            guard let self = self else { return }
            defer { self.dispatchGroup.leave() }
            switch result {
            case .success(let country):
                self.timezone = country.timezone
            case .failure(let error):
                self.handleFailure(error)
            }
        })
    }
    
    private func getBitcoinPriceFromCoincap() {
        dispatchGroup.enter()
        bitcoinProvider.getBitcoinPrice(bitcoinUrl: .coincap, completionHandler: { [weak self] result in
            guard let self = self else { return }
            defer { self.dispatchGroup.leave() }
            switch result {
            case .success(let bitcoin):
                self.bitcoinPrices.append(bitcoin.usd)
            case .failure(let error):
                self.handleFailure(error)
            }
        })
    }
    
    private func getBitcoinPriceFromCoingecko() {
        dispatchGroup.enter()
        bitcoinProvider.getBitcoinPrice(bitcoinUrl: .coingecko, completionHandler: {[weak self] result in
            guard let self = self else { return }
            defer { self.dispatchGroup.leave() }
            switch result {
            case .success(let bitcoin):
                self.bitcoinPrices.append(bitcoin.usd)
            case .failure(let error):
                self.handleFailure(error)
            }
        })
    }
}

