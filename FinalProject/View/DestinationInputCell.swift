//
//  DestinationInputCell.swift
//  FinalProject
//
//  Created by Ксения Чепурных on 12.12.2020.
//

import UIKit
import SnapKit
import MapKit

class DestinationInputCell: UITableViewCell {
    
    // MARK: - Properties
    
    var placemark: MKPlacemark? {
        didSet {
            titleLabel.text = placemark?.name
            addressLabel.text = placemark?.address
        }
    }
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private var addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        stack.distribution = .fillEqually
        stack.axis = .vertical
        stack.spacing = 4
        
        addSubview(stack)
        stack.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.snp.centerY)
            make.left.equalTo(12)
            make.right.equalTo(-12)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
