//
//  ActionView.swift
//  FinalProject
//
//  Created by Ксения Чепурных on 20.12.2020.
//

import UIKit
import SnapKit
import MapKit

enum ActionViewConfiguration {
    case request
    case sessionInProgress
}

enum ButtonAction: CustomStringConvertible {
    case request
    case end
    
    var description: String {
        switch self {
        case .request: return "SEND INVITATION"
        case .end: return "END"
        }
    }
}

class ActionView: UIView {
    
    // MARK: - Properties
    
    var toggle = false
    var destination: MKPlacemark? {
        didSet {
            titleLabel.text = destination?.name
            addressLabel.text = destination?.address
        }
    }
    
    var config: ActionViewConfiguration = .request
    var buttonAction: ButtonAction = .request
    private var companions: [Companion] = []
    public var selectedCompanion: Companion?
    var delegate: ActionViewDelegate?
    var session: Session?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "title"
        label.textAlignment = .center
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "address"
        label.textAlignment = .center
        return label
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect.zero,
        collectionViewLayout: layout)
        layout.scrollDirection = .horizontal
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.register(CollectionCell.self, forCellWithReuseIdentifier: "CollectionCell")
        return collectionView
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .mainBlueTint
        button.setTitle("SEND INVITATION", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    
//    private let sosButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.backgroundColor = .red
//        button.setTitle("SOS", for: .normal)
//        button.setTitleColor(.white, for: .normal)
//        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
//        button.addTarget(self, action: #selector(sosAction), for: .touchUpInside)
//        return button
//    }()
    
    private let callCompanionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .mainBlueTint
        button.setTitle("CALL COMPANION", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(callCompanion), for: .touchUpInside)
        return button
    }()
    
    private let separator: UIView = {
        let separator = UIView()
        separator.backgroundColor = .lightGray
        return separator
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        Service.shared.fetchCompanions { (companionsArr) in
            self.companions = companionsArr
            self.selectedCompanion = self.companions[0]
            self.collectionView.reloadData()
        }
        
        backgroundColor = .white
        addShadow()
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillEqually
        
        addSubview(stack)
        stack.snp.makeConstraints { (make) in
            make.top.equalTo(safeAreaLayoutGuide).offset(10)
            make.centerX.equalToSuperview()
        }
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(stack.snp.bottom).offset(10)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(100)
        }
        
//        addSubview(separator)
//        separator.snp.makeConstraints { (make) in
//            make.top.equalTo(collectionView.snp.bottom).offset(10)
//            make.left.equalTo(0)
//            make.right.equalTo(0)
//            make.height.equalTo(0.8)
//        }

        addSubview(actionButton)
        actionButton.snp.makeConstraints { (make) in
            make.top.equalTo(collectionView.snp.bottom).offset(10)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(20)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.height.equalTo(50)
        }
        actionButton.isEnabled = false

//        addSubview(sosButton)
//        sosButton.snp.makeConstraints { (make) in
//            make.top.equalTo(safeAreaLayoutGuide).offset(30)
//            make.left.equalTo(12)
//            make.right.equalTo(-12)
//            make.height.equalTo(50)
//        }

        addSubview(callCompanionButton)
        callCompanionButton.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel).offset(100)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.height.equalTo(50)
        }
        
//        sosButton.isHidden = true
        callCompanionButton.isHidden = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Functions
    
    @objc func actionButtonPressed() {
        switch buttonAction {
        case .request:
            delegate?.createSession(self)
            print("rec")
        case .end:
            delegate?.endSession()
        }
    }
    
    func toggleUI() {
        if toggle == false {
            callCompanionButton.isHidden = true
            titleLabel.isHidden = false
            addressLabel.isHidden = false
            collectionView.isHidden = false
            actionButton.backgroundColor = .lightGray
            
            toggle = true
        } else {
            actionButton.isEnabled = true
            addressLabel.isHidden = true
            collectionView.isHidden = true
            actionButton.backgroundColor = .mainBlueTint
            toggle = false
        }
    }
    
//    @objc func sosAction() {
//        print("Sos!")
//    }
    
    @objc func callCompanion() {
        guard let companionPhone = session?.companionPhone else { return }
        if let phoneCallURL = URL(string: "tel://\(companionPhone)") {

                let application:UIApplication = UIApplication.shared
                if (application.canOpenURL(phoneCallURL)) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                }
          }
    }
    
    public func configureUI(withConfig config: ActionViewConfiguration) {
        switch config {
        case .request:
            toggleUI()
            buttonAction = .request
            actionButton.setTitle(buttonAction.description, for: .normal)
            
            buttonAction = .request
            actionButton.setTitle(buttonAction.description, for: .normal)
            
        case .sessionInProgress:
            guard let session = session else { return }
            guard let companionName = session.companionName else { return }
            
            if session.role?.rawValue == SessionRole.user.rawValue {
                titleLabel.text = "\(companionName) is looking after you"
                callCompanionButton.isHidden = false
            } else {
                titleLabel.text = "You are looking after \(companionName)"
                callCompanionButton.isHidden = false
            }
            toggleUI()
            buttonAction = .end
            actionButton.setTitle(buttonAction.description, for: .normal)
        }
    }
}

// MARK: CollectionView

extension ActionView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return companions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectionCell
        cell.nameLabel.text = companions[indexPath.item].fullname
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? CollectionCell
        cell?.photo.layer.borderColor = UIColor.mainBlueTint.cgColor
        cell?.photo.layer.borderWidth = 2
        cell?.isSelected = true
        actionButton.isEnabled = true
        selectedCompanion = companions[indexPath.item]
        actionButton.backgroundColor = .mainBlueTint
    }
    
}

protocol ActionViewDelegate {
    func createSession(_ viev: ActionView)
    func endSession()
}

