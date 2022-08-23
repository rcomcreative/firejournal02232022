//
//  ICS214CrewEditVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/15/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData

class ICS214CrewEditVC: UIViewController {
    
    var userAttendees: UserAttendees!
    var objectID: NSManagedObjectID!
    
    let nameL = UILabel()
    let icsPositionL = UILabel()
    let homeAgencyL = UILabel()
    let theBackgroundView = UIView()
    
    var name: String = ""
    var position: String = ""
    var agency: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let window = view.window {
            preferredContentSize.width = window.frame.size.width - 30
        }
        preferredContentSize.height = 200.0
     }

}

extension ICS214CrewEditVC {
    
    func configure(_ userAttendee: UserAttendees) {
        
        self.userAttendees = userAttendee
        self.objectID = self.userAttendees.objectID
        
        if let theName = self.userAttendees.attendee {
            name = "Name: " + theName
        }
        
        if let thePosition = self.userAttendees.attendeeICSPosition {
            position = "Position: " +  thePosition
        }
        
        if let theAgency = self.userAttendees.attendeeHomeAgency {
            agency =  "Home Agency: " + theAgency
        }
        
        theBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        nameL.translatesAutoresizingMaskIntoConstraints = false
        icsPositionL.translatesAutoresizingMaskIntoConstraints = false
        homeAgencyL.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(theBackgroundView)
        theBackgroundView.addSubview(nameL)
        theBackgroundView.addSubview(icsPositionL)
        theBackgroundView.addSubview(homeAgencyL)
        
        theBackgroundView.layer.backgroundColor = UIColor(named: "FJDarkBlue")?.cgColor
        theBackgroundView.layer.cornerRadius = 8
        
        nameL.textAlignment = .left
        nameL.font = .systemFont(ofSize: 16, weight: .semibold )
        nameL.textColor = .white
        nameL.adjustsFontForContentSizeCategory = false
        nameL.lineBreakMode = NSLineBreakMode.byWordWrapping
        nameL.numberOfLines = 0
        nameL.text = name
        
        icsPositionL.textAlignment = .left
        icsPositionL.font = .systemFont(ofSize: 16, weight: .semibold )
        icsPositionL.textColor = .white
        icsPositionL.adjustsFontForContentSizeCategory = false
        icsPositionL.text = position
        
        homeAgencyL.textAlignment = .left
        homeAgencyL.font = .systemFont(ofSize: 16, weight: .semibold )
        homeAgencyL.textColor = .white
        homeAgencyL.adjustsFontForContentSizeCategory = false
        homeAgencyL.text = agency
        
        NSLayoutConstraint.activate([
            
            theBackgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 5),
            theBackgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -5),
            theBackgroundView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -5),
            theBackgroundView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 5),
            
            nameL.leadingAnchor.constraint(equalTo: theBackgroundView.leadingAnchor, constant: 15),
            nameL.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -15),
            nameL.topAnchor.constraint(equalTo: theBackgroundView.topAnchor, constant: 25),
            nameL.heightAnchor.constraint(equalToConstant: 25),
            
            icsPositionL.leadingAnchor.constraint(equalTo: theBackgroundView.leadingAnchor, constant: 15),
            icsPositionL.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -15),
            icsPositionL.topAnchor.constraint(equalTo: nameL.bottomAnchor, constant: 15),
            icsPositionL.heightAnchor.constraint(equalToConstant: 25),
            
            homeAgencyL.leadingAnchor.constraint(equalTo: theBackgroundView.leadingAnchor, constant: 15),
            homeAgencyL.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -15),
            homeAgencyL.topAnchor.constraint(equalTo: icsPositionL.bottomAnchor, constant: 15),
            homeAgencyL.heightAnchor.constraint(equalToConstant: 25),
            
            
            ])
        
    }
}
