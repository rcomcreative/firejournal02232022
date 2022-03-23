//
//  IncidentSameDateAlarmTVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/21/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation

protocol IncidentSameDateAlarmTVCellDelegate: AnyObject {
    func incidentSameDateAlarmPickerTapped(_ index: IndexPath, date: Date, sameDate: Bool)
}

class IncidentSameDateAlarmTVCell: UITableViewCell {

    @IBOutlet weak var dateHolderVleading1: NSLayoutConstraint!
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateHolderV: UIView!
    @IBOutlet weak var timeL: UILabel!
    @IBOutlet weak var sameAsAlarmL: UILabel!
    @IBOutlet weak var sameAsAlarmSwitch: UISwitch!
    
    var index: IndexPath!
    weak var delegate: IncidentSameDateAlarmTVCellDelegate? = nil
    let dateFormatter = DateFormatter.init()
    var sameDate: Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if chosenDate != nil {
            datePicker.date = chosenDate
        } else {
            datePicker.date = Date()
        }
        sameAsAlarmSwitch.isOn = true
        dateFormatter.dateFormat = "EEE MMM, dd, YYYY HH:mm:ss"
    }
    
    var chosenDate: Date!
    
    var notAlarmDate: Bool = true {
        didSet {
            self.sameDate = self.notAlarmDate
        }
    }
    
    private var subject1: String = ""
    var theSubject: String = "" {
        didSet {
            self.subject1 = self.theSubject
            self.subjectL.text = self.subject1
        }
    }
    
    private var date1: Date!
    var theFirstDose = Date() {
        didSet {
            self.date1 = self.theFirstDose
            self.datePicker.date = date1
            self.dateFormatter.dateFormat = "EEE MMM, dd, YYYY HH:mm:ss"
            let dateString = self.dateFormatter.string(from: self.theFirstDose)
            self.timeL.text = dateString + "HR"
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func sameAsAlarmTapped(_ sender: Any) {
        if sameAsAlarmSwitch.isOn {
            sameDate = true
        } else {
            sameDate = false
        }
    }
    
    @IBAction func datePickerTapped(_ sender: UIDatePicker, forEvent event: UIEvent) {
        theFirstDose = sender.date
        sameAsAlarmSwitch.isOn = false
        sameDate = false
        self.dateFormatter.dateFormat = "EEE MMM, dd, YYYY HH:mm:ss"
        let dateString = self.dateFormatter.string(from: self.theFirstDose)
        self.timeL.text = dateString + "HR"
        delegate?.incidentSameDateAlarmPickerTapped(index, date: theFirstDose, sameDate: sameDate )
    }
    
    func configureDatePickersHoldingV() {
        let frame = self.dateHolderV.frame
        let width = frame.width + 100
        let height = frame.height
        let theX = frame.origin.x - 100
        self.dateHolderV.frame = CGRect(x: theX, y: frame.origin.y, width: width, height: height)
        self.dateHolderV.setNeedsDisplay()
    }
    
}
