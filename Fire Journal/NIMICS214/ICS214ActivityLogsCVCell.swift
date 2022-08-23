//
//  ICS214ActivityLogsCVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/13/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData

class ICS214ActivityLogsCVCell: UICollectionViewCell {
    
    var theActivityLog: ICS214ActivityLog!
    
    lazy var theICS214Provider: ICS214Provider = {
        let provider = ICS214Provider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theICS214ProviderContext: NSManagedObjectContext!
    
    
    let dateTimeL = UILabel()
    let activityL = UILabel()
    
    var theDateTime: String = ""
    var theActivity: String = ""
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
}

extension ICS214ActivityLogsCVCell {
    
    func configure(_ actiivtyLog: ICS214ActivityLog) {
        self.theActivityLog = actiivtyLog
        
        if let activity = self.theActivityLog.ics214ActivityLog {
            self.theActivity = activity
        }
        
        if let theDate = self.theActivityLog.ics214ActivityDate {
            theICS214ProviderContext = theICS214Provider.persistentContainer.newBackgroundContext()
            self.theDateTime = theICS214Provider.determineTheICS214StringDate(theDate: theDate)
        }
        
        self.dateTimeL.translatesAutoresizingMaskIntoConstraints = false
        self.activityL.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(self.dateTimeL)
        self.contentView.addSubview(self.activityL)
        
        dateTimeL.textAlignment = .left
        dateTimeL.font = .systemFont(ofSize: 16, weight: .semibold )
        dateTimeL.textColor = .label
        dateTimeL.adjustsFontForContentSizeCategory = false
        dateTimeL.lineBreakMode = NSLineBreakMode.byWordWrapping
        dateTimeL.numberOfLines = 0
        dateTimeL.text = self.theDateTime
        
        activityL.textAlignment = .left
        activityL.font = .systemFont(ofSize: 16)
        activityL.textColor = .label
        activityL.adjustsFontForContentSizeCategory = false
        activityL.lineBreakMode = NSLineBreakMode.byTruncatingTail
        activityL.numberOfLines = 3
        if self.theActivity == "" {
            self.theActivity = "The activity log was not saved - by long pressing this area you can edit the text."
        }
        activityL.text = self.theActivity
        
        NSLayoutConstraint.activate([
            
            dateTimeL.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15),
            dateTimeL.widthAnchor.constraint(equalToConstant: 105),
            dateTimeL.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            
            activityL.leadingAnchor.constraint(equalTo: dateTimeL.trailingAnchor, constant: 15),
            activityL.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            activityL.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5),
            activityL.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            
            ])
    }
    
}
