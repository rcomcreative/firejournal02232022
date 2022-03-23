//
//  StationIncidentCVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 2/23/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData

class StationIncidentCVCell: UICollectionViewCell {
    
    var yearCounts: [ Int : [(Int,[Int])] ]!
    
    let theBackgroundView = UIView()
    
    let titleIconIV = UIImageView()
    let titleL = UILabel()
    
    let backB = UIButton(primaryAction: nil)
    let forewardB = UIButton(primaryAction: nil)
    
    let yearL = UILabel()
    let monthL = UILabel()
    
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
    
    var theBorderColor: UIColor!
    
    private var yearCount: Int!
    private var thisYear: Int!
    private var thisMonth: Int!
    
    
    var primaryMonth: Int = 0 {
        didSet {
            self.thisMonth = self.primaryMonth
        }
    }
    
    var primaryYear: Int = 0 {
        didSet {
            self.thisYear = self.primaryYear
            self.yearL.text = String(self.primaryYear)
        }
    }
    
    var years: [Int] = [] {
        didSet {
            self.yearCount = self.years.count
        }
    }
    
    private var yearsOfCounts: [ Int : [(Int,[Int])] ]!
    var yearOfCounts: [ Int : [(Int,[Int])] ] = [0:[(0, [])]] {
        didSet {
            self.yearsOfCounts = self.yearOfCounts
        }
    }
    
    private var primaryMonthCounts: [(Int,Int)]! {
        didSet {
            for (key,value) in self.primaryMonthCounts {
                print("primaryMonthCounts here is the key \(key) and the value \(value)")
                if key == 0 {
                    self.fireCountL.text = String(value)
                    self.fireCountL.setNeedsDisplay()
                } else if key == 1 {
                    self.emsCountL.text = String(value)
                    self.emsCountL.setNeedsDisplay()
                } else if key == 2 {
                    self.rescueCountL.text = String(value)
                    self.rescueCountL.setNeedsDisplay()
                }
            }
        }
    }
    
    private var incrementCount: Int = 0
    private var primaryButtonCount: Int!
    private var proactiveCount: Int!
    private var theCountsForTheButtons = [EachMonthsTotal]()
    var monthsTotalWithYearCounts: [EachMonthsTotal] = [] {
        didSet {
            self.theCountsForTheButtons = self.monthsTotalWithYearCounts
            self.primaryButtonCount = self.monthsTotalWithYearCounts.count
            self.incrementCount = self.primaryButtonCount
            if self.primaryButtonCount > 0 {
                let count = 12 - self.primaryMonth
                self.incrementCount = self.incrementCount - count
                self.incrementCount -= 1
                self.proactiveCount = self.incrementCount
            }
        }
    }
    
    lazy var incidentMonthTotalsProvider: IncidentMonthTotalsProvider = {
        let provider = IncidentMonthTotalsProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var incidentMonthTotalsContext: NSManagedObjectContext!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
}

extension StationIncidentCVCell {
    
    func configure() {
        getIncidentMonthTotals()
        let monthElements: [Any] = Date().month(date: Date())
        if !monthElements.isEmpty {
            let month = monthElements[0] as! String
            monthL.text = "\(month)'s Totals"
            monthL.setNeedsDisplay()
        }
        forewardB.isHidden = true
        configureObjects()
        configureImagesAndLabels()
        configureNSLayouts()
    }
    
    func getIncidentMonthTotals() {
        incidentMonthTotalsContext = incidentMonthTotalsProvider.persistentContainer.newBackgroundContext()
        yearCounts = incidentMonthTotalsProvider.buidTheIncidentTotals(context: incidentMonthTotalsContext)
        years = incidentMonthTotalsProvider.getYearArray(context: incidentMonthTotalsContext)
        monthsTotalWithYearCounts = incidentMonthTotalsProvider.getTheYearBuilt(years: years, yearsOfMonths: yearCounts)
        primaryMonthCounts = incidentMonthTotalsProvider.getPrimaryMonthCounts(yearsOfMonths: yearCounts)
    }
    
