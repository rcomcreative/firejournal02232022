//
//  IncidentSingleEntryCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 10/30/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit


protocol IncidentSingleEntryDelegate: AnyObject {

    func theTextFieldOnIncidentSingleEntryEndedEditing(type:ValueType, input: String )
}

class IncidentSingleEntryCell: UITableViewCell, UITextFieldDelegate {
    
    var type:ValueType!
    var input:String!

    @IBOutlet weak var incidentTitleL: UILabel!
    
    @IBOutlet weak var incidentInputTF: UITextField!
    
    weak var delegate: IncidentSingleEntryDelegate? = nil
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == incidentInputTF {
            input = incidentInputTF.text
            delegate?.theTextFieldOnIncidentSingleEntryEndedEditing(type: type, input: input)
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == incidentInputTF {
            input = incidentInputTF.text
            delegate?.theTextFieldOnIncidentSingleEntryEndedEditing(type: type, input: input)
        }
        return true
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
            incidentInputTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
