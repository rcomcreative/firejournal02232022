//
//  TagsCVCell.swift
//  StationCommand
//
//  Created by DuRand Jones on 11/23/21.
//

import UIKit

class TagsCVCell: UICollectionViewCell {
    
    let theBackgroundView = UIView()
    let tagL = UILabel()
    var theTag: Tag!
    
    var platoonColor: String = "FJIconRed"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension TagsCVCell {
    
    func configure(tag: Tag, platoonColor: String) {
        self.theTag = tag
        self.platoonColor = platoonColor
        if let name = self.theTag.name {
            tagL.text = name
        }
        
        theBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(theBackgroundView)
        tagL.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tagL)
        
        theBackgroundView.backgroundColor = UIColor.clear //UIColor(named: self.platoonColor)
        theBackgroundView.layer.cornerRadius = 0 //8
        
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
