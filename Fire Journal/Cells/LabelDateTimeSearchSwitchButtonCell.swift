//
//  LabelDateTimeSearchSwitchButtonCell.swift
//  dashboard
//
//  Created by DuRand Jones on 8/31/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol LabelDateTimeSearchSwitchButtonCellDelegate: AnyObject {
    func textEditing()
    func theTextIsFinishedEditing()
    func theTimeButtonWasTapped()
    func theSearchSwitchWasTapped()
}

class LabelDateTimeSearchSwitchButtonCell: UITableViewCell,UITextFieldDelegate {
    
    //    MARK: -objects
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var descriptionTF: UITextField!
    @IBOutlet weak var clockB: UIButton!
    @IBOutlet weak var defaultOvertimeL: UILabel!
    @IBOutlet weak var defaultOvertimeSwitch: UISwitch!
    //    MARK: -properties
    var defaultOrNot: Bool = false
    var myShift: MenuItems!
    var switchType: SwitchTypes!
    weak var delegate:LabelDateTimeSearchSwitchButtonCellDelegate? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //    MARK: -text field delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        print(text)
        delegate?.textEditing()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        print(text)
        delegate?.theTextIsFinishedEditing()
    }
    
    //    MARK: -button actions
    @IBAction func clockBTapped(_ sender: Any) {
        delegate?.theTimeButtonWasTapped()
    }
    @IBAction func theTimeSwitchTapped(_ sender: Any) {
        if defaultOvertimeSwitch.isOn {
            defaultOrNot = false
            defaultOvertimeL.text = "Search"
        } else {
            defaultOrNot = true
            defaultOvertimeL.text = "Off"
        }
        delegate?.theSearchSwitchWasTapped()
    }
    
}
