//
//  TheStoreTextViewTVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 5/5/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit

class TheStoreTextViewTVCell: UITableViewCell {

    let storeTV = UITextView()
    let theStoreText: String = InfoBodyText.theStoreMembershipText.rawValue
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

extension TheStoreTextViewTVCell {
    
    func configure() {
        
        storeTV.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(storeTV)
        
        switch self.tag {
        case 1:
            storeTV.textAlignment = .left
            storeTV.font = .systemFont(ofSize: 16)
            storeTV.textColor = .label
            storeTV.adjustsFontForContentSizeCategory = true
            storeTV.layer.borderWidth = 0.5
            storeTV.layer.cornerRadius = 4
            storeTV.isUserInteractionEnabled = true
            storeTV.isScrollEnabled = true
            storeTV.isEditable = false
            storeTV.text = theStoreText
        case 8:
            storeTV.textAlignment = .left
            storeTV.font = .systemFont(ofSize: 16)
            storeTV.textColor = .label
            storeTV.adjustsFontForContentSizeCategory = true
            storeTV.isUserInteractionEnabled = true
            storeTV.isScrollEnabled = true
            storeTV.isEditable = false
            storeTV.dataDetectorTypes = .link
            storeTV.text = InfoBodyText.theStoreMembershipText4.rawValue
        default: break
        }
        
        NSLayoutConstraint.activate([
            storeTV.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            storeTV.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            storeTV.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            storeTV.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            ])
    }
}
