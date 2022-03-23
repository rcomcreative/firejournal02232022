//
//  DatePickerCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 9/5/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

@objc protocol FormDatePickerCellDelegate: AnyObject {
    @objc optional func chosenFromDate(date: Date)
    @objc optional func chosenToDate(date: Date)
    @objc optional func chosenActivityDate(date: Date)
    @objc optional func chosenSignatureDate(date: Date)
    @objc optional func chosenIncidentDate(date: Date)
}

class FormDatePickerCell: UITableViewCell {
    @IBOutlet weak var datePicker: UIDatePicker!
    var type:Bool!
    var activity:String!
    var pickerDate:Date!
    @IBOutlet weak var dateHolderV: UIView!
    
    weak var delegate: FormDatePickerCellDelegate? = nil
    
    @IBAction func datePicked(_ sender: Any) {
        pickerDate = datePicker.date
        if(type) {
            delegate?.chosenFromDate!(date: pickerDate)
        } else {
            if(activity == "Activity") {
                delegate?.chosenActivityDate!(date: pickerDate)
            } else if(activity == "Signature") {
                delegate?.chosenSignatureDate!(date: pickerDate)
            } else if(activity == "Incident") {
                delegate?.chosenIncidentDate!(date: pickerDate)
            }else {
                delegate?.chosenToDate!(date: pickerDate)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        datePicker.datePickerMode = .dateAndTime
        pickerDate = Date()
        datePicker.date = pickerDate
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
