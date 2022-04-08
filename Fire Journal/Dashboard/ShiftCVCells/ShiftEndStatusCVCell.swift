//
//  ShiftEndStatusCVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 2/23/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData

class ShiftEndStatusCVCell: UICollectionViewCell {
    
    
    lazy var userTimeProvider: UserTimeProvider = {
        let provider = UserTimeProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var userTimeContext: NSManagedObjectContext!
    
    lazy var incidentProvider: IncidentProvider = {
        let provider = IncidentProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var taskContext: NSManagedObjectContext!
    
    
    var dateFormatter = DateFormatter()
    
    var userTime: UserTime!
    let theBackgroundView = UIView()
    
    let shiftIconIV = UIImageView()
    let titleL = UILabel()
    
    let statusL = UILabel()
    let dateL = UILabel()
    let timeL = UILabel()
    let incidentsL = UILabel()
    
    let status2L = UILabel()
    let date2L = UILabel()
    let time2L = UILabel()
    let incidents2L = UILabel()
    
    var status: String = "End Shift"
    var theDate: String = ""
    var theTime: String = ""
    
    private var theIncidentCount: String = ""
    var incidentCount: Int = 0 {
        didSet {
            self.theIncidentCount = String(self.incidentCount) + " Incidents"
        }
    }
    
    var theBorderColor: UIColor!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
}

extension ShiftEndStatusCVCell {
    
    func configure(_ userTime: UserTime) {
        if userTime.shiftCompleted == false {
            self.getTheUserTime()
        }
        getTheShiftIncidentCount()
        dateFormatter.dateFormat = "EEE MMM, dd"
        configureTheObjects()
        configureData()
        configureImageAndLabel()
        configureNSLayout()
    }
    
        /// get the stored guid for the shift
        /// - Parameter guid: String guid for the last shift issued
    func getTheUserTime() {
        userTimeContext = userTimeProvider.persistentContainer.newBackgroundContext()
        guard let userTime = userTimeProvider.getLastCompleteShift(userTimeContext) else {
            let errorMessage = "A start shift is needed to retrieve the incidents of the day"
            print(errorMessage)
            return
        }
        self.userTime = userTime.last
    }
    
    func getTheShiftIncidentCount() {
        taskContext = incidentProvider.persistentContainer.newBackgroundContext()
        if userTime != nil {
        guard let theDate = userTime.userStartShiftTime else {
            return
        }
        guard let incidents = incidentProvider.getTheDaysIncidents(theDate, context: taskContext) else {
            let errorMessage = "there was no date"
            print(errorMessage)
            return
        }
        incidentCount = incidents.count
        } else {
            incidentCount = 0
        }
    }
    
    func configureTheObjects() {
        
        theBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        shiftIconIV.translatesAutoresizingMaskIntoConstraints = false
        titleL.translatesAutoresizingMaskIntoConstraints = false
        statusL.translatesAutoresizingMaskIntoConstraints = false
        dateL.translatesAutoresizingMaskIntoConstraints = false
        timeL.translatesAutoresizingMaskIntoConstraints = false
        incidentsL.translatesAutoresizingMaskIntoConstraints = false
        status2L.translatesAutoresizingMaskIntoConstraints = false
        date2L.translatesAutoresizingMaskIntoConstraints = false
        time2L.translatesAutoresizingMaskIntoConstraints = false
        incidents2L.translatesAutoresizingMaskIntoConstraints = false
        
        
        contentView.addSubview(theBackgroundView)
        contentView.addSubview(shiftIconIV)
        contentView.addSubview(titleL)
        contentView.addSubview(statusL)
        contentView.addSubview(dateL)
        contentView.addSubview(timeL)
        contentView.addSubview(incidentsL)
        contentView.addSubview(status2L)
        contentView.addSubview(date2L)
        contentView.addSubview(time2L)
        contentView.addSubview(incidents2L)
        
    }
    
    func configureData() {
        
        if userTime != nil {
            if let shiftDate = userTime.userEndShiftTime {
                theDate = dateFormatter.string(from: shiftDate)
                dateFormatter.dateFormat = "HH:mm"
                theTime = dateFormatter.string(from: shiftDate)
                theTime = theTime + "HRs"
            }
        }
        
    }
    
    func configureImageAndLabel() {
        
        theBorderColor = UIColor(named: "FJBlueColor")
        theBackgroundView.layer.cornerRadius = 8
        theBackgroundView.layer.borderWidth = 1
        theBackgroundView.layer.borderColor = theBorderColor.cgColor
        
        let image = UIImage(named: "ICONS_startShift")
        if image != nil {
            shiftIconIV.image = image
        }
        
        titleL.textAlignment = .left
        titleL.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        titleL.textColor = .label
        titleL.adjustsFontForContentSizeCategory = false
        titleL.text = "Shift"
        
        statusL.textAlignment = .left
        statusL.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        statusL.textColor = .label
        statusL.adjustsFontForContentSizeCategory = false
        statusL.text = "Status"
        
        dateL.textAlignment = .left
        dateL.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        dateL.textColor = .label
        dateL.adjustsFontForContentSizeCategory = false
        dateL.text = "Date"
        
        timeL.textAlignment = .left
        timeL.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        timeL.textColor = .label
        timeL.adjustsFontForContentSizeCategory = false
        timeL.text = "Time"
        
        incidentsL.textAlignment = .left
        incidentsL.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        incidentsL.textColor = .label
        incidentsL.adjustsFontForContentSizeCategory = false
        incidentsL.text = "Incidents"
        
        status2L.textAlignment = .left
        status2L.font = .systemFont(ofSize: 22)
        status2L.textColor = .label
        status2L.adjustsFontForContentSizeCategory = false
        status2L.text = status
        
        date2L.textAlignment = .left
        date2L.font = .systemFont(ofSize: 22)
        date2L.textColor = .label
        date2L.adjustsFontForContentSizeCategory = false
        date2L.text = theDate
        
        time2L.textAlignment = .left
        time2L.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        time2L.textColor = .label
        time2L.adjustsFontForContentSizeCategory = false
        time2L.text = theTime
        
        incidents2L.textAlignment = .left
        incidents2L.font = .systemFont(ofSize: 22)
        incidents2L.textColor = .label
        incidents2L.adjustsFontForContentSizeCategory = false
        incidents2L.text = theIncidentCount
        
    }
    
    func configureNSLayout() {
        
        if Device.IS_IPHONE {
            NSLayoutConstraint.activate([
                
            theBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            theBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            theBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            theBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            shiftIconIV.leadingAnchor.constraint(equalTo: theBackgroundView.leadingAnchor, constant: 20),
            shiftIconIV.topAnchor.constraint(equalTo: theBackgroundView.topAnchor, constant: 20),
            shiftIconIV.heightAnchor.constraint(equalToConstant: 65),
            shiftIconIV.widthAnchor.constraint(equalToConstant: 65),
            
            titleL.centerYAnchor.constraint(equalTo: shiftIconIV.centerYAnchor),
            titleL.heightAnchor.constraint(equalToConstant: 30),
            titleL.leadingAnchor.constraint(equalTo: shiftIconIV.trailingAnchor, constant: 15),
            titleL.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
            
            statusL.leadingAnchor.constraint(equalTo: shiftIconIV.leadingAnchor),
            statusL.topAnchor.constraint(equalTo: shiftIconIV.bottomAnchor, constant: 10),
            statusL.widthAnchor.constraint(equalToConstant: 150),
            statusL.heightAnchor.constraint(equalToConstant: 30),
            
            status2L.leadingAnchor.constraint(equalTo: statusL.trailingAnchor,constant: 15),
            status2L.topAnchor.constraint(equalTo: statusL.topAnchor),
            status2L.heightAnchor.constraint(equalToConstant: 30),
            status2L.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
            
            dateL.leadingAnchor.constraint(equalTo: shiftIconIV.leadingAnchor),
            dateL.topAnchor.constraint(equalTo: statusL.bottomAnchor, constant: 10),
            dateL.widthAnchor.constraint(equalToConstant: 150),
            dateL.heightAnchor.constraint(equalToConstant: 30),
            
            date2L.leadingAnchor.constraint(equalTo: dateL.trailingAnchor,constant: 15),
            date2L.topAnchor.constraint(equalTo: dateL.topAnchor),
            date2L.heightAnchor.constraint(equalToConstant: 30),
            date2L.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
            
            timeL.leadingAnchor.constraint(equalTo: shiftIconIV.leadingAnchor),
            timeL.topAnchor.constraint(equalTo: dateL.bottomAnchor, constant: 10),
            timeL.widthAnchor.constraint(equalToConstant: 150),
            timeL.heightAnchor.constraint(equalToConstant: 30),
            
            time2L.leadingAnchor.constraint(equalTo: timeL.trailingAnchor,constant: 15),
            time2L.topAnchor.constraint(equalTo: timeL.topAnchor),
            time2L.heightAnchor.constraint(equalToConstant: 30),
            time2L.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
            
            incidentsL.leadingAnchor.constraint(equalTo: shiftIconIV.leadingAnchor),
            incidentsL.topAnchor.constraint(equalTo: timeL.bottomAnchor, constant: 10),
            incidentsL.widthAnchor.constraint(equalToConstant: 150),
            incidentsL.heightAnchor.constraint(equalToConstant: 30),
            
            incidents2L.leadingAnchor.constraint(equalTo: incidentsL.trailingAnchor,constant: 15),
            incidents2L.topAnchor.constraint(equalTo: incidentsL.topAnchor),
            incidents2L.heightAnchor.constraint(equalToConstant: 30),
            incidents2L.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
            
            ])
        } else {
        NSLayoutConstraint.activate([
            
        theBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        theBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        theBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
        theBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        
        shiftIconIV.leadingAnchor.constraint(equalTo: theBackgroundView.leadingAnchor, constant: 20),
        shiftIconIV.topAnchor.constraint(equalTo: theBackgroundView.topAnchor, constant: 20),
        shiftIconIV.heightAnchor.constraint(equalToConstant: 65),
        shiftIconIV.widthAnchor.constraint(equalToConstant: 65),
        
        titleL.centerYAnchor.constraint(equalTo: shiftIconIV.centerYAnchor),
        titleL.heightAnchor.constraint(equalToConstant: 30),
        titleL.leadingAnchor.constraint(equalTo: shiftIconIV.trailingAnchor, constant: 15),
        titleL.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
        
        statusL.leadingAnchor.constraint(equalTo: shiftIconIV.leadingAnchor),
        statusL.topAnchor.constraint(equalTo: shiftIconIV.bottomAnchor, constant: 10),
        statusL.widthAnchor.constraint(equalToConstant: 250),
        statusL.heightAnchor.constraint(equalToConstant: 30),
        
        status2L.leadingAnchor.constraint(equalTo: statusL.trailingAnchor,constant: 15),
        status2L.topAnchor.constraint(equalTo: statusL.topAnchor),
        status2L.heightAnchor.constraint(equalToConstant: 30),
        status2L.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
        
        dateL.leadingAnchor.constraint(equalTo: shiftIconIV.leadingAnchor),
        dateL.topAnchor.constraint(equalTo: statusL.bottomAnchor, constant: 10),
        dateL.widthAnchor.constraint(equalToConstant: 250),
        dateL.heightAnchor.constraint(equalToConstant: 30),
        
        date2L.leadingAnchor.constraint(equalTo: dateL.trailingAnchor,constant: 15),
        date2L.topAnchor.constraint(equalTo: dateL.topAnchor),
        date2L.heightAnchor.constraint(equalToConstant: 30),
        date2L.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
        
        timeL.leadingAnchor.constraint(equalTo: shiftIconIV.leadingAnchor),
        timeL.topAnchor.constraint(equalTo: dateL.bottomAnchor, constant: 10),
        timeL.widthAnchor.constraint(equalToConstant: 250),
        timeL.heightAnchor.constraint(equalToConstant: 30),
        
        time2L.leadingAnchor.constraint(equalTo: timeL.trailingAnchor,constant: 15),
        time2L.topAnchor.constraint(equalTo: timeL.topAnchor),
        time2L.heightAnchor.constraint(equalToConstant: 30),
        time2L.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
        
        incidentsL.leadingAnchor.constraint(equalTo: shiftIconIV.leadingAnchor),
        incidentsL.topAnchor.constraint(equalTo: timeL.bottomAnchor, constant: 10),
        incidentsL.widthAnchor.constraint(equalToConstant: 250),
        incidentsL.heightAnchor.constraint(equalToConstant: 30),
        
        incidents2L.leadingAnchor.constraint(equalTo: incidentsL.trailingAnchor,constant: 15),
        incidents2L.topAnchor.constraint(equalTo: incidentsL.topAnchor),
        incidents2L.heightAnchor.constraint(equalToConstant: 30),
        incidents2L.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
        
        ])
        }
    }
    
}
