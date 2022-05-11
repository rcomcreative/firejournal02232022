//
//  TheStoreTitleTVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 5/5/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit

class TheStoreTitleTVCell: UITableViewCell {
    
    let iconIV = UIImageView()
    let titleL = UILabel()
    let subTitleL = UILabel()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

extension TheStoreTitleTVCell {
    
    func configure() {
        
        iconIV.translatesAutoresizingMaskIntoConstraints = false
        titleL.translatesAutoresizingMaskIntoConstraints = false
        subTitleL.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(iconIV)
        contentView.addSubview(titleL)
        contentView.addSubview(subTitleL)
        configureObjects()
        configureNSLayouts()
    }
    
    func configureObjects() {
        
        let iconImage = UIImage(named: "cloudCircleLogo-1")
        if iconImage != nil {
            iconIV.image = iconImage
            iconIV.contentMode = .scaleAspectFill
        }
        
        let theTitle: String = """
Fire Journal
Membership
"""
        let theSubTitle: String = """
Advanced Reporting
and Career Tracking
"""
        titleL.textAlignment = .left
        if Device.IS_IPHONE {
            titleL.font = .systemFont(ofSize: 26, weight: UIFont.Weight(rawValue: 300))
        } else {
            titleL.font = .systemFont(ofSize: 35, weight: UIFont.Weight(rawValue: 300))
        }
        titleL.textColor = .label
        titleL.adjustsFontForContentSizeCategory = false
        titleL.lineBreakMode = NSLineBreakMode.byWordWrapping
        titleL.numberOfLines = 0
        titleL.text = theTitle
        
        subTitleL.textAlignment = .left
        if Device.IS_IPHONE {
            subTitleL.font = .systemFont(ofSize: 18, weight: UIFont.Weight(rawValue: 300))
        } else {
            subTitleL.font = .systemFont(ofSize: 25, weight: UIFont.Weight(rawValue: 300))
        }
        subTitleL.textColor = .label
        subTitleL.adjustsFontForContentSizeCategory = false
        subTitleL.lineBreakMode = NSLineBreakMode.byWordWrapping
        subTitleL.numberOfLines = 0
        subTitleL.text = theSubTitle
        
    }
    
    func configureNSLayouts() {
        
        if Device.IS_IPHONE {
            
            NSLayoutConstraint.activate([
                
                
                iconIV.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 5),
                iconIV.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -90),
                iconIV.widthAnchor.constraint(equalToConstant: 140),
                iconIV.heightAnchor.constraint(equalToConstant: 140),
                
                titleL.leadingAnchor.constraint(equalTo: iconIV.trailingAnchor, constant: -10),
                titleL.centerYAnchor.constraint(equalTo: iconIV.centerYAnchor,constant: -25),
                titleL.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                titleL.heightAnchor.constraint(equalToConstant: 70),
                
                subTitleL.leadingAnchor.constraint(equalTo: iconIV.trailingAnchor, constant: -10),
                subTitleL.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                subTitleL.topAnchor.constraint(equalTo: titleL.bottomAnchor, constant: 5),
                subTitleL.heightAnchor.constraint(equalToConstant: 50),
                
                ])
            
            
        } else {
        
        NSLayoutConstraint.activate([
            
            
            iconIV.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 5),
            iconIV.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -120),
            iconIV.widthAnchor.constraint(equalToConstant: 180),
            iconIV.heightAnchor.constraint(equalToConstant: 180),
            
            titleL.leadingAnchor.constraint(equalTo: iconIV.trailingAnchor, constant: -10),
            titleL.centerYAnchor.constraint(equalTo: iconIV.centerYAnchor,constant: -25),
            titleL.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleL.heightAnchor.constraint(equalToConstant: 90),
            
            subTitleL.leadingAnchor.constraint(equalTo: iconIV.trailingAnchor, constant: -10),
            subTitleL.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            subTitleL.topAnchor.constraint(equalTo: titleL.bottomAnchor, constant: 5),
            subTitleL.heightAnchor.constraint(equalToConstant: 70),
            
            ])
        }
        
    }
    
    
}
