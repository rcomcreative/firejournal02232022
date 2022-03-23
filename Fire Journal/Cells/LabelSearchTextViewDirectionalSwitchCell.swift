//
//  LabelSearchTextViewDirectionalSwitchCell.swift
//  dashboard
//
//  Created by DuRand Jones on 8/31/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol LabelSearchTextViewDirectionalSwitchCellDelegate: AnyObject {
    func tvSearchTextIsEditing(text: String)
    func tvSearchTextIsDoneEditing(text: String)
    func tvSearchDirectionalTapped()
    func tvSearchSwitchTaopped()
}

class LabelSearchTextViewDirectionalSwitchCell: UITableViewCell, UITextViewDelegate{
    
    //    MARK: -objects
    @IBOutlet weak var descriptionTV: UITextView!
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var directionalB: UIButton!
    @IBOutlet weak var defaultOvertimeL: UILabel!
    @IBOutlet weak var defaultOvertimeSwitch: UISwitch!
    
    //     MARK: -properities
    var defaultOrNot: Bool = false
    var myShift: MenuItems!
    var switchType: SwitchTypes!
    weak var delegate:LabelSearchTextViewDirectionalSwitchCellDelegate? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //    MARK: -TEXT View DELEGATE
    func textViewDidBeginEditing(_ textView: UITextView) {
        let text = textView.text ?? ""
        delegate?.tvSearchTextIsEditing(text: text)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        let text = textView.text ?? ""
        delegate?.tvSearchTextIsDoneEditing(text: text)
    }
    
    //    MARK: -button actions
    @IBAction func directionalBTapped(_ sender: Any) {
        delegate?.tvSearchDirectionalTapped()
    }
    @IBAction func defaultOvertimeSwitchTapped(_ sender: Any) {
        if defaultOvertimeSwitch.isOn {
            defaultOrNot = false
            defaultOvertimeL.text = "Search"
        } else {
            defaultOrNot = true
            defaultOvertimeL.text = "Off"
        }
        delegate?.tvSearchSwitchTaopped()
    }
    
    
}
