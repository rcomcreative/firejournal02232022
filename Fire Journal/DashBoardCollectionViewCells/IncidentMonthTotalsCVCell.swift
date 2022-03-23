//
//  IncidentMonthTotalsCVCell.swift
//  DashboardTest
//
//  Created by DuRand Jones on 12/31/19.
//  Copyright © 2019 inSky LE. All rights reserved.
//

import UIKit

class IncidentMonthTotalsCVCell: UICollectionViewCell {
    @IBOutlet weak var logoIconIV: UIImageView!
    @IBOutlet weak var backgroundHeaderIV: UIImageView!
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var monthsTotalsL: UILabel!
    @IBOutlet weak var previousMonthsTotalB: UIButton!
    @IBOutlet weak var forwardMonthsTotalB: UIButton!
    @IBOutlet weak var titleOneL: UILabel!
    @IBOutlet weak var titleTwoL: UILabel!
    @IBOutlet weak var titleThreeL: UILabel!
    @IBOutlet weak var iconOneIV: UIImageView!
    @IBOutlet weak var iconTwoIV: UIImageView!
    @IBOutlet weak var iconThreeIV: UIImageView!
    @IBOutlet weak var totalOneL: UILabel!
    @IBOutlet weak var totalTwoL: UILabel!
    @IBOutlet weak var totalThreeL: UILabel!
    @IBOutlet weak var yearL: UILabel!
    
    private var yearCount: Int!
    private var thisYear: Int!
    private var thisMonth: Int!
    
    var primaryMonth: Int = 0 {
        didSet {
            self.thisMonth = self.primaryMonth
//            let month = monthName(monthNumber: self.primaryMonth)
//            self.monthsTotalsL.text = "\(month)'s Totals"
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
    
    private var fire: String!
    private var ems: String!
    private var rescue: String!
    private var primaryMonthCounts: [(Int,Int)]! {
        didSet {
            for (key,value) in self.primaryMonthCounts {
                print("primaryMonthCounts here is the key \(key) and the value \(value)")
                if key == 0 {
                    self.totalOneL.text = String(value)
                } else if key == 1 {
                    self.totalTwoL.text = String(value)
                } else if key == 2 {
                    self.totalThreeL.text = String(value)
                }
            }
        }
    }
    
    var thePrimaryMonthCounts: [(Int, Int)] = [(0,0)] {
        didSet {
            self.primaryMonthCounts = self.thePrimaryMonthCounts
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
       let monthElements: [Any] = Date().month(date: Date())
       if !monthElements.isEmpty {
           let month = monthElements[0] as! String
           monthsTotalsL.text = "\(month)'s Totals"
       }
        roundViews()
        forwardMonthsTotalB.isHidden = true
    }
    
    func roundViews() {
        self.contentView.layer.cornerRadius = 6
        self.contentView.clipsToBounds = true
        self.contentView.layer.borderColor = UIColor.systemRed.cgColor
        self.contentView.layer.borderWidth = 2
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
    
    @IBAction func previousMonthsTotalBTapped(_ sender: Any) {
        incrementCount -= 1
        forwardMonthsTotalB.isHidden = false
        let count: EachMonthsTotal!
        if incrementCount == 0 {
            previousMonthsTotalB.isHidden = true
        }
        count = theCountsForTheButtons[incrementCount]
        let monthInt = count.month
        let month = monthName(monthNumber: monthInt)
        monthsTotalsL.text = "\(month)'s Totals"
        let yearInt = count.year
        yearL.text = "\(yearInt)"
        let fire = count.fire
        let ems = count.ems
        let rescue = count.rescue
        totalOneL.text = String(fire)
        totalTwoL.text = String(ems)
        totalThreeL.text = String(rescue)
    }
    
    @IBAction func forwardMonthTotalBTapped(_ sender: Any) {
                incrementCount += 1
               previousMonthsTotalB.isHidden = false
               let count: EachMonthsTotal!
               if incrementCount == proactiveCount {
                   forwardMonthsTotalB.isHidden = true
               }
               count = theCountsForTheButtons[incrementCount]
               let yearInt = count.year
               yearL.text = "\(yearInt)"
               let monthInt = count.month
               let month = monthName(monthNumber: monthInt)
               monthsTotalsL.text = "\(month)'s Totals"
               let fire = count.fire
               let ems = count.ems
               let rescue = count.rescue
               totalOneL.text = String(fire)
               totalTwoL.text = String(ems)
               totalThreeL.text = String(rescue)
    }
    
    

}
