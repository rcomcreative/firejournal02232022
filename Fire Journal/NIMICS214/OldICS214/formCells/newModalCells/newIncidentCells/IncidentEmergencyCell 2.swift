//
//  IncidentEmergencyCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 10/30/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol IncidentEmergencyDelegate: AnyObject {
    func emergencyTapped(emergency: String)
}

class IncidentEmergencyCell: UITableViewCell {

    @IBOutlet weak var incidentEmergencySwitch: UISwitch!
    var emergency: String?
    weak var delegate: IncidentEmergencyDelegate? = nil
    
    @IBAction func emergencySwitchTapped(_ sender: Any) {
        if incidentEmergencySwitch.isOn {
            emergency = "Emergency"
        } else {
            emergency = "Non-Emergency"
        }
        delegate?.emergencyTapped(emergency: emergency!)
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
