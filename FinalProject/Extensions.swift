//
//  Extensions.swift
//  FinalProject
//
//  Created by Ксения Чепурных on 09.12.2020.
//

import UIKit
import SnapKit
import MapKit

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
        label.text = "COMPANION"
        label.font = UIFont(name: "Avenir-Light", size: 30)
        label.textColor = UIColor(white: 0, alpha: 0.8)
        return label
    }
}

// MARK: View

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
    
    func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.6
        layer.shadowOffset = CGSize(width: 0.7, height: 0.7)
        layer.masksToBounds = false
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

extension MKPlacemark {
    var address: String? {
        get {
            guard let subThoroughfare = subThoroughfare else { return nil }
            guard let thoroughfare = thoroughfare else { return nil }
            guard let locality = locality else { return nil }
            guard let adminArea = administrativeArea else { return nil }
            
            return "\(subThoroughfare) \(thoroughfare), \(locality), \(adminArea) "
        }
    }
}

extension UIViewController {
    func presentAlertController(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func shouldPresentLoadingView(_ present: Bool, message: String? = nil) {
        if present {
            let loadingView = UIView()
            loadingView.frame = self.view.frame
            loadingView.backgroundColor = .black
            loadingView.alpha = 0
            loadingView.tag = 1
            
            let indicator = UIActivityIndicatorView()
            indicator.style = .large
            indicator.color = .white
            indicator.center = view.center
            
            let label = UILabel()
            label.text = message
            label.font = UIFont.systemFont(ofSize: 20)
            label.textColor = .white
            label.textAlignment = .center
            label.alpha = 0.87
            
            view.addSubview(loadingView)
            loadingView.addSubview(indicator)
            loadingView.addSubview(label)
            
            label.snp.makeConstraints { (make) in
                make.centerX.equalTo(view.snp.centerX)
                make.top.equalTo(indicator.snp.bottom).offset(30)
            }
            
            indicator.startAnimating()
            
            UIView.animate(withDuration: 0.3) {
                loadingView.alpha = 0.7
            }
        } else {
            view.subviews.forEach { (subview) in
                if subview.tag == 1 {
                    UIView.animate(withDuration: 0.3, animations: {
                        subview.alpha = 0
                    }, completion: { _ in
                        subview.removeFromSuperview()
                    })
                }
            }
        }
    }
}
