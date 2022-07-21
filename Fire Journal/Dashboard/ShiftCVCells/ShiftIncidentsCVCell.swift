    //
    //  ShiftIncidentsCVCell.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 2/23/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //

import UIKit
import CoreData

protocol ShiftIncidentsCVCellDelegate: AnyObject {
    func theIncidentTapped(incidentOID: NSManagedObjectID)
}

class ShiftIncidentsCVCell: UICollectionViewCell {
    
    weak var delegate: ShiftIncidentsCVCellDelegate? = nil
    var dateFormatter = DateFormatter()
    
    var theIncident: Incident!
    var theIncidentAddress: IncidentAddress!
    var theIncidentLocation: FCLocation!
    var theIncidentTimer: IncidentTimer!
    var theIncidents = [Int]()
    
    let theBackgroundView = UIView()
    
    let titleIconIV = UIImageView()
    let titleL = UILabel()
    
    let typeIconIV = UIImageView()
    let incidentCountL = UILabel()
    let incidentDataL = UILabel()
    
    let incidentsL = UILabel()
    let fireL = UILabel()
    let emsL = UILabel()
    let rescueL = UILabel()
    let fireIconIV = UIImageView()
    let emsIconIV = UIImageView()
    let rescueIconIV = UIImageView()
    let fireCountL = UILabel()
    let emsCountL = UILabel()
    let rescueCountL = UILabel()
    var theBorderColor: UIColor!
    
    private var theFireCount = 0
    var fCount = 0 {
        didSet {
            self.theFireCount = self.fCount
        }
    }
    
    private var theEMSCount = 0
    var eCount = 0 {
        didSet {
            self.theEMSCount = eCount
        }
    }
    
    private var theRescueCount = 0
    var rCount = 0 {
        didSet {
            self.theRescueCount = self.rCount
        }
    }
    
    private var theIncidentsCount = 0
    var iCount = 0 {
        didSet {
            self.theIncidentsCount = self.iCount
        }
    }
    
    var fireCount: String = "0"
    var emsCount: String = "0"
    var rescueCount: String = "0"
    var title: String = "Incidents"
    var today: String = "Today's Incidents"
    var typeNameA = ["100515IconSet_092016_fireboard","100515IconSet_092016_emsboard","100515IconSet_092016_rescueboard"]
    var iconImage: UIImage!
    var fireIconImage: UIImage!
    var emsIconImage: UIImage!
    var rescueIconImage: UIImage!
    var lastIncidentIconImage: UIImage!
    var incidentCount: Int = 0
    var incidentCountS: String = ""
    var theIncidentDate: String = ""
    var theIncidentInfo: String = ""
    var theIncidentNumber: String = ""
    var theIncidentStreetAddress: String = ""
    var theIncidentCityStateZip: String = ""
    var theIncidentAlarm: String = ""
    var theIncidentArrival: String = ""
    var theIncidentControlled: String = ""
    var theIncidentLastUnit: String = ""
    var fireLabel: String = "Fire"
    var emsLabel: String = "EMS"
    var rescueLabel: String = "Rescue"
    var theUserTime: UserTime!
    
    
    
    lazy var incidentProvider: IncidentProvider = {
        let provider = IncidentProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var taskContext: NSManagedObjectContext!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
}

extension ShiftIncidentsCVCell {
    
    func configure(_ userTime: UserTime) {
        getThisShiftsIncidents(userTime)
        self.theUserTime = userTime
        dateFormatter.dateFormat = "MM/dd/YYYY"
        if self.theIncident != nil {
            if self.theIncident.theLocation != nil {
                self.theIncidentLocation = self.theIncident.theLocation
            }
            if self.theIncident.incidentTimerDetails != nil {
                self.theIncidentTimer = self.theIncident.incidentTimerDetails
            }
        }
        configureData()
        configureObjects()
        configureImagesLabels()
        configureNSLayouts()
    }
    
