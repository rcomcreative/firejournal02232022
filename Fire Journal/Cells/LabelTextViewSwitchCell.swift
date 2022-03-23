//
//  LabelTextViewSwitchCell.swift
//  dashboard
//
//  Created by DuRand Jones on 8/18/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol LabelTextViewSwitchCellDelegate: AnyObject {
    func labelTextViewSwitchCellSwitchTapped(switched: Bool, switchType: SwitchTypes, type: MenuItems)
    func textViewEdited(text: String, switchType: SwitchTypes, myShift: MenuItems)
    func textViewDidEndEditing(text: String, switchType: SwitchTypes, myShift: MenuItems)
}

class LabelTextViewSwitchCell: UITableViewCell, UITextViewDelegate {
    //    MARK: -Objects
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var descriptionL: UILabel!
    @IBOutlet weak var switchL: UILabel!
    @IBOutlet weak var defaultOvertimeSwitch: UISwitch!
    @IBOutlet weak var answerTV: UITextView!
    //    MARK: -properties
    weak var delegate:LabelTextViewSwitchCellDelegate? = nil
    var switched:Bool = false
    var myShift: MenuItems! = nil
    var switchType: SwitchTypes! = nil
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        answerTV.layer.borderColor = UIColor.lightGray.cgColor
        answerTV.layer.borderWidth = 0.5
        answerTV.layer.cornerRadius = 8.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //    MARK: -switch acction
    @IBAction func switchHasBeenTapped(_ sender: Any) {
        if switched {
            switched = false
        } else {
            switched = true
        }
        delegate?.labelTextViewSwitchCellSwitchTapped(switched: switched, switchType: switchType,type: myShift)
    }
    
    
    //    MARK: -text view delegate
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text ?? ""
        delegate?.textViewEdited(text: text, switchType: switchType, myShift: myShift)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        let text = textView.text ?? ""
        delegate?.textViewDidEndEditing(text: text, switchType: switchType, myShift: myShift)
    }
    
}
