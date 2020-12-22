//
//  DestinationImputView.swift
//  FinalProject
//
//  Created by Ксения Чепурных on 12.12.2020.
//

import UIKit
import SnapKit

class DestinationInputView: UIView, UITextFieldDelegate {
    
    var delegate: DestinationInputViewDelegate?

    // MARK: UIProperties
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        return button
    }()
    
    lazy var startingLocationTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Current Location"
        textField.backgroundColor = UIColor.rgb(red: 200, green: 200, blue: 200)
        textField.isEnabled = false
        textField.font = UIFont.systemFont(ofSize: 14)
        
        let paddingView = UIView()
        paddingView.snp.makeConstraints { (make) in
            make.height.equalTo(30)
            make.width.equalTo(10)
        }
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    lazy var destinationTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter a destination.."
        textField.backgroundColor = UIColor.rgb(red: 223, green: 228, blue: 234)
        textField.returnKeyType = .search
        textField.font = UIFont.systemFont(ofSize: 14)
        
        let paddingView = UIView()
        paddingView.snp.makeConstraints { (make) in
            make.height.equalTo(30)
            make.width.equalTo(10)
        }
        
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.delegate = self
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViewComponents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Functions
    
    func configureViewComponents() {
        addShadow()
        
        backgroundColor = .white
        
        addSubview(backButton)
        backButton.snp.makeConstraints { (make) in
            make.top.equalTo(safeAreaLayoutGuide).offset(10)
            make.left.equalTo(12)
            make.height.width.equalTo(24)
        }
        
        
        addSubview(startingLocationTextField)
        startingLocationTextField.snp.makeConstraints { (make) in
            make.top.equalTo(backButton.snp.bottom).offset(10)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.height.equalTo(40)
        }
        
        addSubview(destinationTextField)
        destinationTextField.snp.makeConstraints { (make) in
            make.top.equalTo(startingLocationTextField.snp.bottom).offset(10)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.height.equalTo(40)
        }
        
    }
    
    @objc func handleBackButton() {
        delegate?.dissmisDestinationInputView()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text else { return false }
        delegate?.executeSearch(query: query)
        return true
    }
    
}

protocol DestinationInputViewDelegate {
    func dissmisDestinationInputView()
    func executeSearch(query: String)
}
