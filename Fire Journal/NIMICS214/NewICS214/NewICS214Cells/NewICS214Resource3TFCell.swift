//
//  NewICS214Resource3TFCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/2/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData

protocol NewICS214Resource3TFCellDelegate: AnyObject {
    func theCrewMemberChanged(theCrew: UserAttendees, indexPath: IndexPath)
    func theEditButtonWasTapped(indexPath: IndexPath, crew: UserAttendees)
}

class NewICS214Resource3TFCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var icsPositionTF: UITextField!
    @IBOutlet weak var homeAgencyTF: UITextField!
    @IBOutlet weak var editB: UIButton!
    
    private var theCrew = UserAttendees()
    var crew: UserAttendees? {
        didSet {
            self.theCrew = self.crew ?? UserAttendees()
            self.nameTF.text = self.theCrew.attendee
            self.icsPositionTF.text = self.theCrew.attendeeICSPosition
            self.homeAgencyTF.text = self.theCrew.attendeeHomeAgency
        }
    }
    
    private var theIndexPath = IndexPath()
    var indexPath: IndexPath? {
        didSet {
            self.theIndexPath = indexPath ?? IndexPath()
        }
    }
    
    weak var delegate: NewICS214Resource3TFCellDelegate? = nil
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
//        editB.layer.borderColor = UIColor.lightGray.cgColor
//        editB.layer.borderWidth = 1
//        editB.layer.cornerRadius = 6
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // update UI
        accessoryType = selected ? .checkmark : .none
    }
    
    @IBAction func editBTapped(_ sender: Any) {
        delegate?.theEditButtonWasTapped(indexPath: indexPath!, crew: theCrew)
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let tag = textField.tag
        let text = textField.text ?? ""
        switch tag {
        case 1:
            theCrew.attendee = text
        case 2:
            theCrew.attendeeICSPosition = text
        case 3:
            theCrew.attendeeHomeAgency = text
        default: break
        }
        delegate?.theCrewMemberChanged(theCrew: theCrew, indexPath: theIndexPath )
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let tag = textField.tag
        let text = textField.text ?? ""
        switch tag {
        case 1:
            theCrew.attendee = text
        case 2:
            theCrew.attendeeICSPosition = text
        case 3:
            theCrew.attendeeHomeAgency = text
        default: break
        }
        delegate?.theCrewMemberChanged(theCrew: theCrew, indexPath: theIndexPath )
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
