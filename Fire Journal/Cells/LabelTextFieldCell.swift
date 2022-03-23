//
//  LabelTextFieldCell.swift
//  dashboard
//
//  Created by DuRand Jones on 8/18/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol LabelTextFieldCellDelegate: AnyObject {
    func incidentLabelTFEditing(text:String, myShift: MenuItems, type: IncidentTypes)
    func incidentLabelTFFinishedEditing(text:String,myShift:MenuItems, type: IncidentTypes)
    func labelTextFieldEditing(text: String, myShift: MenuItems)
    func labelTextFieldFinishedEditing(text: String, myShift: MenuItems)
    func userInfoTextFieldEditing(text:String, myShift: MenuItems, journalType: JournalTypes )
    func userInfoTextFieldFinishedEditing(text:String, myShift: MenuItems, journalType: JournalTypes )
}

class LabelTextFieldCell: UITableViewCell, UITextFieldDelegate {
    
    //    MARK: -objects
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var descriptionTF: UITextField!
    //    MARK: -Properies
    weak var delegate:LabelTextFieldCellDelegate? = nil
    private var myShift: MenuItems = MenuItems.journal
    
    var theShift: MenuItems? {
        didSet {
            self.myShift = self.theShift ?? MenuItems.journal
            if myShift == MenuItems.incidents {
                self.descriptionTF.keyboardType = .numbersAndPunctuation
            }
        }
    }
    var journalType:JournalTypes!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //    MARK: -textFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if myShift == .incidents {
            self.descriptionTF.keyboardType = .namePhonePad
            self.descriptionTF.reloadInputViews()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch myShift {
        case .incidents:
            descriptionTF.keyboardType = .numberPad
        default:
            descriptionTF.keyboardType = .emailAddress
        }
        let text = textField.text ?? ""
        if journalType == nil {
            delegate?.labelTextFieldEditing(text: text, myShift: myShift)
        } else {
        switch journalType {
        case .userInfo:
            delegate?.userInfoTextFieldEditing(text:text, myShift: myShift, journalType: journalType )
        case .fireStation:
            delegate?.userInfoTextFieldEditing(text:text, myShift: myShift, journalType: journalType )
        default:
            print("no")
        }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        if journalType == nil {
            delegate?.labelTextFieldFinishedEditing(text: text, myShift: myShift)
        } else {
            switch journalType {
            case .userInfo?:
                delegate?.userInfoTextFieldFinishedEditing(text:text, myShift: myShift, journalType: journalType )
            case .fireStation?:
                delegate?.userInfoTextFieldFinishedEditing(text:text, myShift: myShift, journalType: journalType )
            default:
                print("no")
            }
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let text = textField.text ?? ""
        if journalType == nil {
            delegate?.labelTextFieldFinishedEditing(text: text, myShift: myShift)
        }
        return true
    }
    
}
