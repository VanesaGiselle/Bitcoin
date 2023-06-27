//
//  BitcoinViewController.swift
//  Bitcoin
//
//  Created by Vanesa Korbenfeld on 21/06/2023.
//

import UIKit

class BitcoinView: UIViewController {
    private var presenter: BitcoinPresenter

    init(presenter: BitcoinPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        presenter.delegate = self
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
    
    private func getDataFromApi() {
        presenter.getDataFromApi()
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
}

extension BitcoinView: BitcoinUI {
    func render(_ bitcoinPrice: String, _ timezone: String) {
        bitcoinLabel.text = bitcoinPrice
        timezoneLabel.text = timezone
    }
    
    func handleError(_ error: ErrorType) {
        self.handleFailure(error)
    }
}
