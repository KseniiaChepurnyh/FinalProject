//
//  CollectionCell.swift
//  FinalProject
//
//  Created by Ксения Чепурных on 20.12.2020.
//

import UIKit

class CollectionCell: UICollectionViewCell {
    
    let photo: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "user")
        imageView.layer.cornerRadius = 65 / 2
        imageView.backgroundColor = UIColor.rgb(red: 223, green: 228, blue: 234)
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "name"
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubview(photo)
        photo.snp.makeConstraints { (make) in
            make.top.equalTo(safeAreaLayoutGuide).offset(5)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(65)
        }
        
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(photo.snp.bottom).offset(10)
            make.left.equalTo(0)
            make.right.equalTo(0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
