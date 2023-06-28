//
//  BitcoinViewController.swift
//  Bitcoin
//
//  Created by Vanesa Korbenfeld on 21/06/2023.
//

import UIKit
import Combine

class BitcoinViewController: UIViewController {
    private var bitcoinViewModel: BitcoinViewModel
    private var cancellables: Set<AnyCancellable> = []

    init(bitcoinViewModel: BitcoinViewModel) {
        self.bitcoinViewModel = bitcoinViewModel
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
        bitcoinViewModel.getDataFromApi()
        createBindingWithViewModel()
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
    
    func createBindingWithViewModel() {
        bitcoinViewModel.$bitcoinAverage
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
            guard let self = self else { return }
                self.bitcoinLabel.text = self.bitcoinViewModel.bitcoinAverage
            }).store(in: &cancellables)
        
        bitcoinViewModel.$timezone
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
            guard let self = self else { return }
                self.timezoneLabel.text = self.bitcoinViewModel.timezone
            }).store(in: &cancellables)
        
        bitcoinViewModel.$error
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
            guard let self = self, let error = self.bitcoinViewModel.error else { return }
                
                self.handleFailure(error)
            }).store(in: &cancellables)
    }
}
