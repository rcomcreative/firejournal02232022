//
//  LabelAnswerSwitchCell.swift
//  dashboard
//
//  Created by DuRand Jones on 8/18/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol LabelAnswerSwitchCellDelegate: AnyObject {
    func defaultOvertimeSwitchTapped(switched:Bool,type:MenuItems,switchType: SwitchTypes)
    func answerLEditing(text: String, myShift: MenuItems, switchType: SwitchTypes)
    func answerLDidEndEditing(text: String, switchType: SwitchTypes)
}

class LabelAnswerSwitchCell: UITableViewCell, UITextFieldDelegate {
    //    MARK: -cell objects
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var descriptionL: UILabel!
    @IBOutlet weak var answerL: UITextField!
    @IBOutlet weak var defaultOvertimeL: UILabel!
    @IBOutlet weak var defaultOvertimeSwitch: UISwitch!
    //    MARK: -cell properties
    weak var delegate:LabelAnswerSwitchCellDelegate? = nil
    var switched:Bool = false
    var myShift: MenuItems! = nil
    var switchType: SwitchTypes! = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func overtimeDefaultSwitched(_ sender: Any) {
        if switched {
            switched = false
        } else {
            switched = true
        }
        delegate?.defaultOvertimeSwitchTapped(switched:switched,type: myShift,switchType: switchType)
    }
    
    //    MARK: -textFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        delegate?.answerLEditing(text: text, myShift: myShift, switchType: switchType)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print(textField.text ?? "nothing to see here")
        let text = textField.text ?? ""
        delegate?.answerLDidEndEditing(text: text, switchType: switchType)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let input:String = answerL.text {
            delegate?.answerLEditing(text: input, myShift: myShift, switchType: switchType)
        }
        return true
    }
    
    
}
