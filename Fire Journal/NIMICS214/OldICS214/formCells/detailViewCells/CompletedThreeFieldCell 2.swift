//
//  CompletedThreeFieldCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 8/31/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol CompletedThreeFieldCellDelgate: AnyObject {
    func nameTextFieldEdited(string:String, indexPath:IndexPath)
    func positionTextFieldEdited(position:String, indexPath:IndexPath)
    func agencyTextFieldEdited(agency:String, indexPath:IndexPath)
}

class CompletedThreeFieldCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var inputTestFieldOne: UITextField!
    @IBOutlet weak var inputTextFieldTwo: UITextField!
    @IBOutlet weak var inputTextFieldThree: UITextField!
    var resources = [ResourceAttendee]()
    var indexPath = IndexPath(item: 0, section: 0)
    
    var inputTextOne: String!
    var inputTextTwo: String!
    var inputTextThree: String!
    
    weak var delegate:CompletedThreeFieldCellDelgate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        resources = []
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("hey")
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == inputTestFieldOne {
            if let input:String = inputTestFieldOne.text {
                delegate?.nameTextFieldEdited(string: input, indexPath:indexPath)
            }
        }
        if textField == inputTextFieldTwo {
            if let input:String = inputTextFieldTwo.text {
                print(input)
                print(indexPath)
                delegate?.positionTextFieldEdited(position: input, indexPath:indexPath)
            }
        }
        if textField == inputTextFieldThree {
            if let input:String = inputTextFieldThree.text {
                delegate?.agencyTextFieldEdited(agency: input, indexPath:indexPath)
            }
        }
        return true
    }
    
    func configureWithResource(_ resource: ResourceAttendee) {
        inputTestFieldOne.text = resource.name
        inputTextFieldTwo.text = resource.icsPosition
        inputTextFieldThree.text = resource.homeAgency
        var phone:String = ""
        var name:String = ""
        var email:String = ""
        var icsPosition:String = ""
        var homeAgency:String = ""
        var guid:String = ""
        if (resource.name) != nil {
            name = resource.name!
        }
        if resource.phone != nil {
            phone = resource.phone!
        }
        if resource.email != nil {
            email = resource.email!
        }
        if resource.homeAgency != nil {
            homeAgency = resource.homeAgency!
        }
        if resource.icsPosition != nil {
            icsPosition = resource.icsPosition!
        }
        if resource.guid != nil {
            guid = resource.guid!
        }
        let selected = ResourceAttendee.init(name: name, email: email, phone: phone, icsPosition: icsPosition, homeAgency: homeAgency, guid: guid)
        resources.append(selected!)
        
    }
    
}
