//
//  ShiftStartStatusCVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 2/23/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData

class ShiftStartStatusCVCell: UICollectionViewCell {
    
    var dateFormatter = DateFormatter()
    
    var userTime: UserTime!
    let theBackgroundView = UIView()
    
    let shiftIconIV = UIImageView()
    let titleL = UILabel()
    
    let statusL = UILabel()
    let dateL = UILabel()
    let timeL = UILabel()
    let platoonL = UILabel()
    let stationL = UILabel()
    let assignmentL = UILabel()
    let apparatusL = UILabel()
    let supervisorL = UILabel()
    
    let status2L = UILabel()
    let date2L = UILabel()
    let time2L = UILabel()
    let platoon2L = UILabel()
    let station2L = UILabel()
    let assignment2L = UILabel()
    let apparatus2L = UILabel()
    let supervisor2L = UILabel()
    
    var status: String = "Today's Shift"
    var theDate: String = ""
    var theTime: String = ""
    var thePlatoon: String = ""
    var theStation: String = ""
    var theAssignment: String = ""
    var theAssignedApparatus: String = ""
    var theSupervisor: String = ""
    
    var theBorderColor: UIColor!
    var thePlatoonColor: UIColor!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
}

extension ShiftStartStatusCVCell {
    
    func configure(_ userTime: UserTime) {
        self.userTime = userTime
        dateFormatter.dateFormat = "EEE MMM, dd, YYYY"
        configureTheObjects()
        configureData()
        configureLabelsImages()
        configureNSLayouts()
    }
    
    func configureTheObjects() {
        
        theBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        shiftIconIV.translatesAutoresizingMaskIntoConstraints = false
        titleL.translatesAutoresizingMaskIntoConstraints = false
        statusL.translatesAutoresizingMaskIntoConstraints = false
        dateL.translatesAutoresizingMaskIntoConstraints = false
        timeL.translatesAutoresizingMaskIntoConstraints = false
        platoonL.translatesAutoresizingMaskIntoConstraints = false
        stationL.translatesAutoresizingMaskIntoConstraints = false
        assignmentL.translatesAutoresizingMaskIntoConstraints = false
        apparatusL.translatesAutoresizingMaskIntoConstraints = false
        supervisorL.translatesAutoresizingMaskIntoConstraints = false
        status2L.translatesAutoresizingMaskIntoConstraints = false
        date2L.translatesAutoresizingMaskIntoConstraints = false
        time2L.translatesAutoresizingMaskIntoConstraints = false
        platoon2L.translatesAutoresizingMaskIntoConstraints = false
        station2L.translatesAutoresizingMaskIntoConstraints = false
        assignment2L.translatesAutoresizingMaskIntoConstraints = false
        apparatus2L.translatesAutoresizingMaskIntoConstraints = false
        supervisor2L.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(theBackgroundView)
        contentView.addSubview(shiftIconIV)
        contentView.addSubview(titleL)
        contentView.addSubview(statusL)
        contentView.addSubview(dateL)
        contentView.addSubview(timeL)
        contentView.addSubview(platoonL)
        contentView.addSubview(stationL)
        contentView.addSubview(assignmentL)
        contentView.addSubview(apparatusL)
        contentView.addSubview(supervisorL)
        contentView.addSubview(status2L)
        contentView.addSubview(date2L)
        contentView.addSubview(time2L)
        contentView.addSubview(platoon2L)
        contentView.addSubview(station2L)
        contentView.addSubview(assignment2L)
        contentView.addSubview(apparatus2L)
        contentView.addSubview(supervisor2L)
        
    }
    
    func configureData() {
       
        if let shiftDate = userTime.userStartShiftTime {
            theDate = dateFormatter.string(from: shiftDate)
            dateFormatter.dateFormat = "HH:mm"
            theTime = dateFormatter.string(from: shiftDate)
            theTime = theTime + "HRs"
        }
        
        if let platoon = userTime.startShiftPlatoon {
            thePlatoon = platoon
            if platoon == "A Platoon" {
                thePlatoonColor = UIColor(named: "FJIconRed")
            } else if platoon == "B Platoon" {
                thePlatoonColor = UIColor(named: "FJBlue")
            } else if platoon == "C Platoon" {
                thePlatoonColor = UIColor(named: "FJGreen")
            } else if platoon == "D Platoon" {
                thePlatoonColor = UIColor(named: "FJGold")
            }
        }
        
        if let station = userTime.startShiftFireStation {
            theStation = station
        }
        
        if let assignment = userTime.startShiftAssignment {
            theAssignment = assignment
        }
        
        if let assignedApparatus = userTime.startShiftApparatus {
            theAssignedApparatus = assignedApparatus
        }
        
        if let supervisor = userTime.startShiftSupervisor {
            theSupervisor = supervisor
        }
        
    }
    
