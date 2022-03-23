//
//  startShiftOvertimeSwitchCell.swift
//  dashboard
//
//  Created by DuRand Jones on 8/17/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol StartShiftOvertimeSwitchDelegate: AnyObject {
    func switchTapped(type: String, startOrEnd: Bool, myShift: MenuItems)
}

class startShiftOvertimeSwitchCell: UITableViewCell {
    
    //    MARK: -Objects
    @IBOutlet weak var amOrOvertimeL: UILabel!
    @IBOutlet weak var amOrOvertimeSwitch: UISwitch!
    // MARK: Properties
    var myShift: MenuItems = .journal
    var startOrEndB: Bool = false
    //    MARK: -Delegate
    weak var delegate: StartShiftOvertimeSwitchDelegate? = nil
    
    @IBAction func switchTapped(_ sender: Any) {
        var type: String = ""
        if amOrOvertimeSwitch.isOn {
            switch myShift {
            case .incidents:
                amOrOvertimeL.text = "Emergency"
                type = "Emergency"
            case .journal:
                amOrOvertimeL.text = "Public"
                type = "Public"
            case .nfirsBasic1Search:
                amOrOvertimeL.text = "Completed"
                type = "Completed"
            case .startShift:
                amOrOvertimeL.text = "AM Relief"
                type = "AM Relief"
            case .updateShift:
                amOrOvertimeL.text = "Move Up"
                type = "Move Up"
            case .endShift:
                amOrOvertimeL.text = "AM Relief"
                type = "AM Relief"
            case .alarmSearch:
                amOrOvertimeL.text = "Completed"
                type = "Completed"
            case .ics214Search:
                amOrOvertimeL.text = "Completed"
                type = "Completed"
            default:
                amOrOvertimeL.text = ""
                type = ""
            }
            startOrEndB = true
        } else {
            switch myShift {
            case .incidents:
                amOrOvertimeL.text = "Non-Emergency"
                type = "Non-Emergency"
            case .journal:
                amOrOvertimeL.text = "Private"
                type = "Private"
            case .nfirsBasic1Search:
                amOrOvertimeL.text = "Incomplete"
                type = "Incomplete"
            case .startShift:
                amOrOvertimeL.text = "Overtime"
                type = "Overtime"
            case .updateShift:
                amOrOvertimeL.text = "Overtime"
                type = "Overtime"
            case .endShift:
                amOrOvertimeL.text = "Overtime"
                type = "Overtime"
            case .alarmSearch:
                amOrOvertimeL.text = "Incomplete"
                type = "Completed"
            case .ics214Search:
                amOrOvertimeL.text = "Incomplete"
                type = "Completed"
            default:
                amOrOvertimeL.text = ""
                type = ""
            }
            startOrEndB = false
        }
        delegate?.switchTapped(type: type, startOrEnd: startOrEndB, myShift: myShift)
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
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
