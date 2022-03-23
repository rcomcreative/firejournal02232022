//
//  ContactsCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 9/11/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

/**
 # Contacts Cell Protocol
 ## Working with Crew
 * used to help build the crew
    1. contactTapped() - user wants to review contacts **used**
    1. resourceTapped() - user wants to review resources list
    1. saveTapped(array: Array<Array<String>>) - an array of selected
    1. cancelTapped()
    1. newEntryHasBegun() - text field delegation **used**
 - Authors: DuRand Jones
 - Complexity: O(1)
 */
@objc protocol ContactsCellDelegate: AnyObject {
    @objc func contactTapped()
    @objc func resourceTapped()
    @objc func saveTapped(array: Array<Array<String>>)
    @objc func cancelTapped()
    @objc func newEntryHasBegun()
}

class ContactsCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var resourceL: UILabel!
    @IBOutlet weak var resourceNameTF: UITextField!
    @IBOutlet weak var resourceAddB: UIButton!
    @IBOutlet weak var contactsAddB: UIButton!
    @IBOutlet weak var fieldOneL: UILabel!
    @IBOutlet weak var fieldTwoL: UILabel!
    @IBOutlet weak var fieldThreeL: UILabel!
    @IBOutlet weak var inputOneTF: UITextField!
    @IBOutlet weak var inputTwoTF: UITextField!
    @IBOutlet weak var inputThreeTF: UITextField!
    
    weak var delegate: ContactsCellDelegate? = nil
    
    @IBAction func addContactsTapped(_ sender: Any) {
        delegate?.contactTapped()
    }
    @IBAction func addResourceTapped(_ sender: Any) {
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
         delegate?.newEntryHasBegun()
        return true
    }
    
}
