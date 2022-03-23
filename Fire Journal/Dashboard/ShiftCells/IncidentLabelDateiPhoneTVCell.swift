//
//  IncidentLabelDateiPhoneTVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/20/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol IncidentLabelDateiPhoneTVCellDelegate: AnyObject {
    func incidentLabelDateiPhoneThePickerTapped(_ index: IndexPath, date: Date)
}

class IncidentLabelDateiPhoneTVCell: UITableViewCell {
    
    @IBOutlet weak var dateHolderVleading1: NSLayoutConstraint!
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateHolderV: UIView!
    @IBOutlet weak var timeL: UILabel!
    
    weak var delegate: IncidentLabelDateiPhoneTVCellDelegate? = nil
    let dateFormatter = DateFormatter.init()
    var sameDate: Bool = true
    var index: IndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        datePicker.datePickerMode = .dateAndTime
        if chosenDate != nil {
            datePicker.date = chosenDate
        } else {
            datePicker.date = Date()
        }
        dateFormatter.dateFormat = "EEE MMM, dd, YYYY HH:mm:ss"
        let theDate = dateFormatter.string(from: datePicker.date)
        self.timeL.text = theDate + " HR"
    }
    
    var chosenDate: Date!
    
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
            let theDate = dateFormatter.string(from: datePicker.date)
            self.timeL.text = theDate + " HR"
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func datePickerTapped(_ sender: UIDatePicker, forEvent event: UIEvent) {
        theFirstDose = sender.date
        let theDate = dateFormatter.string(from: theFirstDose)
        self.timeL.text = theDate + " HR"
        delegate?.incidentLabelDateiPhoneThePickerTapped(index, date: theFirstDose )
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