        /// get the incidents that have been created since the shift started
        /// - Parameter userTime: startShift information to collect incidents
    func getThisShiftsIncidents(_ userTime: UserTime) {
        taskContext = incidentProvider.persistentContainer.newBackgroundContext()
        guard let incidents = incidentProvider.getTodaysIncidents(context: taskContext, userTime: userTime) else {
            let errorMessage = "There were no incidents related to the listed shift"
            print(errorMessage)
            return }
        let theTodayIncidents = incidents
        if !theTodayIncidents.isEmpty {
            theIncident = theTodayIncidents.first
            let theFire = theTodayIncidents.filter { $0.situationIncidentImage == "Fire" }
            fCount = theFire.count
            let theEMS = theTodayIncidents.filter { $0.situationIncidentImage == "EMS" }
            eCount = theEMS.count
            let theRescue = theTodayIncidents.filter { $0.situationIncidentImage == "Rescue"}
            rCount = theRescue.count
            iCount = theTodayIncidents.count
        }
    }
    
    func configureData() {
        
        if theIncident != nil {
            if let date =  theUserTime.userStartShiftTime {
                theIncidentDate = dateFormatter.string(from: date)
            }
        } else {
            theIncidentDate = "Today"
        }
        
        fireCount = String(theFireCount)
        emsCount = String(theEMSCount)
        rescueCount = String(theRescueCount)
        
        if theIncidentsCount == 0 {
            incidentCountS = "0 incidents for Shift:\n" + theIncidentDate
        } else if theIncidentsCount == 1 {
            incidentCountS = "1 incident for Shift:\n" + theIncidentDate
        } else {
            incidentCountS = "\(theIncidentsCount) incidents for Shift:\n" + theIncidentDate
        }
        
        let fire = typeNameA[0]
        iconImage = UIImage(named: fire)
        fireIconImage = UIImage(named: fire)
        let ems = typeNameA[1]
        emsIconImage = UIImage(named: ems)
        let rescue = typeNameA[2]
        rescueIconImage = UIImage(named: rescue)
        
        if theIncident != nil {
            if let imageName = self.theIncident.incidentEntryTypeImageName {
                lastIncidentIconImage = UIImage(named: imageName)
            } else {
                let fire = typeNameA[0]
                lastIncidentIconImage = UIImage(named: fire)
            }
        }
        
        if theIncident != nil {
            if let incidentID = theIncident.incidentNumber {
                theIncidentNumber = "Incident " + incidentID
            }
            if theIncident.locationAvailable {
                if theIncidentLocation != nil {
                    var theNumber: String = ""
                    var theStreet: String = ""
                    var theCity: String = ""
                    var theState: String = ""
                    var theZip: String = ""
                    if let number = theIncidentLocation.streetNumber {
                        theNumber = number
                    }
                    if let street = theIncidentLocation.streetName {
                        theStreet = street
                    }
                    theIncidentStreetAddress = theNumber + " " + theStreet
                    if let city = theIncidentLocation.city {
                        theCity = city
                    }
                    if let state = theIncidentLocation.state {
                        theState = state
                    }
                    if let zip = theIncidentLocation.zip {
                        theZip = zip
                    }
                    theIncidentCityStateZip = theCity + ", " + theState + " " + theZip
                }
            }
            
            if theIncidentTimer != nil {
                dateFormatter.dateFormat = "HH:mm:ss"
                var alarmTime: String = ""
                var arrivalTime: String = ""
                var controlledTime: String = ""
                var lastUnitTime: String = ""
                if theIncidentTimer.incidentAlarmDateTime != nil {
                    if let alarm = theIncidentTimer.incidentAlarmDateTime {
                        alarmTime = dateFormatter.string(from: alarm)
                    }
                }
                if theIncidentTimer.incidentArrivalDateTime != nil {
                    if let arrival = theIncidentTimer.incidentArrivalDateTime {
                        arrivalTime = dateFormatter.string(from: arrival)
                    }
                }
                if theIncidentTimer.incidentControlDateTime != nil {
                    if let controlled = theIncidentTimer.incidentControlDateTime {
                        controlledTime = dateFormatter.string(from: controlled)
                    }
                }
                if theIncidentTimer.incidentLastUnitDateTime != nil {
                    if let last = theIncidentTimer.incidentLastUnitDateTime {
                        lastUnitTime = dateFormatter.string(from: last)
                    }
                }
                if alarmTime != "" {
                    theIncidentAlarm = alarmTime + "HR" + " Alarm"
                } else {
                    theIncidentAlarm = "No alarm time set"
                }
                if arrivalTime != "" {
                    theIncidentArrival = arrivalTime + "HR" + " Arrival"
                } else {
                    theIncidentArrival = "No arrival time set"
                }
                if controlledTime != "" {
                    theIncidentControlled = controlledTime + "HR" + " Controlled"
                } else {
                    theIncidentControlled = "No controlled time set"
                }
                if lastUnitTime != "" {
                    theIncidentLastUnit = lastUnitTime + "HR" + " Last Unit"
                } else {
                    theIncidentLastUnit = "No last unit time set"
                }
            }
            
            var theAddress = theIncidentStreetAddress + theIncidentCityStateZip
            if theAddress == " ,  " {
                    theAddress = "No address indicated."
            } else {
                theAddress = """
            \(theIncidentStreetAddress)
            \(theIncidentCityStateZip)
            """
            }
            
            if theIncidentNumber == "" {
                theIncidentNumber = "No Incident number was indicated"
            }
            
            theIncidentInfo = """
\(theIncidentNumber)
\(theAddress)
\(theIncidentAlarm)
\(theIncidentArrival)
\(theIncidentControlled)
\(theIncidentLastUnit)
"""
        }
    }
    
