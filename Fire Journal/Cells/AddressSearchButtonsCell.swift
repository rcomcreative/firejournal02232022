//
//  AddressSearchButtonsCell.swift
//  dashboard
//
//  Created by DuRand Jones on 8/31/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol AddressSearchButtonsCellDelegate: AnyObject {
    func theSearchLocationTapped()
    func theSearchMapTapped()
    func theSearchAddressSwitchTapped()
    func theSearchTextIsEditing(text: String)
    func theSearchTextIsFinished(text: String)
}

class AddressSearchButtonsCell: UITableViewCell,UITextFieldDelegate {
    //    MARK: -objects
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var addressL: UITextField!
    @IBOutlet weak var cityL: UITextField!
    @IBOutlet weak var stateL: UITextField!
    @IBOutlet weak var zipL: UITextField!
    @IBOutlet weak var locationB: UIButton!
    @IBOutlet weak var mapB: UIButton!
    @IBOutlet weak var defaultOvertimeL: UILabel!
    @IBOutlet weak var defaultOvertimeSwitch: UISwitch!
    
    
    //    MARK: -properties
    var defaultOrNot:Bool = false
    var myShift: MenuItems!
    var switchType: SwitchTypes!
    weak var delegate:AddressSearchButtonsCellDelegate? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //    MAKR: -text field delegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        print(text)
        delegate?.theSearchTextIsEditing(text: text)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        print(text)
        delegate?.theSearchTextIsFinished(text: text)
    }
    
    //    MARK: -button actions
    @IBAction func theSearchLocationBTapped(_ sender: Any) {
        delegate?.theSearchLocationTapped()
    }
    @IBAction func theSearchMapBTapped(_ sender: Any) {
        delegate?.theSearchMapTapped()
    }
    @IBAction func theSearchAddressBTapped(_ sender: Any) {
        if defaultOvertimeSwitch.isOn {
            defaultOrNot = false
            defaultOvertimeL.text = "Search"
        } else {
            defaultOrNot = true
            defaultOvertimeL.text = "Off"
        }
        delegate?.theSearchAddressSwitchTapped()
    }
    
    
}
