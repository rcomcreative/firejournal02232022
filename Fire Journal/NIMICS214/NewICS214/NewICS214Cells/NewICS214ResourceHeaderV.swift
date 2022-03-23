//
//  NewICS214ResourceHeaderV.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/2/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol NewICS214ResourceHeaderVDelegate: AnyObject {
    func newICS214ResourceInfoTapped()
    func newICS214ResourceAddNewMember(member: String)
    func newICS214ResourceAddFromContacts()
    func newICS214ResourceCancelTapped()
    func newICS214ResourceSaveTapped()
    func newICS214ResourceTextEditing(text: String)
}

class NewICS214ResourceHeaderV: UIView {
  
    //    MARK: -PROPERTIES-
    weak var delegate: NewICS214ResourceHeaderVDelegate? = nil
    var member: String = ""
    
    //    MARK: -OBJECTS-
    @IBOutlet weak var backgroundV: UIImageView!
    @IBOutlet weak var saveB: UIButton!
    @IBOutlet weak var cancelB: UIButton!
    @IBOutlet weak var infoB: UIButton!
    @IBOutlet weak var newMemberB: UIButton!
    @IBOutlet weak var contactsB: UIButton!
    @IBOutlet weak var newMemberTF: UITextField!
    
    //    MARK: -ACTIONS-
    @IBAction func saveBTapped(_ sender: Any) {
        delegate?.newICS214ResourceSaveTapped()
    }
    @IBAction func cancelBTapped(_ sender: Any) {
        delegate?.newICS214ResourceCancelTapped()
    }
    @IBAction func infoBTapped(_ sender: Any) {
        delegate?.newICS214ResourceInfoTapped()
    }
    @IBAction func newMemberBTapped(_ sender: Any) {
        self.resignFirstResponder()
        _ = self.textFieldShouldEndEditing(newMemberTF)
        delegate?.newICS214ResourceAddNewMember(member: member)
        newMemberTF.text = ""
    }
    @IBAction func contactsBTapped(_ sender: Any) {
        delegate?.newICS214ResourceAddFromContacts()
    }
    
    

}

extension NewICS214ResourceHeaderV: UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            member = text
        }
        return true
    }
    
}
