//
//  IncidentTextViewTVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/15/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit

class IncidentTextViewTVCell: UITableViewCell {
    
    let descriptionTV = UITextView()
    let theBackgroundView = UIView()
    
    private var theDescription: String = ""
    var information: String = "" {
        didSet {
            self.theDescription = self.information
            self.descriptionTV.text = self.theDescription
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension IncidentTextViewTVCell {
    
    func configure() {
        
        theBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTV.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(theBackgroundView)
        contentView.addSubview(descriptionTV)
        
        
        descriptionTV.layer.borderColor = UIColor.lightGray.cgColor
        descriptionTV.layer.borderWidth = 0.5
        descriptionTV.layer.cornerRadius = 8.0
        descriptionTV.textColor = UIColor(named: "FJIconRed")
        descriptionTV.font = .systemFont(ofSize: 18)
        descriptionTV.textAlignment = .left
        
        NSLayoutConstraint.activate([
            
            theBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            theBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            theBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            theBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            descriptionTV.leadingAnchor.constraint(equalTo: theBackgroundView.leadingAnchor, constant: 15),
            descriptionTV.topAnchor.constraint(equalTo: theBackgroundView.topAnchor, constant: 15),
            descriptionTV.bottomAnchor.constraint(equalTo: theBackgroundView.bottomAnchor, constant: -15),
            descriptionTV.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -35),
            
            ])
    }
    
}
