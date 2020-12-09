//
//  Extensions.swift
//  FinalProject
//
//  Created by Ксения Чепурных on 09.12.2020.
//

import UIKit
import SnapKit

// MARK: Text Field

extension UITextField {
    func createTextField(withPlacehplder placeholder: String, isSecureTextEntry: Bool) -> UITextField {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .black
        textField.keyboardAppearance = .light
        textField.isSecureTextEntry = isSecureTextEntry
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        return textField
    }
}

// MARK: Label

extension UILabel {
    func createLogo() -> UILabel {
        let label = UILabel()
        label.text = "Finder"
        label.font = UIFont(name: "Avenir-Light", size: 36)
        label.textColor = UIColor(white: 0, alpha: 0.8)
        return label
    }
}

// MARK: Container View

extension UIView {
    func createInputContainerView(image: UIImage, textField: UITextField) -> UIView {
        let view = UIView()
        let imageView = UIImageView()
        imageView.image = image
        imageView.alpha = 0.87
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(view.snp.centerY)
            make.width.height.equalTo(24)
            make.left.equalTo(0)
        }
        
        view.addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.centerY.equalTo(view.snp.centerY)
            make.left.equalTo(imageView.snp.right).offset(8)
            make.right.equalTo(-8)
        }
        
        let separator = UIView()
        separator.backgroundColor = .mainBlueTint
        view.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.snp.bottom)
            make.left.right.equalTo(view)
            make.height.equalTo(2)
        }
        return view
    }
    
}

// MARK: Button

extension UIButton {
    func createAuthButton(text: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(text, for: .normal)
        button.setTitleColor(UIColor(white: 1, alpha: 1), for: .normal)
        button.layer.cornerRadius = 5
        button.backgroundColor = .mainBlueTint
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        return button
    }
    
    func createNavigationButton(text1: String, text2: String) -> UIButton {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "\(text1) ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.black])
        attributedTitle.append(NSAttributedString(string: text2, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.mainBlueTint]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }
}

// MARK: Color

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor.init(red: red/255, green: green/255, blue: blue/255, alpha: 1.0)
    }
    
    static let backgruondColor = UIColor.rgb(red: 241, green: 242, blue: 246)
    static let mainBlueTint = UIColor.rgb(red: 30, green: 144, blue: 255)
    
}