    func configureObjects() {
        
        theBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        titleIconIV.translatesAutoresizingMaskIntoConstraints = false
        titleL.translatesAutoresizingMaskIntoConstraints = false
        backB.translatesAutoresizingMaskIntoConstraints = false
        forewardB.translatesAutoresizingMaskIntoConstraints = false
        yearL.translatesAutoresizingMaskIntoConstraints = false
        monthL.translatesAutoresizingMaskIntoConstraints = false
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
        contentView.addSubview(yearL)
        contentView.addSubview(monthL)
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
Total Incident
Status
"""
        
        yearL.textAlignment = .center
        yearL.font = .systemFont(ofSize: 16, weight: UIFont.Weight(rawValue: 300))
        yearL.textColor = .label
        yearL.adjustsFontForContentSizeCategory = false
        
        monthL.textAlignment = .center
        monthL.font = .systemFont(ofSize: 16, weight: UIFont.Weight(rawValue: 300))
        monthL.textColor = .label
        monthL.adjustsFontForContentSizeCategory = false
        
        
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
            fireCountL.text = "0"
        }
        
        emsCountL.textAlignment = .center
        emsCountL.font = .systemFont(ofSize: 16, weight: UIFont.Weight(rawValue: 300))
        emsCountL.textColor = .label
        emsCountL.adjustsFontForContentSizeCategory = false
        if emsCountL.text == nil {
            emsCountL.text = "0"
        }
        
        rescueCountL.textAlignment = .center
        rescueCountL.font = .systemFont(ofSize: 16, weight: UIFont.Weight(rawValue: 300))
        rescueCountL.textColor = .label
        rescueCountL.adjustsFontForContentSizeCategory = false
        
        if rescueCountL.text == nil {
            rescueCountL.text = "0"
        }
        
        let backImage = UIImage(systemName: "arrow.left.circle")
        let forwardImage = UIImage(systemName: "arrow.right.circle")
        
        if backImage != nil {
        backB.setImage(backImage, for: .normal)
        }
        
        if forwardImage != nil {
            forewardB.setImage(forwardImage, for: .normal)
        }
        
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
        
        yearL.leadingAnchor.constraint(equalTo: backB.trailingAnchor, constant: 10),
        yearL.trailingAnchor.constraint(equalTo: forewardB.leadingAnchor, constant: -10),
        yearL.centerYAnchor.constraint(equalTo: backB.centerYAnchor),
        yearL.heightAnchor.constraint(equalToConstant: 25),
        
        monthL.leadingAnchor.constraint(equalTo: backB.trailingAnchor, constant: 10),
        monthL.trailingAnchor.constraint(equalTo: forewardB.leadingAnchor, constant: -10),
        monthL.topAnchor.constraint(equalTo: yearL.bottomAnchor, constant: 10),
        monthL.heightAnchor.constraint(equalToConstant: 25),
        
        emsL.centerXAnchor.constraint(equalTo: theBackgroundView.centerXAnchor),
        emsL.topAnchor.constraint(equalTo: monthL.bottomAnchor, constant: 10),
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
        incrementCount -= 1
        forewardB.isHidden = false
        let count: EachMonthsTotal!
        if incrementCount == 0 {
            backB.isHidden = true
        }
        count = theCountsForTheButtons[incrementCount]
        let monthInt = count.month
        let month = monthName(monthNumber: monthInt)
        monthL.text = "\(month)'s Totals"
        let yearInt = count.year
        yearL.text = "\(yearInt)"
        let fire = count.fire
        let ems = count.ems
        let rescue = count.rescue
        fireCountL.text = String(fire)
        emsCountL.text = String(ems)
        rescueCountL.text = String(rescue)
    }
    
    @objc func forewardButtonTapped(_ sender: UIButton) {
        incrementCount += 1
       backB.isHidden = false
       let count: EachMonthsTotal!
       if incrementCount == proactiveCount {
           forewardB.isHidden = true
       }
       count = theCountsForTheButtons[incrementCount]
       let yearInt = count.year
       yearL.text = "\(yearInt)"
       let monthInt = count.month
       let month = monthName(monthNumber: monthInt)
       monthL.text = "\(month)'s Totals"
       let fire = count.fire
       let ems = count.ems
       let rescue = count.rescue
       fireCountL.text = String(fire)
       emsCountL.text = String(ems)
       rescueCountL.text = String(rescue)
    }
    
    func monthName(monthNumber: Int) -> String {
        var name: String = ""
        switch monthNumber {
        case 1:
            name = "January"
        case 2:
            name = "February"
        case 3:
            name = "March"
        case 4:
            name = "April"
        case 5:
            name = "May"
        case 6:
            name = "June"
        case 7:
            name = "July"
        case 8:
            name = "August"
        case 9:
            name = "September"
        case 10:
            name = "October"
        case 11:
            name = "November"
        case 12:
            name = "December"
        default: break
        }
        return name
    }
    
}


