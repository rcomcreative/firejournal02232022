//
//  PreviewVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 6/24/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData

class PreviewVC: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var theIncident: Incident!
    var theIncidenttime: IncidentTimer!
    var theIncidentLocal: IncidentLocal!
    var theIncidentLocation: FCLocation!
    var thePhotos: [Photo]!
    var incidentIV = UIImageView()
    var incidentNumberL = UILabel()
    var incidentNumber2L = UILabel()
    var theIncidentS: String = "Incident"
    var theIncidentNumber: String = ""
    var incidentAddressL = UILabel()
    var incidentAddress2L = UILabel()
    var theAddress: String = "Address"
    var theAddressWZip: String = ""
    var incidentTypeL = UILabel()
    var incidentType2L = UILabel()
    let incidentType: String = "Local Incident:"
    var theIncidentType: String = ""
    var incidentEmergency1L = UILabel()
    var incidentEmergency2L = UILabel()
    let emergency: String = "Emergency:"
    var theEmergency: String = ""
    var incidentAlarm1L = UILabel()
    var incidentAlarm2L = UILabel()
    let alarm: String = "Alarm:"
    var theAlarm: String = ""
    var incidentArrival1L = UILabel()
    var incidentArrival2L = UILabel()
    let arrival: String = "Arrival:"
    var theArrival: String = ""
    var incidentControlled1L = UILabel()
    var incidentControlled2L = UILabel()
    let controlled: String = "Controlled:"
    var theControlled: String = ""
    var incidentLastUnit1L = UILabel()
    var incidentLastUnit2L = UILabel()
    let lastUnit: String = "Last Unit:"
    var theLastUnit: String = ""
    var incidentPhotoCount1L = UILabel()
    var incidentPhotoCount2L = UILabel()
    let photos: String = "Photo Count:"
    var thePhotoCount: String = ""
    
    var dateFormatter = DateFormatter()
    var typeNameA = ["100515IconSet_092016_fireboard","100515IconSet_092016_emsboard","100515IconSet_092016_rescueboard"]
    
    private let incidentID: NSManagedObjectID
    
    init(incidentID: NSManagedObjectID) {
        self.incidentID = incidentID
        super.init(nibName: nil, bundle: nil)
        theIncident = context.object(with: self.incidentID) as? Incident
        
        if let imageName = theIncident.incidentEntryTypeImageName {
            incidentIV.image = UIImage(named: imageName)
        } else {
            let imageName = typeNameA[0]
            incidentIV.image = UIImage(named: imageName)
        }
        
        
        if let incidentNumber = theIncident.incidentNumber {
            theIncidentNumber = "#" + incidentNumber
        }
        
        if theIncident.incidentType == "Emergency" {
            theEmergency = "Emergency"
        } else if theIncident.incidentType == "Non-Emergency" {
            theEmergency = "Non-Emergency"
        }
        
        if theIncident.incidentLocalDetails != nil {
            theIncidentLocal = theIncident.incidentLocalDetails
            if let local = theIncidentLocal.incidentLocalType {
                theIncidentType = local
            }
        }
        
        if theIncidentType == "" {
            theIncidentType = "Not designated."
        }
        
        if theIncident.theLocation != nil {
            theIncidentLocation = theIncident.theLocation
            var streetAddress: String = ""
            var city: String = ""
            var state: String = ""
            var zip: String = ""
            if theIncidentLocation != nil {
                if let number = theIncidentLocation.streetNumber {
                    streetAddress = number + " "
                }
                if let street = theIncidentLocation.streetName {
                    streetAddress = streetAddress + street
                }
                if let c = theIncidentLocation.city {
                    city = c
                }
                if let s = theIncidentLocation.state {
                    state = s
                }
                if let z = theIncidentLocation.zip {
                    zip = z
                }
                var cityState: String = ""
                if city != "" {
                    cityState = city + ", "
                }
                if state != "" {
                    cityState = cityState + state
                }
                if cityState != "" {
                    theAddressWZip = streetAddress + "\n" + cityState + " " + zip
                } else {
                    theAddressWZip = streetAddress + " " + zip
                }
            } else {
                theAddressWZip = "No location available."
            }
        }
        
        if theAddressWZip == " " || theAddressWZip == "  " {
            theAddressWZip = "No location available."
        }
        
        if theIncident.incidentTimerDetails != nil {
            theIncidenttime = theIncident.incidentTimerDetails
            self.dateFormatter.dateFormat = "EEE MMM, dd, YYYY HH:mm:ss"
            if let alarm = theIncidenttime.incidentAlarmDateTime {
                let dateString = self.dateFormatter.string(from: alarm)
                theAlarm = dateString + "HR"
            }
            if let arrival = theIncidenttime.incidentArrivalDateTime {
                let dateString = self.dateFormatter.string(from: arrival)
                theArrival = dateString + "HR"
            } else {
                theArrival = theAlarm
            }
            if let controlled = theIncidenttime.incidentControlDateTime {
                let dateString = self.dateFormatter.string(from: controlled)
                theControlled = dateString + "HR"
            } else {
                theControlled = theAlarm
            }
            if let lastUnit = theIncidenttime.incidentLastUnitDateTime {
                let dateString = self.dateFormatter.string(from: lastUnit)
                theLastUnit = dateString + "HR"
            } else {
                theLastUnit = theAlarm
            }
        }
        if theIncident.photo != nil {
            guard let attachments = self.theIncident.photo?.allObjects as? [Photo] else { return }
            thePhotos = attachments
            if thePhotos.count > 0 {
                thePhotoCount = String(thePhotos.count)
            } else {
                thePhotoCount = "No photos"
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

}

extension PreviewVC {
    
    func configure() {
        
        incidentIV.translatesAutoresizingMaskIntoConstraints = false
        incidentNumberL.translatesAutoresizingMaskIntoConstraints = false
        incidentNumber2L.translatesAutoresizingMaskIntoConstraints = false
        incidentAddressL.translatesAutoresizingMaskIntoConstraints = false
        incidentAddress2L.translatesAutoresizingMaskIntoConstraints = false
        incidentTypeL.translatesAutoresizingMaskIntoConstraints = false
        incidentType2L.translatesAutoresizingMaskIntoConstraints = false
        incidentAlarm1L.translatesAutoresizingMaskIntoConstraints = false
        incidentAlarm2L.translatesAutoresizingMaskIntoConstraints = false
        incidentArrival1L.translatesAutoresizingMaskIntoConstraints = false
        incidentArrival2L.translatesAutoresizingMaskIntoConstraints = false
        incidentControlled1L.translatesAutoresizingMaskIntoConstraints = false
        incidentControlled2L.translatesAutoresizingMaskIntoConstraints = false
        incidentLastUnit1L.translatesAutoresizingMaskIntoConstraints = false
        incidentLastUnit2L.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(incidentIV)
        self.view.addSubview(incidentNumberL)
        self.view.addSubview(incidentAddressL)
        self.view.addSubview(incidentNumber2L)
        self.view.addSubview(incidentAddress2L)
        self.view.addSubview(incidentType2L)
        self.view.addSubview(incidentTypeL)
        self.view.addSubview(incidentAlarm1L)
        self.view.addSubview(incidentAlarm2L)
        self.view.addSubview(incidentArrival1L)
        self.view.addSubview(incidentArrival2L)
        self.view.addSubview(incidentControlled1L)
        self.view.addSubview(incidentControlled2L)
        self.view.addSubview(incidentLastUnit1L)
        self.view.addSubview(incidentLastUnit2L)
        
        configureLabels()
        configureNSLayouts()
        
    }
    
    func configureLabels() {
        
        incidentNumberL.textAlignment = .left
        incidentNumberL.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        incidentNumberL.textColor = .label
        incidentNumberL.adjustsFontForContentSizeCategory = false
        incidentNumberL.text = theIncidentS
        
        incidentNumber2L.textAlignment = .left
        incidentNumber2L.font = .systemFont(ofSize: 22)
        incidentNumber2L.textColor = UIColor(named: "FJIconRed")
        incidentNumber2L.adjustsFontForContentSizeCategory = false
        incidentNumber2L.text = theIncidentNumber
        
        incidentAddressL.textAlignment = .left
        incidentAddressL.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        incidentAddressL.textColor = .label
        incidentAddressL.adjustsFontForContentSizeCategory = false
        incidentAddressL.text = theAddress
        
        incidentAddress2L.textAlignment = .left
        incidentAddress2L.font = .systemFont(ofSize: 22)
        incidentAddress2L.textColor = UIColor(named: "FJIconRed")
        incidentAddress2L.adjustsFontForContentSizeCategory = false
        incidentAddress2L.lineBreakMode = NSLineBreakMode.byWordWrapping
        incidentAddress2L.numberOfLines = 0
        incidentAddress2L.text = theAddressWZip
        
        incidentTypeL.textAlignment = .left
        incidentTypeL.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        incidentTypeL.textColor = .label
        incidentTypeL.adjustsFontForContentSizeCategory = false
        incidentTypeL.text = incidentType
        
        incidentType2L.textAlignment = .left
        incidentType2L.font = .systemFont(ofSize: 22)
        incidentType2L.textColor = UIColor(named: "FJIconRed")
        incidentType2L.adjustsFontForContentSizeCategory = false
        incidentType2L.lineBreakMode = NSLineBreakMode.byWordWrapping
        incidentType2L.numberOfLines = 0
        incidentType2L.text = theIncidentType
        
        incidentAlarm1L.textAlignment = .left
        incidentAlarm1L.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        incidentAlarm1L.textColor = .label
        incidentAlarm1L.adjustsFontForContentSizeCategory = false
        incidentAlarm1L.text = alarm
        
        incidentAlarm2L.textAlignment = .left
        incidentAlarm2L.font = .systemFont(ofSize: 22)
        incidentAlarm2L.textColor = UIColor(named: "FJIconRed")
        incidentAlarm2L.adjustsFontForContentSizeCategory = false
        incidentAlarm2L.text = theAlarm
        
        incidentArrival1L.textAlignment = .left
        incidentArrival1L.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        incidentArrival1L.textColor = .label
        incidentArrival1L.adjustsFontForContentSizeCategory = false
        incidentArrival1L.text = arrival
        
        incidentArrival2L.textAlignment = .left
        incidentArrival2L.font = .systemFont(ofSize: 22)
        incidentArrival2L.textColor = UIColor(named: "FJIconRed")
        incidentArrival2L.adjustsFontForContentSizeCategory = false
        incidentArrival2L.text = theArrival
        
        incidentControlled1L.textAlignment = .left
        incidentControlled1L.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        incidentControlled1L.textColor = .label
        incidentControlled1L.adjustsFontForContentSizeCategory = false
        incidentControlled1L.text = controlled
        
        incidentControlled2L.textAlignment = .left
        incidentControlled2L.font = .systemFont(ofSize: 22)
        incidentControlled2L.textColor = UIColor(named: "FJIconRed")
        incidentControlled2L.adjustsFontForContentSizeCategory = false
        incidentControlled2L.text = theControlled
        
        incidentLastUnit1L.textAlignment = .left
        incidentLastUnit1L.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        incidentLastUnit1L.textColor = .label
        incidentLastUnit1L.adjustsFontForContentSizeCategory = false
        incidentLastUnit1L.text = lastUnit
        
        incidentLastUnit2L.textAlignment = .left
        incidentLastUnit2L.font = .systemFont(ofSize: 22)
        incidentLastUnit2L.textColor = UIColor(named: "FJIconRed")
        incidentLastUnit2L.adjustsFontForContentSizeCategory = false
        incidentLastUnit2L.text = theLastUnit
        
    }
    
    func configureNSLayouts() {
        
        NSLayoutConstraint.activate([
            
            incidentIV.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            incidentIV.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20),
            incidentIV.heightAnchor.constraint(equalToConstant: 65),
            incidentIV.widthAnchor.constraint(equalToConstant: 65),
            
            incidentNumberL.leadingAnchor.constraint(equalTo: incidentIV.trailingAnchor, constant: 10),
            incidentNumberL.topAnchor.constraint(equalTo: incidentIV.topAnchor),
            incidentNumberL.widthAnchor.constraint(equalToConstant: 150),
            incidentNumberL.heightAnchor.constraint(equalToConstant: 30),
            
            incidentNumber2L.leadingAnchor.constraint(equalTo: incidentNumberL.leadingAnchor),
            incidentNumber2L.topAnchor.constraint(equalTo: incidentNumberL.bottomAnchor, constant: 5),
            incidentNumber2L.widthAnchor.constraint(equalToConstant: 150),
            incidentNumber2L.heightAnchor.constraint(equalToConstant: 30),
            
            incidentTypeL.leadingAnchor.constraint(equalTo: incidentNumberL.leadingAnchor),
            incidentTypeL.topAnchor.constraint(equalTo: incidentNumber2L.bottomAnchor, constant: 5),
            incidentTypeL.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            incidentTypeL.heightAnchor.constraint(equalToConstant: 30),
            
            incidentType2L.leadingAnchor.constraint(equalTo: incidentNumberL.leadingAnchor),
            incidentType2L.topAnchor.constraint(equalTo: incidentTypeL.bottomAnchor, constant: 5),
            incidentType2L.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            incidentType2L.heightAnchor.constraint(equalToConstant: 60),
            
            incidentAddressL.leadingAnchor.constraint(equalTo: incidentNumberL.leadingAnchor),
            incidentAddressL.topAnchor.constraint(equalTo: incidentType2L.bottomAnchor, constant: 5),
            incidentAddressL.widthAnchor.constraint(equalToConstant: 150),
            incidentAddressL.heightAnchor.constraint(equalToConstant: 30),
            
            incidentAddress2L.leadingAnchor.constraint(equalTo: incidentNumberL.leadingAnchor),
            incidentAddress2L.topAnchor.constraint(equalTo: incidentAddressL.bottomAnchor, constant: 5),
            incidentAddress2L.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            incidentAddress2L.heightAnchor.constraint(equalToConstant: 60),
            
            incidentAlarm1L.leadingAnchor.constraint(equalTo: incidentNumberL.leadingAnchor),
            incidentAlarm1L.topAnchor.constraint(equalTo: incidentAddress2L.bottomAnchor, constant: 5),
            incidentAlarm1L.widthAnchor.constraint(equalToConstant: 150),
            incidentAlarm1L.heightAnchor.constraint(equalToConstant: 30),
            
            incidentAlarm2L.leadingAnchor.constraint(equalTo: incidentNumberL.leadingAnchor),
            incidentAlarm2L.topAnchor.constraint(equalTo: incidentAlarm1L.bottomAnchor, constant: 5),
            incidentAlarm2L.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            incidentAlarm2L.heightAnchor.constraint(equalToConstant: 30),
            
            incidentArrival1L.leadingAnchor.constraint(equalTo: incidentNumberL.leadingAnchor),
            incidentArrival1L.topAnchor.constraint(equalTo: incidentAlarm2L.bottomAnchor, constant: 5),
            incidentArrival1L.widthAnchor.constraint(equalToConstant: 150),
            incidentArrival1L.heightAnchor.constraint(equalToConstant: 30),
            
            incidentArrival2L.leadingAnchor.constraint(equalTo: incidentNumberL.leadingAnchor),
            incidentArrival2L.topAnchor.constraint(equalTo: incidentArrival1L.bottomAnchor, constant: 5),
            incidentArrival2L.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            incidentArrival2L.heightAnchor.constraint(equalToConstant: 30),
            
            incidentControlled1L.leadingAnchor.constraint(equalTo: incidentNumberL.leadingAnchor),
            incidentControlled1L.topAnchor.constraint(equalTo: incidentArrival2L.bottomAnchor, constant: 5),
            incidentControlled1L.widthAnchor.constraint(equalToConstant: 150),
            incidentControlled1L.heightAnchor.constraint(equalToConstant: 30),
            
            incidentControlled2L.leadingAnchor.constraint(equalTo: incidentNumberL.leadingAnchor),
            incidentControlled2L.topAnchor.constraint(equalTo: incidentControlled1L.bottomAnchor, constant: 5),
            incidentControlled2L.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            incidentControlled2L.heightAnchor.constraint(equalToConstant: 30),
            
            incidentLastUnit1L.leadingAnchor.constraint(equalTo: incidentNumberL.leadingAnchor),
            incidentLastUnit1L.topAnchor.constraint(equalTo: incidentControlled2L.bottomAnchor, constant: 5),
            incidentLastUnit1L.widthAnchor.constraint(equalToConstant: 150),
            incidentLastUnit1L.heightAnchor.constraint(equalToConstant: 30),
            
            incidentLastUnit2L.leadingAnchor.constraint(equalTo: incidentNumberL.leadingAnchor),
            incidentLastUnit2L.topAnchor.constraint(equalTo: incidentLastUnit1L.bottomAnchor, constant: 5),
            incidentLastUnit2L.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            incidentLastUnit2L.heightAnchor.constraint(equalToConstant: 30),
            
            
        ])
        
    }
}
