//
//  DatePickerCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 9/5/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

@objc protocol DatePickerCellDelegate: AnyObject {
    @objc optional func chosenFromDate(date: Date)
    @objc optional func chosenToDate(date: Date)
    @objc optional func chosenActivityDate(date: Date)
    @objc optional func chosenSignatureDate(date: Date)
    @objc optional func chosenIncidentDate(date: Date)
}
protocol DatePickerDelegate: AnyObject {
    func alarmTimeChosenDate(date:Date,incidentType:IncidentTypes)
    func arrivalTimeChosenDate(date:Date,incidentType:IncidentTypes)
    func controlledTimeChosenDate(date:Date,incidentType:IncidentTypes)
    func lastUnitTimeChosenDate(date:Date,incidentType:IncidentTypes)
    func nfirsSecMOfficersChosenDate(date:Date,incidentType:IncidentTypes)
    func nfirsSecMMembersChosenDate(date:Date,incidentType:IncidentTypes)
}

class DatePickerCell: UITableViewCell {
    @IBOutlet weak var datePicker: UIDatePicker!
    var type:Bool!
    var activity:String!
    private var pickedDate: Date!
    var pickerDate:Date! {
        didSet {
            self.pickedDate = self.pickerDate
        }
    }
    var incidentType:IncidentTypes = .fire
    @IBOutlet weak var dateHolderV: UIView!
    
    weak var delegate: DatePickerCellDelegate? = nil
    weak var delegate2: DatePickerDelegate? = nil
    
    @IBAction func theDatePicked(_ sender: UIDatePicker, forEvent event: UIEvent) {
        pickerDate = datePicker.date
               switch incidentType {
               case .alarm:
                   delegate2?.alarmTimeChosenDate(date: pickerDate, incidentType: incidentType)
               case .arrival:
                   delegate2?.arrivalTimeChosenDate(date: pickerDate, incidentType: incidentType)
               case .controlled:
                   delegate2?.controlledTimeChosenDate(date: pickerDate, incidentType: incidentType)
               case .lastunitstanding:
                   delegate2?.lastUnitTimeChosenDate(date: pickerDate, incidentType: incidentType)
               case .nfirsSecMOfficersDate:
                   delegate2?.nfirsSecMOfficersChosenDate(date: pickerDate, incidentType: incidentType)
               case .nfirsSecMMembersDate:
                   delegate2?.nfirsSecMMembersChosenDate(date: pickerDate, incidentType: incidentType)
               default:
                   delegate?.chosenToDate!(date: pickerDate)
               }
    }
    
    @IBAction func datePicked(_ sender: Any) {
        pickerDate = datePicker.date
        switch incidentType {
        case .alarm:
            delegate2?.alarmTimeChosenDate(date: pickerDate, incidentType: incidentType)
        case .arrival:
            delegate2?.arrivalTimeChosenDate(date: pickerDate, incidentType: incidentType)
        case .controlled:
            delegate2?.controlledTimeChosenDate(date: pickerDate, incidentType: incidentType)
        case .lastunitstanding:
            delegate2?.lastUnitTimeChosenDate(date: pickerDate, incidentType: incidentType)
        case .nfirsSecMOfficersDate:
            delegate2?.nfirsSecMOfficersChosenDate(date: pickerDate, incidentType: incidentType)
        case .nfirsSecMMembersDate:
            delegate2?.nfirsSecMMembersChosenDate(date: pickerDate, incidentType: incidentType)
        default:
            delegate?.chosenToDate!(date: pickerDate)
        }
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        datePicker.datePickerMode = .dateAndTime
        if pickerDate == nil {
            pickerDate = Date()
        }
        datePicker.date = pickerDate
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