    func configureObjects() {
        
        theBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        titleIconIV.translatesAutoresizingMaskIntoConstraints = false
        titleL.translatesAutoresizingMaskIntoConstraints = false
        typeIconIV.translatesAutoresizingMaskIntoConstraints = false
        incidentDataL.translatesAutoresizingMaskIntoConstraints = false
        incidentsL.translatesAutoresizingMaskIntoConstraints = false
        fireL.translatesAutoresizingMaskIntoConstraints = false
        emsL.translatesAutoresizingMaskIntoConstraints = false
        rescueL.translatesAutoresizingMaskIntoConstraints = false
        fireIconIV.translatesAutoresizingMaskIntoConstraints = false
        emsIconIV.translatesAutoresizingMaskIntoConstraints = false
        rescueIconIV.translatesAutoresizingMaskIntoConstraints = false
        fireCountL.translatesAutoresizingMaskIntoConstraints = false
        emsCountL.translatesAutoresizingMaskIntoConstraints = false
        rescueCountL.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(theBackgroundView)
        contentView.addSubview(titleIconIV)
        contentView.addSubview(titleL)
        contentView.addSubview(typeIconIV)
        contentView.addSubview(incidentDataL)
        contentView.addSubview(incidentsL)
        contentView.addSubview(fireL)
        contentView.addSubview(emsL)
        contentView.addSubview(rescueL)
        contentView.addSubview(fireIconIV)
        contentView.addSubview(emsIconIV)
        contentView.addSubview(rescueIconIV)
        contentView.addSubview(fireCountL)
        contentView.addSubview(emsCountL)
        contentView.addSubview(rescueCountL)
        
    }
    
