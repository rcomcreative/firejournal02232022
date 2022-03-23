//
//  LabelNoDescripAnswerSwitchCell.swift
//  dashboard
//
//  Created by DuRand Jones on 8/31/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol LabelNoDescripAnswerSwitchCellDelegate: AnyObject {
    func theTextIsEditing()
    func theTextHasStoppedEditing()
    func theSwitchWasTappedHere()
}

class LabelNoDescripAnswerSwitchCell: UITableViewCell, UITextFieldDelegate {
    
    //    MARK: -objects
    @IBOutlet weak var descriptionTF: UITextField!
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var defaultOvertimeL: UILabel!
    @IBOutlet weak var defaultOvertimeSwitch: UISwitch!
    //    MARK: -properties
    var defaultOrNot: Bool = false
    var myShift: MenuItems!
    var switchType: SwitchTypes!
    weak var delegate:LabelNoDescripAnswerSwitchCellDelegate? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //    MARK: -button action
    @IBAction func defaultOvertimeSwitchWasTapped(_ sender: Any) {
        if defaultOvertimeSwitch.isOn {
            defaultOrNot = false
            defaultOvertimeL.text = "Search"
        } else {
            defaultOrNot = true
            defaultOvertimeL.text = "Off"
        }
    }
    
    //    MARK: -text field delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        print(text)
        delegate?.theTextIsEditing()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        print(text)
        delegate?.theTextHasStoppedEditing()
    }
    
    
}
