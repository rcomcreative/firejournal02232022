//
//  TextFieldInputCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 8/31/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit


protocol TextFieldInputCellDelegate: AnyObject {

    func singleTextFieldInput(type: ValueType, input: String )
    func singleTextFieldInputWithForm(type: Form, input: String )
}

class TextFieldInputCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var inputLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    var formField: String!
    var value: ValueType!
    var aForm: String = ""
    var form: Form!
    
    weak var delegate: TextFieldInputCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let input:String = inputTextField.text {
            if aForm == "" {
                delegate?.singleTextFieldInput(type: value, input: input )
            } else {
                delegate?.singleTextFieldInputWithForm(type: form, input: input)
            }
        }
        return true
    }
    
}
