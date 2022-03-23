//
//  CrewMemberEditCellTableViewCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/23/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol CrewMemberEditCellDelegate: AnyObject {
    func theCrewSaveButtonTapped(_ modelID: NSManagedObjectID, attendee: UserAttendees, textOne: String, textTwo: String, textThree: String, textFour: String, textFive: String)
}

class CrewMemberEditCellTableViewCell: UITableViewCell,UITextFieldDelegate {
    
    @IBOutlet weak var labelOneL: UILabel!
    @IBOutlet weak var labelTwoL: UILabel!
    @IBOutlet weak var labelThreeL: UILabel!
    @IBOutlet weak var labelFourL: UILabel!
    @IBOutlet weak var labelFiveL: UILabel!
    
    @IBOutlet weak var textOneTF: UITextField!
    @IBOutlet weak var textTwoTF: UITextField!
    @IBOutlet weak var textThreeTF: UITextField!
    @IBOutlet weak var textFourTF: UITextField!
    @IBOutlet weak var textFiveTF: UITextField!
    
    @IBOutlet weak var editB: UIButton!
    @IBOutlet weak var saveB: UIButton!
    
    var modelID:NSManagedObjectID!
    var text1:String = ""
    var text2:String = ""
    var text3:String = ""
    var text4:String = ""
    var text5:String = ""
    weak var delegate:CrewMemberEditCellDelegate? = nil
    var attendee:UserAttendees!
    
    @IBAction func editBTapped(_ sender: Any) {
        saveB.isHidden = false
        saveB.alpha = 1.0
        textOneTF.isUserInteractionEnabled = true
        textTwoTF.isUserInteractionEnabled = true
        textThreeTF.isUserInteractionEnabled = true
        textFourTF.isUserInteractionEnabled = true
        textFiveTF.isUserInteractionEnabled = true
        textOneTF.isEnabled = true
        textTwoTF.isEnabled = true
        textThreeTF.isEnabled = true
        textFourTF.isEnabled = true
        textFiveTF.isEnabled = true
        editB.isHidden = true
        editB.alpha = 0.0
        textFiveTF.setNeedsDisplay()
    }
    
    @IBAction func saveBTapped(_ sender: Any) {
        _ = textFieldShouldEndEditing(textFiveTF)
        
        delegate?.theCrewSaveButtonTapped(modelID, attendee: attendee, textOne: text1, textTwo: text2, textThree: text3, textFour: text4, textFive: text5)
        
        textOneTF.isUserInteractionEnabled = false
        textTwoTF.isUserInteractionEnabled = false
        textThreeTF.isUserInteractionEnabled = false
        textFourTF.isUserInteractionEnabled = false
        textFiveTF.isUserInteractionEnabled = false
        textOneTF.isEnabled = false
        textTwoTF.isEnabled = false
        textThreeTF.isEnabled = false
        textFourTF.isEnabled = false
        textFiveTF.isEnabled = false
        saveB.isHidden = true
        saveB.alpha = 0.0
        editB.isHidden = false
        editB.alpha = 1.0
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        saveB.isHidden = true
        saveB.alpha = 0.0
        editB.isHidden = false
        editB.alpha = 1.0
        textOneTF.tag = 1
        textTwoTF.tag = 2
        textThreeTF.tag = 3
        textFourTF.tag = 4
        textFiveTF.tag = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

//        accessoryType = selected ? .checkmark : .none
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let tag = textField.tag
        switch tag {
        case 1:
            text1 = textField.text ?? ""
        case 2:
            text2 = textField.text ?? ""
        case 3:
            text3 = textField.text ?? ""
        case 4:
            text4 = textField.text ?? ""
        case 5:
            text5 = textField.text ?? ""
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let tag = textField.tag
        switch tag {
        case 1:
            text1 = textField.text ?? ""
        case 2:
            text2 = textField.text ?? ""
        case 3:
            text3 = textField.text ?? ""
        case 4:
            text4 = textField.text ?? ""
        case 5:
            text5 = textField.text ?? ""
        default:
            break
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let tag = textField.tag
        switch tag {
        case 1:
            text1 = textField.text ?? ""
        case 2:
            text2 = textField.text ?? ""
        case 3:
            text3 = textField.text ?? ""
        case 4:
            text4 = textField.text ?? ""
        case 5:
            text5 = textField.text ?? ""
        default:
            break
        }
        return true
    }
    
}
