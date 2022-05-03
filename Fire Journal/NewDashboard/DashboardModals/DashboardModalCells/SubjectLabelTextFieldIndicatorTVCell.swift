//
//  SubjectLabelTextFieldIndicatorTVCell.swift
//  DashboardTest
//
//  Created by DuRand Jones on 1/28/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol SubjectLabelTextFieldIndicatorTVCellDelegate: AnyObject {
    func theTextFieldWasEdited(theText: String, tag: Int)
    func getTheContacts(tag: Int)
}

class SubjectLabelTextFieldIndicatorTVCell: UITableViewCell {
    
    weak var delegate: SubjectLabelTextFieldIndicatorTVCellDelegate? = nil

//    MARK: -PROPERTIES-
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var subjectTF: UITextField!
    @IBOutlet weak var indicatorB: UIButton!
    @IBOutlet weak var contactsB: UIButton!
    
    private var theValue: String = ""
    var textFieldValue: String = "" {
        didSet {
            self.theValue = self.textFieldValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func indicatorBTapped(_ sender: Any) {
        
    }
    
    @IBAction func contactsBTapped(_ sender: Any) {
        delegate?.getTheContacts(tag: self.tag)
    }
    
}

extension SubjectLabelTextFieldIndicatorTVCell: UITextFieldDelegate {
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let text = textField.text {
            textFieldValue = text
            delegate?.theTextFieldWasEdited(theText: theValue, tag: self.tag)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            textFieldValue = text
            delegate?.theTextFieldWasEdited(theText: theValue, tag: self.tag)
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            textFieldValue = text
            delegate?.theTextFieldWasEdited(theText: theValue, tag: self.tag)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

