//
//  BitcoinViewController.swift
//  Bitcoin
//
//  Created by Vanesa Korbenfeld on 21/06/2023.
//

import UIKit
import Combine

class BitcoinViewController: UIViewController {
    struct ViewModel {
        let bitcoinPrice: String
        let timezone: String
    }
    
    private var bitcoinProvider: BitcoinProvider
    private var timezoneProvider: TimezoneProvider
    private var cancellables: Set<AnyCancellable> = []
    
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
        let bitcoinCoincapPublisher = getBitcoinPriceFromCoincap()
        let bitcoinCoingeckoPublisher = getBitcoinPriceFromCoingecko()
        let timezoneCountryPublisher = getTimezoneFromApi()
        
        Publishers.Zip3(bitcoinCoincapPublisher, bitcoinCoingeckoPublisher, timezoneCountryPublisher).sink(receiveCompletion:{ [weak self] completion in
            guard case .failure(let error) = completion else { return }
            self?.handleFailure(error)
        }, receiveValue: { [weak self] bitcoinCap, bitcoinGecko, timezone in
            guard let self = self else { return }
            let bitcoinAverage = (bitcoinCap + bitcoinGecko) / 2
            let viewModel = ViewModel(bitcoinPrice: String(bitcoinAverage), timezone: timezone)
            self.render(viewModel: viewModel)
        })
            .store(in: &cancellables)
    }
    
    private func getTimezoneFromApi() -> AnyPublisher<String, ErrorType> {
        return Future<String, ErrorType> { [weak self] promise in
            guard let self = self else { return }
            
            self.timezoneProvider.getTimezone { (result: Result<Country, ErrorType>) in
                switch result {
                case .success(let country):
                    promise(.success(country.timezone))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func getBitcoinPriceFromCoincap() -> AnyPublisher<Double, ErrorType> {
        return Future<Double, ErrorType> { [weak self] promise in
            guard let self = self else { return }
            
            self.bitcoinProvider.getBitcoinPrice(bitcoinUrl: .coincap, completionHandler: { result in
                switch result {
                case .success(let bitcoin):
                    promise(.success(Double(bitcoin.usd)))
                case .failure(let error):
                    promise(.failure(error))
                }
            })
        }.eraseToAnyPublisher()
    }
    
    private func getBitcoinPriceFromCoingecko() -> AnyPublisher<Double, ErrorType> {
        return Future<Double, ErrorType> { [weak self] promise in
            guard let self = self else { return }
            
            self.bitcoinProvider.getBitcoinPrice(bitcoinUrl: .coingecko, completionHandler: { result in
                switch result {
                case .success(let bitcoin):
                    promise(.success(Double(bitcoin.usd)))
                case .failure(let error):
                    promise(.failure(error))
                }
            })
        }.eraseToAnyPublisher()
    }
}

