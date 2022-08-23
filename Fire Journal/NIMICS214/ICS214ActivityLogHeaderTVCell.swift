//
//  ICS214ActivityLogHeaderTVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/12/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit

class ICS214ActivityLogHeaderTVCell: UITableViewCell {

    let dateTimeL = UILabel()
    let activityL = UILabel()

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

extension ICS214ActivityLogHeaderTVCell {
    
    func configure() {
        
        dateTimeL.translatesAutoresizingMaskIntoConstraints = false
        activityL.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(dateTimeL)
        self.contentView.addSubview(activityL)
        
        
        dateTimeL.textAlignment = .left
        dateTimeL.font = .systemFont(ofSize: 16, weight: .semibold )
        dateTimeL.textColor = .label
        dateTimeL.adjustsFontForContentSizeCategory = false
        dateTimeL.text = "Date/Time"
        
        activityL.textAlignment = .left
        activityL.font = .systemFont(ofSize: 16, weight: .semibold )
        activityL.textColor = .label
        activityL.adjustsFontForContentSizeCategory = false
        activityL.text = "Notable Activities"
        
        NSLayoutConstraint.activate([
            
            dateTimeL.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15),
            dateTimeL.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            dateTimeL.widthAnchor.constraint(equalToConstant: 120),
            
            activityL.leadingAnchor.constraint(equalTo: dateTimeL.trailingAnchor, constant: 15),
            activityL.topAnchor.constraint(equalTo: dateTimeL.topAnchor),
            activityL.widthAnchor.constraint(equalToConstant: 200),
            
            ])
        
        
    }
}
