//
//  DestinationImputView.swift
//  FinalProject
//
//  Created by Ксения Чепурных on 11.12.2020.
//

import UIKit
import SnapKit

class DestinationImputActivationView: UIView {
    
    // MARK: Properties
    
    var delegate: DestinationImputActivationViewDelegate?
    private let dotView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Where are you going?"
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()

    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addShadow()
        
        addSubview(dotView)
        dotView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.snp.centerY)
            make.left.equalTo(16)
            make.height.equalTo(6)
            make.width.equalTo(6)
        }
        
        addSubview(placeholderLabel)
        placeholderLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.left.equalTo(dotView.snp.left).offset(16)
            make.right.equalTo(-16)
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showDestinationImputView))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Functions
    
    @objc func showDestinationImputView() {
        delegate?.presentDestinationImputView()
    }
}

// MARK: Protocol

protocol DestinationImputActivationViewDelegate {
    func presentDestinationImputView()
}