    func configureImagesLabels() {
        
        theBorderColor = UIColor(named: "FJBlueColor")
        theBackgroundView.layer.cornerRadius = 8
        theBackgroundView.layer.borderWidth = 1
        theBackgroundView.layer.borderColor = theBorderColor.cgColor
        
        if iconImage != nil {
            titleIconIV.image = iconImage
        }
        
        titleL.textAlignment = .left
        titleL.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        titleL.textColor = .label
        titleL.adjustsFontForContentSizeCategory = false
        titleL.lineBreakMode = NSLineBreakMode.byWordWrapping
        titleL.numberOfLines = 0
        titleL.text =  incidentCountS
        
        incidentCountL.textAlignment = .left
        incidentCountL.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        incidentCountL.textColor = .label
        incidentCountL.adjustsFontForContentSizeCategory = false
        incidentCountL.text = incidentCountS
        
        if lastIncidentIconImage != nil {
            typeIconIV.image = lastIncidentIconImage
        }
        
        incidentDataL.textAlignment = .left
        incidentDataL.font = .systemFont(ofSize: 18)
        incidentDataL.textColor = UIColor(named: "FJIncidentPlaceHolderRedColor")
        incidentDataL.adjustsFontForContentSizeCategory = false
        incidentDataL.lineBreakMode = NSLineBreakMode.byWordWrapping
        incidentDataL.numberOfLines = 0
        incidentDataL.text = theIncidentInfo
        
        incidentsL.textAlignment = .center
        incidentsL.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        incidentsL.textColor = .label
        incidentsL.adjustsFontForContentSizeCategory = false
        incidentsL.text = today
        
        fireL.textAlignment = .center
        fireL.font = .systemFont(ofSize: 16, weight: UIFont.Weight(rawValue: 300))
        fireL.textColor = .label
        fireL.adjustsFontForContentSizeCategory = false
        fireL.text = fireLabel
        
        emsL.textAlignment = .center
        emsL.font = .systemFont(ofSize: 16, weight: UIFont.Weight(rawValue: 300))
        emsL.textColor = .label
        emsL.adjustsFontForContentSizeCategory = false
        emsL.text = emsLabel
        
        rescueL.textAlignment = .center
        rescueL.font = .systemFont(ofSize: 16, weight: UIFont.Weight(rawValue: 300))
        rescueL.textColor = .label
        rescueL.adjustsFontForContentSizeCategory = false
        rescueL.text = rescueLabel
        
        if fireIconImage != nil {
            fireIconIV.image = fireIconImage
        }
        
        if emsIconImage != nil {
            emsIconIV.image = emsIconImage
        }
        
        if rescueIconImage != nil {
            rescueIconIV.image = rescueIconImage
        }
        
        fireCountL.textAlignment = .center
        fireCountL.font = .systemFont(ofSize: 16, weight: UIFont.Weight(rawValue: 300))
        fireCountL.textColor = .label
        fireCountL.adjustsFontForContentSizeCategory = false
        fireCountL.text = fireCount
        
        emsCountL.textAlignment = .center
        emsCountL.font = .systemFont(ofSize: 16, weight: UIFont.Weight(rawValue: 300))
        emsCountL.textColor = .label
        emsCountL.adjustsFontForContentSizeCategory = false
        emsCountL.text = emsCount
        
        rescueCountL.textAlignment = .center
        rescueCountL.font = .systemFont(ofSize: 16, weight: UIFont.Weight(rawValue: 300))
        rescueCountL.textColor = .label
        rescueCountL.adjustsFontForContentSizeCategory = false
        rescueCountL.text = rescueCount
        
        
        
    }
    
