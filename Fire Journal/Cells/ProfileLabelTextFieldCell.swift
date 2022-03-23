//
//  ProfileLabelTextFieldCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/14/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol ProfileLabelTextDelegate: AnyObject {
    func profileTextFieldDidBeginEditing(text:String,fju:String)
    func profileTextFieldDidEndEdit(text:String,fju:String)
}

class ProfileLabelTextFieldCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var descriptionTF: UITextField!
    weak var delegate:ProfileLabelTextDelegate? = nil
    var fju:String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    //    MARK: -textFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        delegate?.profileTextFieldDidBeginEditing(text: text,fju:fju)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        delegate?.profileTextFieldDidEndEdit(text: text,fju:fju)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let text = textField.text ?? ""
        delegate?.profileTextFieldDidEndEdit(text: text,fju:fju)
        return true
    }
    
}
