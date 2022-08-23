//
//  ICS214ResourcesCVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/12/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData

class ICS214ResourcesCVCell: UICollectionViewCell {
    
    var userAttendees: UserAttendees!
    var objectID: NSManagedObjectID!
    
    let nameL = UILabel()
    let icsPositionL = UILabel()
    let homeAgencyL = UILabel()
    
    var name: String = ""
    var position: String = ""
    var agency: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
}

extension ICS214ResourcesCVCell {
    
    func configure(_ userAttendee: UserAttendees) {
        
        self.userAttendees = userAttendee
        self.objectID = self.userAttendees.objectID
        
        if let theName = self.userAttendees.attendee {
            name = theName
        }
        
        if let thePosition = self.userAttendees.attendeeICSPosition {
            position = thePosition
        }
        
        if let theAgency = self.userAttendees.attendeeHomeAgency {
            agency = theAgency
        }
        
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
        nameL.lineBreakMode = NSLineBreakMode.byWordWrapping
        nameL.numberOfLines = 0
        nameL.text = name
        
        icsPositionL.textAlignment = .left
        icsPositionL.font = .systemFont(ofSize: 16, weight: .semibold )
        icsPositionL.textColor = .label
        icsPositionL.adjustsFontForContentSizeCategory = false
        nameL.lineBreakMode = NSLineBreakMode.byWordWrapping
        nameL.numberOfLines = 0
        icsPositionL.text = position
        
        homeAgencyL.textAlignment = .left
        homeAgencyL.font = .systemFont(ofSize: 16, weight: .semibold )
        homeAgencyL.textColor = .label
        homeAgencyL.adjustsFontForContentSizeCategory = false
        nameL.lineBreakMode = NSLineBreakMode.byWordWrapping
        nameL.numberOfLines = 0
        homeAgencyL.text = agency
        
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
