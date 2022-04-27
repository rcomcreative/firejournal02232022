//
//  PromotionTagsCVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/26/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit

class PromotionTagsCVCell: UICollectionViewCell {
    
    let theBackgroundView = UIView()
    let tagL = UILabel()
    var theTag: PromotionJournalTags!
    
    var platoonColor: String = "FJIconRed"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PromotionTagsCVCell {
    
    func configure(tag: PromotionJournalTags) {
        self.theTag = tag
        if let name = self.theTag.tag {
            tagL.text = name
        }
        
        theBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(theBackgroundView)
        tagL.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tagL)
        
        theBackgroundView.backgroundColor = UIColor.clear
        theBackgroundView.layer.cornerRadius = 0
        
        tagL.textAlignment = .center
        tagL.font = .systemFont(ofSize: 10, weight: UIFont.Weight(rawValue: 100))
        tagL.textColor = .label
        tagL.adjustsFontForContentSizeCategory = false
        tagL.lineBreakMode = NSLineBreakMode.byWordWrapping
        tagL.numberOfLines = 0
        
        NSLayoutConstraint.activate([
            
            theBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            theBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            theBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            theBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            tagL.centerYAnchor.constraint(equalTo: theBackgroundView.centerYAnchor),
            tagL.centerXAnchor.constraint(equalTo: theBackgroundView.centerXAnchor),
            tagL.leadingAnchor.constraint(equalTo: theBackgroundView.leadingAnchor),
            tagL.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor),
            
            ])
    }
    
}
