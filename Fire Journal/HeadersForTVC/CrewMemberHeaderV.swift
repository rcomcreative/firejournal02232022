//
//  CrewMemberHeaderV.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/23/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol CrewMemberHeaderVDelegate: AnyObject {
    func addNewMemberBTapped(crew:String)
    func getTheContactsList()
}

class CrewMemberHeaderV: UIView, UITextFieldDelegate {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var colorV: UIView!
    @IBOutlet weak var subjetL: UILabel!
    @IBOutlet weak var descriptionTV: UITextView!
    @IBOutlet weak var contactsB: UIButton!
    @IBOutlet weak var addContactB: UIButton!
    @IBOutlet weak var newTeamMemberTF: UITextField!
    weak var delegate:CrewMemberHeaderVDelegate? = nil
    var crewMember:String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func addMemberBTapped(_ sender: Any) {
        crewMember = newTeamMemberTF.text ?? ""
        delegate?.addNewMemberBTapped(crew: crewMember)
        newTeamMemberTF.text = ""
    }
    @IBAction func findContactsBTapped(_ sender: Any) {
        delegate?.getTheContactsList()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        crewMember = textField.text ?? ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        crewMember = textField.text ?? ""
    }
}
