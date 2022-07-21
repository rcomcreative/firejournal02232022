//
//  AllShiftIncidentCVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 6/30/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData

class AllShiftIncidentCVCell: UICollectionViewCell {
    
    var theTime: [ShiftIncidentTotals]!
    
    let theBackgroundView = UIView()
    
    var theBorderColor: UIColor!
    
    let titleIconIV = UIImageView()
    let titleL = UILabel()
    
    let backB = UIButton(primaryAction: nil)
    let forewardB = UIButton(primaryAction: nil)
    private var incrementCount: Int = 0
    private var shiftCount: Int!
    private var proactiveCount: Int!
    
    let shiftL = UILabel()
    
    let fireL = UILabel()
    let emsL = UILabel()
    let rescueL = UILabel()
    let fireIconIV = UIImageView()
    let emsIconIV = UIImageView()
    let rescueIconIV = UIImageView()
    let fireCountL = UILabel()
    let emsCountL = UILabel()
    let rescueCountL = UILabel()
    
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
    var fireLabel: String = "Fire"
    var emsLabel: String = "EMS"
    var rescueLabel: String = "Rescue"
    
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
    
    lazy var userTimeProvider: UserTimeProvider = {
        let provider = UserTimeProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var userTimeContext: NSManagedObjectContext!
    var allUserTime: [UserTime]!
    var userTimeIncidents = [ Date : (Int, Int, Int, Int) ]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
}

extension AllShiftIncidentCVCell {
    
    func configure(_ userTime: UserTime) {
        getTheUserTimes()
        shiftCount = theTime.count
        configureObjects()
        configureImagesAndLabels()
        configureNSLayouts()
    }
    
