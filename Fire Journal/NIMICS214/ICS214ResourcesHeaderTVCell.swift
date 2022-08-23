//
//  ICS214ResourcesHeaderTVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/12/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit

class ICS214ResourcesHeaderTVCell: UITableViewCell {
    
    let nameL = UILabel()
    let icsPositionL = UILabel()
    let homeAgencyL = UILabel()

    override func awakeFromNib() {
        super.awakeFromNib()
            // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
            // Configure the view for the selected state
    }

}

extension ICS214ResourcesHeaderTVCell {
    
    func configure() {
        
        nameL.translatesAutoresizingMaskIntoConstraints = false
        icsPositionL.translatesAutoresizingMaskIntoConstraints = false
        homeAgencyL.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(nameL)
        self.contentView.addSubview(icsPositionL)
        self.contentView.addSubview(homeAgencyL)
        
        nameL.textAlignment = .left
        nameL.font = .systemFont(ofSize: 16, weight: .semibold )
        nameL.textColor = .label
        nameL.adjustsFontForContentSizeCategory = false
        nameL.text = "Name"
        
        icsPositionL.textAlignment = .left
        icsPositionL.font = .systemFont(ofSize: 16, weight: .semibold )
        icsPositionL.textColor = .label
        icsPositionL.adjustsFontForContentSizeCategory = false
        icsPositionL.text = "ICS Position"
        
        homeAgencyL.textAlignment = .left
        homeAgencyL.font = .systemFont(ofSize: 16, weight: .semibold )
        homeAgencyL.textColor = .label
        homeAgencyL.adjustsFontForContentSizeCategory = false
        homeAgencyL.text = "Home Agency"
        
        NSLayoutConstraint.activate([
            
            nameL.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15),
            nameL.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            nameL.widthAnchor.constraint(equalToConstant: 90),
            
            icsPositionL.leadingAnchor.constraint(equalTo: nameL.trailingAnchor, constant: 15),
            icsPositionL.topAnchor.constraint(equalTo: nameL.topAnchor),
            icsPositionL.widthAnchor.constraint(equalToConstant: 110),
            
            homeAgencyL.leadingAnchor.constraint(equalTo: icsPositionL.trailingAnchor, constant: 15),
            homeAgencyL.topAnchor.constraint(equalTo: nameL.topAnchor),
            homeAgencyL.widthAnchor.constraint(equalToConstant: 110),
            
            
            ])
    }
}
