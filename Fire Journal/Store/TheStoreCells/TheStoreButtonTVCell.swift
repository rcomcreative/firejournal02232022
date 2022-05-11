//
//  TheStoreButtonTVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 5/6/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol TheStoreButtonTVCellDelegate: AnyObject {
    func theStoreButtonTapped(type: TheStoreButtonTypes, price: String)
}

class TheStoreButtonTVCell: UITableViewCell {
    
    weak var delegate: TheStoreButtonTVCellDelegate? = nil
    
    let theStoreB = UIButton(primaryAction: nil)
    let theMembershipL = UILabel()
    let thePriceL = UILabel()
    var price: String = ""
    var membership: String = ""
    var enter: String = ""
    var buttonType: TheStoreButtonTypes!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension TheStoreButtonTVCell {
    
    func configure() {
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.buttonSize = .medium
            switch buttonType {
            case .quarterly:
                price = "$7.99"
                membership = " Silver"
                enter = ""
                config.baseBackgroundColor = UIColor(named: "FJSilverColor")
                config.title = membership + " " + price
                config.image = UIImage(systemName: "dollarsign.circle")
            case .annual:
                price = "$39.99"
                membership = " Gold"
                enter = ""
                config.baseBackgroundColor = UIColor(named: "FJGoldMetalic")
                config.title = membership + " " + price
                config.image = UIImage(systemName: "dollarsign.circle")
            case .login:
                price = ""
                membership = ""
                enter = " Login"
                config.baseBackgroundColor = UIColor(named: "FJIconRed")
                config.image = UIImage(systemName: "lock.icloud")
                config.title = enter
            case .restore:
                price = ""
                membership = ""
                enter = " Restore"
                config.baseBackgroundColor = UIColor(named: "FJBlueColor")
                config.image = UIImage(systemName: "arrow.clockwise.icloud")
                config.title = enter
            default: break
            }
            config.baseForegroundColor = .white
            theStoreB.configuration = config
            
            theStoreB.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            
            theStoreB.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(theStoreB)
            
            NSLayoutConstraint.activate([
                
                theStoreB.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 26),
                theStoreB.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -26),
                theStoreB.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
                theStoreB.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
                
                ])
        }
    }
    
    @objc func buttonTapped() {
        delegate?.theStoreButtonTapped(type: buttonType, price: price)
    }
    
}