    func configureLabelsImages() {
        
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
        
        platoonL.textAlignment = .left
        platoonL.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        platoonL.textColor = .label
        platoonL.adjustsFontForContentSizeCategory = false
        platoonL.text = "Platoon"
        
        stationL.textAlignment = .left
        stationL.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        stationL.textColor = .label
        stationL.adjustsFontForContentSizeCategory = false
        stationL.text = "Fire Station"
        
        assignmentL.textAlignment = .left
        assignmentL.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        assignmentL.textColor = .label
        assignmentL.adjustsFontForContentSizeCategory = false
        assignmentL.text = "Assignment"
        
        apparatusL.textAlignment = .left
        apparatusL.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        apparatusL.textColor = .label
        apparatusL.adjustsFontForContentSizeCategory = false
        apparatusL.lineBreakMode = NSLineBreakMode.byWordWrapping
        apparatusL.numberOfLines = 0
        apparatusL.text = """
Assigned
Apparatus
"""
        
        supervisorL.textAlignment = .left
        supervisorL.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        supervisorL.textColor = .label
        supervisorL.adjustsFontForContentSizeCategory = false
        supervisorL.text = "Supervisor"
        
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
        time2L.font = .systemFont(ofSize: 22)
        time2L.textColor = .label
        time2L.adjustsFontForContentSizeCategory = false
        time2L.text = theTime
        
        platoon2L.textAlignment = .left
        platoon2L.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        platoon2L.textColor = thePlatoonColor
        platoon2L.adjustsFontForContentSizeCategory = false
        platoon2L.text = thePlatoon
        
        station2L.textAlignment = .left
        station2L.font = .systemFont(ofSize: 22)
        station2L.textColor = .label
        station2L.adjustsFontForContentSizeCategory = false
        station2L.text = theStation
        
        assignment2L.textAlignment = .left
        assignment2L.font = .systemFont(ofSize: 22)
        assignment2L.textColor = .label
        assignment2L.adjustsFontForContentSizeCategory = false
        assignment2L.text = theAssignment
        
        apparatus2L.textAlignment = .left
        apparatus2L.font = .systemFont(ofSize: 22)
        apparatus2L.textColor = .label
        apparatus2L.adjustsFontForContentSizeCategory = false
        apparatus2L.text = theAssignedApparatus
        
        supervisor2L.textAlignment = .left
        supervisor2L.font = .systemFont(ofSize: 22)
        supervisor2L.textColor = .label
        supervisor2L.adjustsFontForContentSizeCategory = false
        supervisor2L.text = theSupervisor
        
    }
    
