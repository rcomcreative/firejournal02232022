//
//  LabelNumberFieldCell.swift
//  dashboard
//
//  Created by DuRand Jones on 11/3/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol LabelNumberFieldCellDelegate: AnyObject {
    func numberFieldEdited(text:String)
    func numberFieldDoneEditing(text:String)
}

class LabelNumberFieldCell: UITableViewCell,UITextFieldDelegate {
    @IBOutlet weak var numericalTF: UITextField!
    @IBOutlet weak var subjectL: UILabel!
    
    weak var delegate:LabelNumberFieldCellDelegate? = nil
    var myShift: MenuItems! = nil
    var journalType:JournalTypes!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        numericalTF.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        delegate?.numberFieldDoneEditing(text: text)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        delegate?.numberFieldEdited(text: text)
    }
    
}
