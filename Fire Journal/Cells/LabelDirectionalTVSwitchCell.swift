//
//  LabelDirectionalTVSwitchCell.swift
//  dashboard
//
//  Created by DuRand Jones on 8/30/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol LabelDirectionalTVSwitchCellDelegate: AnyObject {
    func tvDirectionalTapped(myShift: MenuItems)
    func tvSwitchTapped(myShift: MenuItems, defaultOvertimeB: Bool)
}

class LabelDirectionalTVSwitchCell: UITableViewCell {
    //    MARK: -objects
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var descriptionL: UILabel!
    
    @IBOutlet weak var directionalB: UIButton!
    @IBOutlet weak var descriptionTV: UITextView!
    @IBOutlet weak var defaultOvertimeL: UILabel!
    @IBOutlet weak var defaultOvertimeSwitch: UISwitch!
    //    MARK: -properties
    var defaultOvertimeB: Bool = false
    var myShift: MenuItems!
    weak var delegate: LabelDirectionalTVSwitchCellDelegate? = nil
    var switchType: SwitchTypes! = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        
        descriptionTV.layer.borderColor = UIColor.lightGray.cgColor
        descriptionTV.layer.borderWidth = 1.0
        descriptionTV.layer.cornerRadius = 8.0
        
        if defaultOvertimeB {
            defaultOvertimeL.text = "AM Relief"
        } else {
            defaultOvertimeL.text = "Overtime"
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //    MARK: -button actions
    @IBAction func directionBTapped(_ sender: Any) {
        delegate?.tvDirectionalTapped(myShift: myShift)
    }
    @IBAction func defaultOvertimeSwitchTapped(_ sender: Any) {
        if defaultOvertimeB {
            defaultOvertimeB = false
            defaultOvertimeL.text = "Overtime"
        } else {
            defaultOvertimeB = true
            defaultOvertimeL.text = "AM Relief"
        }
        delegate?.tvSwitchTapped(myShift: myShift, defaultOvertimeB: defaultOvertimeB)
    }
    
    
    
}
