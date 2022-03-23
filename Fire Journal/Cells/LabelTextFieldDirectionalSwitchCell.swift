//
//  LabelTextFieldDirectionalSwitchCell.swift
//  dashboard
//
//  Created by DuRand Jones on 8/18/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol LabelTextFieldDirectionalSwitchCellDelegate: AnyObject {
    func directionalButTapped(switchType: SwitchTypes, type: MenuItems )
    func defaultOvertimeDirectionalSwitchTapped(switched: Bool, type: MenuItems,switchType: SwitchTypes)
    func descriptionTextFieldDoneEditing()
}

class LabelTextFieldDirectionalSwitchCell: UITableViewCell, UITextFieldDelegate {
    
    //    MARK: -Objects
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var instructionalL: UILabel!
    @IBOutlet weak var descriptionTF: UITextField!
    @IBOutlet weak var directionalB: UIButton!
    @IBOutlet weak var defaultOvertimeL: UILabel!
    @IBOutlet weak var defaultOvertimeSwitch: UISwitch!
    //    MARK: -properties
    var defaultOrNote:Bool = false
    weak var delegate:LabelTextFieldDirectionalSwitchCellDelegate? = nil
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
    //    MARK: -BUTTON ACTION
    @IBAction func directionalBTapped(_ sender: Any) {
        delegate?.directionalButTapped(switchType: switchType, type: myShift )
    }
    //    MARK: -switch action
    @IBAction func overtimeDefaultSTapped(_ sender: Any) {
        if defaultOrNote {
            defaultOrNote = false
        } else {
            defaultOrNote = true
        }
        delegate?.defaultOvertimeDirectionalSwitchTapped(switched: defaultOrNote, type: myShift, switchType: switchType)
    }
    
    //    MARK: -textFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print(textField.text ?? "nothing to see here")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print(textField.text ?? "nothing to see here")
    }
    
    
}
