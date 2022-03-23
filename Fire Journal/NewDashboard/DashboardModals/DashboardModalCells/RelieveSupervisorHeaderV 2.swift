//
//  RelieveSupervisorHeaderV.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/3/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol RelieveSupervisorHeaderVDelegate: AnyObject {
    func relieveSupervisorInfoTapped()
    func relieveSupervisorAddNewMember(member: String)
    func relieveSupervisorAddFromContacts()
    func relieveSupervisorCancelTapped()
    func relieveSupervisorSaveTapped(member: String)
    func relieveSupervisorTextEditing(text: String)
}

class RelieveSupervisorHeaderV: UIView {

//    MARK: -PROPERTIES-
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backgroundV: UIImageView!
    @IBOutlet weak var iconIV: UIImageView!
    @IBOutlet weak var relieveSupervisorCancelB: UIButton!
    @IBOutlet weak var relieveSupervisorSaveB: UIButton!
    @IBOutlet weak var relieveSupervisorSubjectL: UILabel!
    @IBOutlet weak var relieveSupervisorNewMemberNameTF: UITextField!
    @IBOutlet weak var relieveSupervisorInfoB: UIButton!
    @IBOutlet weak var relieveSupervisorAddB: UIButton!
    @IBOutlet weak var relieveSupervisorAddContact: UIButton!
    
//    MARK: -OBJECTS-
    weak var delegate: RelieveSupervisorHeaderVDelegate? = nil
    var member: String = ""
    
//    MARK: -BUTTON ACTIONS-
    @IBAction func relieveSupervisorCancelBTapped(_ sender: Any) {
        delegate?.relieveSupervisorCancelTapped()
    }
    @IBAction func relieveSupervisorSaveBTapped(_ sender: Any) {
        delegate?.relieveSupervisorSaveTapped(member: member)
    }
    @IBAction func relieveSupervisorInfoBTapped(_ sender: Any) {
        delegate?.relieveSupervisorInfoTapped()
    }
    @IBAction func relieveSupervisorAddMemberBTapped(_ sender: Any) {
        self.resignFirstResponder()
        _ = self.textFieldShouldEndEditing(relieveSupervisorNewMemberNameTF)
        delegate?.relieveSupervisorAddNewMember(member: member)
        relieveSupervisorNewMemberNameTF.text = ""
    }
    @IBAction func relieveSupervisorAddContactBTapped(_ sender: Any) {
        delegate?.relieveSupervisorAddFromContacts()
    }
    
}

extension RelieveSupervisorHeaderV: UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            member = text
        }
        return true
    }
}