    func configureNSLayouts() {
        
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
            
            platoonL.leadingAnchor.constraint(equalTo: shiftIconIV.leadingAnchor),
            platoonL.topAnchor.constraint(equalTo: timeL.bottomAnchor, constant: 10),
            platoonL.widthAnchor.constraint(equalToConstant: 150),
            platoonL.heightAnchor.constraint(equalToConstant: 30),
            
            platoon2L.leadingAnchor.constraint(equalTo: platoonL.trailingAnchor,constant: 15),
            platoon2L.topAnchor.constraint(equalTo: platoonL.topAnchor),
            platoon2L.heightAnchor.constraint(equalToConstant: 30),
            platoon2L.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
            
            stationL.leadingAnchor.constraint(equalTo: shiftIconIV.leadingAnchor),
            stationL.topAnchor.constraint(equalTo: platoonL.bottomAnchor, constant: 10),
            stationL.widthAnchor.constraint(equalToConstant: 150),
            stationL.heightAnchor.constraint(equalToConstant: 30),
            
            station2L.leadingAnchor.constraint(equalTo: stationL.trailingAnchor,constant: 15),
            station2L.topAnchor.constraint(equalTo: stationL.topAnchor),
            station2L.heightAnchor.constraint(equalToConstant: 30),
            station2L.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
            
            assignmentL.leadingAnchor.constraint(equalTo: shiftIconIV.leadingAnchor),
            assignmentL.topAnchor.constraint(equalTo: stationL.bottomAnchor, constant: 10),
            assignmentL.widthAnchor.constraint(equalToConstant: 150),
            assignmentL.heightAnchor.constraint(equalToConstant: 30),
            
            assignment2L.leadingAnchor.constraint(equalTo: assignmentL.trailingAnchor,constant: 15),
            assignment2L.topAnchor.constraint(equalTo: assignmentL.topAnchor),
            assignment2L.heightAnchor.constraint(equalToConstant: 30),
            assignment2L.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
            
            apparatusL.leadingAnchor.constraint(equalTo: shiftIconIV.leadingAnchor),
            apparatusL.topAnchor.constraint(equalTo: assignmentL.bottomAnchor, constant: 10),
            apparatusL.widthAnchor.constraint(equalToConstant: 150),
            apparatusL.heightAnchor.constraint(equalToConstant: 45),
            
            apparatus2L.leadingAnchor.constraint(equalTo: apparatusL.trailingAnchor,constant: 15),
            apparatus2L.centerYAnchor.constraint(equalTo: apparatusL.centerYAnchor),
            apparatus2L.heightAnchor.constraint(equalToConstant: 30),
            apparatus2L.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
            
            supervisorL.leadingAnchor.constraint(equalTo: shiftIconIV.leadingAnchor),
            supervisorL.topAnchor.constraint(equalTo: apparatusL.bottomAnchor, constant: 10),
            supervisorL.widthAnchor.constraint(equalToConstant: 150),
            supervisorL.heightAnchor.constraint(equalToConstant: 30),
            
            supervisor2L.leadingAnchor.constraint(equalTo: supervisorL.trailingAnchor,constant: 15),
            supervisor2L.topAnchor.constraint(equalTo: supervisorL.topAnchor),
            supervisor2L.heightAnchor.constraint(equalToConstant: 30),
            supervisor2L.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
            
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
        
        platoonL.leadingAnchor.constraint(equalTo: shiftIconIV.leadingAnchor),
        platoonL.topAnchor.constraint(equalTo: timeL.bottomAnchor, constant: 10),
        platoonL.widthAnchor.constraint(equalToConstant: 250),
        platoonL.heightAnchor.constraint(equalToConstant: 30),
        
        platoon2L.leadingAnchor.constraint(equalTo: platoonL.trailingAnchor,constant: 15),
        platoon2L.topAnchor.constraint(equalTo: platoonL.topAnchor),
        platoon2L.heightAnchor.constraint(equalToConstant: 30),
        platoon2L.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
        
        stationL.leadingAnchor.constraint(equalTo: shiftIconIV.leadingAnchor),
        stationL.topAnchor.constraint(equalTo: platoonL.bottomAnchor, constant: 10),
        stationL.widthAnchor.constraint(equalToConstant: 250),
        stationL.heightAnchor.constraint(equalToConstant: 30),
        
        station2L.leadingAnchor.constraint(equalTo: stationL.trailingAnchor,constant: 15),
        station2L.topAnchor.constraint(equalTo: stationL.topAnchor),
        station2L.heightAnchor.constraint(equalToConstant: 30),
        station2L.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
        
        assignmentL.leadingAnchor.constraint(equalTo: shiftIconIV.leadingAnchor),
        assignmentL.topAnchor.constraint(equalTo: stationL.bottomAnchor, constant: 10),
        assignmentL.widthAnchor.constraint(equalToConstant: 250),
        assignmentL.heightAnchor.constraint(equalToConstant: 30),
        
        assignment2L.leadingAnchor.constraint(equalTo: assignmentL.trailingAnchor,constant: 15),
        assignment2L.topAnchor.constraint(equalTo: assignmentL.topAnchor),
        assignment2L.heightAnchor.constraint(equalToConstant: 30),
        assignment2L.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
        
        apparatusL.leadingAnchor.constraint(equalTo: shiftIconIV.leadingAnchor),
        apparatusL.topAnchor.constraint(equalTo: assignmentL.bottomAnchor, constant: 10),
        apparatusL.widthAnchor.constraint(equalToConstant: 250),
        apparatusL.heightAnchor.constraint(equalToConstant: 45),
        
        apparatus2L.leadingAnchor.constraint(equalTo: apparatusL.trailingAnchor,constant: 15),
        apparatus2L.centerYAnchor.constraint(equalTo: apparatusL.centerYAnchor),
        apparatus2L.heightAnchor.constraint(equalToConstant: 30),
        apparatus2L.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
        
        supervisorL.leadingAnchor.constraint(equalTo: shiftIconIV.leadingAnchor),
        supervisorL.topAnchor.constraint(equalTo: apparatusL.bottomAnchor, constant: 10),
        supervisorL.widthAnchor.constraint(equalToConstant: 250),
        supervisorL.heightAnchor.constraint(equalToConstant: 30),
        
        supervisor2L.leadingAnchor.constraint(equalTo: supervisorL.trailingAnchor,constant: 15),
        supervisor2L.topAnchor.constraint(equalTo: supervisorL.topAnchor),
        supervisor2L.heightAnchor.constraint(equalToConstant: 30),
        supervisor2L.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
        
        ])
        }
    }
    
}