    func configureNSLayouts() {
        
        NSLayoutConstraint.activate([
            
            theBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            theBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            theBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            theBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            titleIconIV.leadingAnchor.constraint(equalTo: theBackgroundView.leadingAnchor, constant: 20),
            titleIconIV.topAnchor.constraint(equalTo: theBackgroundView.topAnchor, constant: 20),
            titleIconIV.heightAnchor.constraint(equalToConstant: 65),
            titleIconIV.widthAnchor.constraint(equalToConstant: 65),
            
            titleL.centerYAnchor.constraint(equalTo: titleIconIV.centerYAnchor),
            titleL.heightAnchor.constraint(equalToConstant: 65),
            titleL.leadingAnchor.constraint(equalTo: titleIconIV.trailingAnchor, constant: 15),
            titleL.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
            
            incidentDataL.leadingAnchor.constraint(equalTo: titleL.leadingAnchor),
            incidentDataL.topAnchor.constraint(equalTo:  titleIconIV.bottomAnchor, constant: 10),
            incidentDataL.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
            incidentDataL.heightAnchor.constraint(equalToConstant: 170),
            
            typeIconIV.leadingAnchor.constraint(equalTo: titleIconIV.leadingAnchor),
            typeIconIV.centerYAnchor.constraint(equalTo: incidentDataL.centerYAnchor),
            typeIconIV.heightAnchor.constraint(equalToConstant: 65),
            typeIconIV.widthAnchor.constraint(equalToConstant: 65),
            
            incidentsL.topAnchor.constraint(equalTo: incidentDataL.bottomAnchor, constant: 20),
            incidentsL.leadingAnchor.constraint(equalTo: typeIconIV.leadingAnchor, constant: 10),
            incidentsL.heightAnchor.constraint(equalToConstant: 35),
            incidentsL.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
            
            emsL.centerXAnchor.constraint(equalTo: theBackgroundView.centerXAnchor),
            emsL.topAnchor.constraint(equalTo: incidentsL.bottomAnchor, constant: 10),
            emsL.widthAnchor.constraint(equalToConstant: 65),
            emsL.heightAnchor.constraint(equalToConstant: 25),
            
            emsIconIV.centerXAnchor.constraint(equalTo: theBackgroundView.centerXAnchor),
            emsIconIV.topAnchor.constraint(equalTo: emsL.bottomAnchor, constant: 10),
            emsIconIV.widthAnchor.constraint(equalToConstant: 65),
            emsIconIV.heightAnchor.constraint(equalToConstant: 65),
            
            emsCountL.centerXAnchor.constraint(equalTo: theBackgroundView.centerXAnchor),
            emsCountL.topAnchor.constraint(equalTo: emsIconIV.bottomAnchor, constant: 10),
            emsCountL.widthAnchor.constraint(equalToConstant: 65),
            emsCountL.heightAnchor.constraint(equalToConstant: 25),
            
            fireL.trailingAnchor.constraint(equalTo: emsL.leadingAnchor, constant: -25),
            fireL.topAnchor.constraint(equalTo: emsL.topAnchor),
            fireL.widthAnchor.constraint(equalToConstant: 65),
            fireL.heightAnchor.constraint(equalToConstant: 25),
            
            fireIconIV.leadingAnchor.constraint(equalTo: fireL.leadingAnchor),
            fireIconIV.widthAnchor.constraint(equalToConstant: 65),
            fireIconIV.heightAnchor.constraint(equalToConstant: 65),
            fireIconIV.topAnchor.constraint(equalTo: emsIconIV.topAnchor),
            
            fireCountL.leadingAnchor.constraint(equalTo: fireL.leadingAnchor),
            fireCountL.widthAnchor.constraint(equalToConstant: 65),
            fireCountL.heightAnchor.constraint(equalToConstant: 25),
            fireCountL.topAnchor.constraint(equalTo: emsCountL.topAnchor),
            
            rescueL.leadingAnchor.constraint(equalTo: emsL.trailingAnchor, constant: 25),
            rescueL.widthAnchor.constraint(equalToConstant: 65),
            rescueL.heightAnchor.constraint(equalToConstant: 25),
            rescueL.topAnchor.constraint(equalTo: emsL.topAnchor),
            
            rescueIconIV.leadingAnchor.constraint(equalTo: rescueL.leadingAnchor),
            rescueIconIV.widthAnchor.constraint(equalToConstant: 65),
            rescueIconIV.heightAnchor.constraint(equalToConstant: 65),
            rescueIconIV.topAnchor.constraint(equalTo: emsIconIV.topAnchor),
            
            rescueCountL.leadingAnchor.constraint(equalTo: rescueL.leadingAnchor),
            rescueCountL.topAnchor.constraint(equalTo: emsCountL.topAnchor),
            rescueCountL.widthAnchor.constraint(equalToConstant: 65),
            rescueCountL.heightAnchor.constraint(equalToConstant: 25),
            
        ])
    }
    
}
