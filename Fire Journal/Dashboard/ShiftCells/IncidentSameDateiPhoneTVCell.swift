//
//  IncidentSameDateiPhoneTVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/20/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation

protocol IncidentSameDateiPhoneTVCellDelegate: AnyObject {
    func incidentSameDateiPhoneChosen(_ date: Date, index: IndexPath, sameDate: Bool)
}

class IncidentSameDateiPhoneTVCell: UITableViewCell {

    @IBOutlet weak var dateHolderVleading1: NSLayoutConstraint!
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateHolderV: UIView!
    @IBOutlet weak var timeL: UILabel!
    @IBOutlet weak var sameAsAlarmL: UILabel!
    @IBOutlet weak var sameAsAlarmSwitch: UISwitch!
    
    weak var delegate: IncidentSameDateiPhoneTVCellDelegate? = nil
    
    var theSameDate: Bool = true
    var sameDate: Bool = true {
        didSet {
            self.theSameDate = self.sameDate
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if chosenDate != nil {
            datePicker.date = chosenDate
            
        } else {
            datePicker.date = Date()
        }
        sameAsAlarmSwitch.isOn = theSameDate
        dateFormatter.dateFormat = "EEE MMM, dd, YYYY HH:mm:ss"
    }
    
    var chosenDate: Date!
    var index: IndexPath!
    let dateFormatter = DateFormatter.init()
    
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
            datePicker.date = date1
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
        sameAsAlarmSwitch.setNeedsDisplay()
        sameDate = false
        self.dateFormatter.dateFormat = "EEE MMM, dd, YYYY HH:mm:ss"
        let dateString = self.dateFormatter.string(from: self.theFirstDose)
        self.timeL.text = dateString + "HR"
        delegate?.incidentSameDateiPhoneChosen(theFirstDose, index: index, sameDate: sameDate)
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
