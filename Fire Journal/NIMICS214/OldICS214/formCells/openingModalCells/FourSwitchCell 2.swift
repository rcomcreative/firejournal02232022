//
//  FourSwitchCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 10/24/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

enum TypeOfForm:String {
    case incidentForm = "incidentForm"
    case strikeForceForm = "strikeForceForm"
    case femaTaskForceForm = "femaTaskForceForm"
    case otherForm = "otherForm"
}

protocol FourSwitchCellDelegate: AnyObject {
    func fourSwitchContinueTapped(type: String, masterOrMore: Bool)
}

class FourSwitchCell: UITableViewCell {
    
    var type:String = ""
    var masterOrMore:Bool = true
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var localIncidentL: UILabel!
    @IBOutlet weak var strikeTeamL: UILabel!
    @IBOutlet weak var femaTaskForceL: UILabel!
    @IBOutlet weak var otherL: UILabel!
    @IBOutlet weak var localIncidentSwitch: UISwitch!
    @IBOutlet weak var strikeTeamSwitch: UISwitch!
    @IBOutlet weak var femaTaskForceSwitch: UISwitch!
    @IBOutlet weak var otherSwitch: UISwitch!
    @IBOutlet weak var continueB: UIButton!
    @IBOutlet weak var instructionL: UILabel!
    @IBOutlet weak var localIncidentMasterIV: UIImageView!
    @IBOutlet weak var strikeTeamMasterIV: UIImageView!
    @IBOutlet weak var femaMasterIV: UIImageView!
    @IBOutlet weak var otherMasterIV: UIImageView!
    
    weak var delegate: FourSwitchCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        continueB.layer.cornerRadius = 8.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func continueBTapped(_ sender: Any) {
        if(type == "") {
            type = TypeOfForm.incidentForm.rawValue
        }
        delegate?.fourSwitchContinueTapped(type: type, masterOrMore: masterOrMore)
    }
    @IBAction func localIncidentSTapped(_ sender: Any) {
        if !localIncidentSwitch.isOn {
            localIncidentSwitch.setOn(false, animated: true)
        } else {
            localIncidentSwitch.setOn(true, animated: true)
            strikeTeamSwitch.setOn(false, animated: true)
            femaTaskForceSwitch.setOn(false, animated: true)
            otherSwitch.setOn(false, animated: true)
            type = TypeOfForm.incidentForm.rawValue
        }
    }
    @IBAction func strikeTeamSTapped(_ sender: Any) {
        if !strikeTeamSwitch.isOn {
            strikeTeamSwitch.setOn(false, animated: true)
        } else {
            localIncidentSwitch.setOn(false, animated: true)
            strikeTeamSwitch.setOn(true, animated: true)
            femaTaskForceSwitch.setOn(false, animated: true)
            otherSwitch.setOn(false, animated: true)
            type = TypeOfForm.strikeForceForm.rawValue
        }
    }
    @IBAction func femaTaskForceSTapped(_ sender: Any) {
        if !femaTaskForceSwitch.isOn {
            femaTaskForceSwitch.setOn(false, animated: true)
        } else {
            localIncidentSwitch.setOn(false, animated: true)
            strikeTeamSwitch.setOn(false, animated: true)
            femaTaskForceSwitch.setOn(true, animated: true)
            otherSwitch.setOn(false, animated: true)
            type = TypeOfForm.femaTaskForceForm.rawValue
        }
    }
    @IBAction func otherSTapped(_ sender: Any) {
        if !otherSwitch.isOn {
            otherSwitch.setOn(false, animated: true)
        } else {
            localIncidentSwitch.setOn(false, animated: true)
            strikeTeamSwitch.setOn(false, animated: true)
            femaTaskForceSwitch.setOn(false, animated: true)
            otherSwitch.setOn(true, animated: true)
            type = TypeOfForm.otherForm.rawValue
        }
    }
    
    
    
    
}