    func configureObjects() {
        
        theBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        titleIconIV.translatesAutoresizingMaskIntoConstraints = false
        titleL.translatesAutoresizingMaskIntoConstraints = false
        backB.translatesAutoresizingMaskIntoConstraints = false
        forewardB.translatesAutoresizingMaskIntoConstraints = false
        shiftL.translatesAutoresizingMaskIntoConstraints = false
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
        contentView.addSubview(backB)
        contentView.addSubview(forewardB)
        contentView.addSubview(shiftL)
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
    
    func configureImagesAndLabels() {
        
        theBorderColor = UIColor(named: "FJBlueColor")
        theBackgroundView.layer.cornerRadius = 8
        theBackgroundView.layer.borderWidth = 1
        theBackgroundView.layer.borderColor = theBorderColor.cgColor
        
        let fire = typeNameA[0]
        iconImage = UIImage(named: "100515IconSet_092016_NFIRSBasic1")
        fireIconImage = UIImage(named: fire)
        let ems = typeNameA[1]
        emsIconImage = UIImage(named: ems)
        let rescue = typeNameA[2]
        rescueIconImage = UIImage(named: rescue)
        
        if iconImage != nil {
            titleIconIV.image = iconImage
        }
        
        if fireIconImage != nil {
            fireIconIV.image = fireIconImage
        }
        
        if emsIconImage != nil {
            emsIconIV.image = emsIconImage
        }
        
        if rescueIconImage != nil {
            rescueIconIV.image = rescueIconImage
        }
        
        titleL.textAlignment = .left
        titleL.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        titleL.textColor = .label
        titleL.adjustsFontForContentSizeCategory = false
        titleL.lineBreakMode = NSLineBreakMode.byWordWrapping
        titleL.numberOfLines = 0
        titleL.text = """
Shifts Incident
Status
"""
        
        shiftL.textAlignment = .center
        shiftL.font = .systemFont(ofSize: 16, weight: UIFont.Weight(rawValue: 300))
        shiftL.textColor = .label
        shiftL.adjustsFontForContentSizeCategory = false
        if let date = theTime.first?.shiftDated {
            shiftL.text = "Shift " + date
        }
        
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
        
        fireCountL.textAlignment = .center
        fireCountL.font = .systemFont(ofSize: 16, weight: UIFont.Weight(rawValue: 300))
        fireCountL.textColor = .label
        fireCountL.adjustsFontForContentSizeCategory = false
        if fireCountL.text == nil {
            if let count = theTime.first?.fire {
                fireCountL.text = String(count)
            } else {
                fireCountL.text = "0"
            }
        }
        
        emsCountL.textAlignment = .center
        emsCountL.font = .systemFont(ofSize: 16, weight: UIFont.Weight(rawValue: 300))
        emsCountL.textColor = .label
        emsCountL.adjustsFontForContentSizeCategory = false
        if emsCountL.text == nil {
            if let count = theTime.first?.ems {
                emsCountL.text = String(count)
            } else {
                emsCountL.text = "0"
            }
        }
        
        rescueCountL.textAlignment = .center
        rescueCountL.font = .systemFont(ofSize: 16, weight: UIFont.Weight(rawValue: 300))
        rescueCountL.textColor = .label
        rescueCountL.adjustsFontForContentSizeCategory = false
        
        if rescueCountL.text == nil {
            if let count = theTime.first?.rescue {
                rescueCountL.text = String(count)
            } else {
                rescueCountL.text = "0"
            }
        }
        
        let backImage = UIImage(systemName: "arrow.left.circle")
        let forwardImage = UIImage(systemName: "arrow.right.circle")
        
        if backImage != nil {
        backB.setImage(backImage, for: .normal)
        }
        
        if forwardImage != nil {
            forewardB.setImage(forwardImage, for: .normal)
        }
        
        forewardB.isHidden = true
        forewardB.isEnabled = false
        forewardB.alpha = 0.0
        
        backB.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
        
        forewardB.addTarget(self, action: #selector( forewardButtonTapped(_:)), for: .touchUpInside)
        
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
        
        backB.leadingAnchor.constraint(equalTo: titleIconIV.leadingAnchor),
        backB.widthAnchor.constraint(equalToConstant: 40),
        backB.heightAnchor.constraint(equalToConstant: 40),
        backB.topAnchor.constraint(equalTo: titleL.bottomAnchor, constant: 20),
        
        forewardB.topAnchor.constraint(equalTo: backB.topAnchor),
        forewardB.widthAnchor.constraint(equalToConstant: 40),
        forewardB.heightAnchor.constraint(equalToConstant: 40),
        forewardB.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -20),
        
        shiftL.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -10),
        shiftL.leadingAnchor.constraint(equalTo: theBackgroundView.leadingAnchor, constant: 10),
        shiftL.topAnchor.constraint(equalTo: backB.bottomAnchor, constant: 10),
        shiftL.heightAnchor.constraint(equalToConstant: 25),
        
        emsL.centerXAnchor.constraint(equalTo: theBackgroundView.centerXAnchor),
        emsL.topAnchor.constraint(equalTo: shiftL.bottomAnchor, constant: 10),
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
    
    @objc func backButtonTapped(_ sender: UIButton) {
        incrementCount += 1
        forewardB.isHidden = false
        forewardB.isEnabled = true
        forewardB.alpha = 100.0
        let shifted = shiftCount - 1
        if  incrementCount > shifted {
            backB.isHidden = true
            backB.isEnabled = false
            backB.alpha = 0.0
        }
        
        if incrementCount < shiftCount {
        if let date = theTime[incrementCount].shiftDated {
            shiftL.text = "Shift " + date
        }
        fireCountL.text = String(theTime[incrementCount].fire)
        emsCountL.text = String(theTime[incrementCount].ems)
        rescueCountL.text = String(theTime[incrementCount].rescue)
        }
        
    }
    
    @objc func forewardButtonTapped(_ sender: UIButton) {
        incrementCount -= 1
        backB.isHidden = false
        backB.isEnabled = true
        backB.alpha = 100.0
        if incrementCount == 0 {
            forewardB.isHidden = true
            forewardB.isEnabled = false
            forewardB.alpha = 0.0
        }
        
        if let date = theTime[incrementCount].shiftDated {
            shiftL.text = "Shift " + date
        }
        fireCountL.text = String(theTime[incrementCount].fire)
        emsCountL.text = String(theTime[incrementCount].ems)
        rescueCountL.text = String(theTime[incrementCount].rescue)
    }
    
    func getTheUserTimes() {
        userTimeContext = userTimeProvider.persistentContainer.newBackgroundContext()
        guard let userTime = userTimeProvider.getAllUserTime(userTimeContext) else {
            return
        }
        allUserTime = userTime
        theTime =  buildTheIncident(allUserTime)
    }
    
    func buildTheIncident(_ theUserTimes: [UserTime]) -> [ ShiftIncidentTotals ] {
        var userTimeIncidents = [ ShiftIncidentTotals ]()
        for theUserTime in theUserTimes {
            guard let incidents = theUserTime.incident?.allObjects as? [Incident] else {
                return userTimeIncidents
            }
            let theFire = incidents.filter { $0.situationIncidentImage == "Fire" }
            fCount = theFire.count
            let theEMS = incidents.filter { $0.situationIncidentImage == "EMS" }
            eCount = theEMS.count
            let theRescue = incidents.filter { $0.situationIncidentImage == "Rescue"}
            rCount = theRescue.count
            iCount = incidents.count
            if let startDate = theUserTime.userStartShiftTime {
                let shiftIncidents = ShiftIncidentTotals.init(theShiftDate: startDate, incidents: iCount, theFire: fCount, theEMS: eCount, theRescue: rCount)
                userTimeIncidents.append(shiftIncidents)
            }
        }
        userTimeIncidents = userTimeIncidents.sorted(by: { return $0.shiftDate > $1.shiftDate } )
        return userTimeIncidents
    }
    
   
}
