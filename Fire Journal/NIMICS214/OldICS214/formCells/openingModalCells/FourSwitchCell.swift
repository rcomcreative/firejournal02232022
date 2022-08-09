//
//  FourSwitchCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 10/24/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

enum TypeOfForm: String {
    case incidentForm = "incidentForm"
    case strikeForceForm = "strikeForceForm"
    case femaTaskForceForm = "femaTaskForceForm"
    case otherForm = "otherForm"
}


protocol FourSwitchCellDelegate: AnyObject {

    func fourSwitchContinueTapped(type: String, masterOrMore: Bool, typeOfForm: TypeOfForm)
}

class FourSwitchCell: UITableViewCell {
    
    var type:String = ""
    var typeOfForm: TypeOfForm!
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
    
    private var theLocalIncidentOn: Bool = false
    var localIncidentOn: Bool = true {
        didSet {
            self.theLocalIncidentOn = self.localIncidentOn
            if self.theLocalIncidentOn {
                localIncidentSwitch.setOn(true, animated: true)
                localIncidentMasterIV.isHidden = false
                localIncidentMasterIV.alpha = 1.0
                femaTaskForceSwitch.setOn(false, animated: true)
                femaMasterIV.isHidden = false
                femaMasterIV.alpha = 0.0
                strikeTeamSwitch.setOn(false, animated: true)
                strikeTeamMasterIV.isHidden = false
                strikeTeamMasterIV.alpha = 0.0
                otherSwitch.setOn(false, animated: true)
                otherMasterIV.isHidden = false
                otherMasterIV.alpha = 0.0
            } else {
                localIncidentSwitch.setOn(false, animated: true)
                localIncidentMasterIV.isHidden = false
                localIncidentMasterIV.alpha = 0.0
            }
        }
    }
    
    private var theFEMATaksForceOn: Bool = false
    var femaTaksForceOn: Bool = true {
        didSet {
            self.theFEMATaksForceOn = self.femaTaksForceOn
            if self.theFEMATaksForceOn {
                femaTaskForceSwitch.setOn(true, animated: true)
                femaMasterIV.isHidden = false
                femaMasterIV.alpha = 1.0
                localIncidentSwitch.setOn(false, animated: true)
                localIncidentMasterIV.isHidden = false
                localIncidentMasterIV.alpha = 0.0
                strikeTeamSwitch.setOn(false, animated: true)
                strikeTeamMasterIV.isHidden = false
                strikeTeamMasterIV.alpha = 0.0
                otherSwitch.setOn(false, animated: true)
                otherMasterIV.isHidden = false
                otherMasterIV.alpha = 0.0
            } else {
                femaTaskForceSwitch.setOn(false, animated: true)
                femaMasterIV.isHidden = false
                femaMasterIV.alpha = 0.0
            }
        }
    }
    
    private var theStrikeTeamOn: Bool = true
    var strikeTeamOn: Bool = true {
        didSet {
            self.theStrikeTeamOn = self.strikeTeamOn
            if self.theStrikeTeamOn {
                localIncidentSwitch.setOn(false, animated: true)
                localIncidentMasterIV.isHidden = false
                localIncidentMasterIV.alpha = 0.0
                femaTaskForceSwitch.setOn(false, animated: true)
                femaMasterIV.isHidden = false
                femaMasterIV.alpha = 0.0
                strikeTeamSwitch.setOn(true, animated: true)
                strikeTeamMasterIV.isHidden = false
                strikeTeamMasterIV.alpha = 1.0
                otherSwitch.setOn(false, animated: true)
                otherMasterIV.isHidden = false
                otherMasterIV.alpha = 0.0
            } else {
                strikeTeamSwitch.setOn(false, animated: true)
                strikeTeamMasterIV.isHidden = false
                strikeTeamMasterIV.alpha = 0.0
            }
        }
    }
    
    private var theOtherOn: Bool = true
    var otherOn: Bool = true {
        didSet {
            self.theOtherOn = self.otherOn
            if self.theOtherOn {
                otherSwitch.setOn(true, animated: true)
                otherMasterIV.isHidden = false
                otherMasterIV.alpha = 1.0
                localIncidentSwitch.setOn(false, animated: true)
                localIncidentMasterIV.isHidden = false
                localIncidentMasterIV.alpha = 0.0
                femaTaskForceSwitch.setOn(false, animated: true)
                femaMasterIV.isHidden = false
                femaMasterIV.alpha = 0.0
                strikeTeamSwitch.setOn(false, animated: true)
                strikeTeamMasterIV.isHidden = false
                strikeTeamMasterIV.alpha = 0.0
            } else {
                otherSwitch.setOn(false, animated: true)
                otherMasterIV.isHidden = false
                otherMasterIV.alpha = 0.0
            }
        }
    }
    
    private var theInsructionsText: String = ""
    var instructionsText: String = "" {
        didSet {
            self.theInsructionsText = self.instructionsText
            self.instructionL.text = self.theInsructionsText
        }
    }

    
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
            typeOfForm = TypeOfForm.incidentForm
        }
        delegate?.fourSwitchContinueTapped(type: type, masterOrMore: masterOrMore, typeOfForm: typeOfForm)
    }
    
    @IBAction func localIncidentSTapped(_ sender: Any) {
        if !localIncidentSwitch.isOn {
            localIncidentSwitch.setOn(false, animated: true)
        } else {
            localIncidentSwitch.setOn(true, animated: true)
            UIView.animate(withDuration: 0.5, animations: {
                self.localIncidentMasterIV.alpha = 1.0
                self.strikeTeamMasterIV.alpha = 0.0
                self.femaMasterIV.alpha = 0.0
                self.otherMasterIV.alpha = 0.0
            })
            strikeTeamSwitch.setOn(false, animated: true)
            femaTaskForceSwitch.setOn(false, animated: true)
            otherSwitch.setOn(false, animated: true)
            type = TypeOfForm.incidentForm.rawValue
            typeOfForm = TypeOfForm.incidentForm
        }
    }
    
    @IBAction func strikeTeamSTapped(_ sender: Any) {
        if !strikeTeamSwitch.isOn {
            strikeTeamSwitch.setOn(false, animated: true)
        } else {
            localIncidentSwitch.setOn(false, animated: true)
            strikeTeamSwitch.setOn(true, animated: true)
            UIView.animate(withDuration: 0.5, animations: {
                self.localIncidentMasterIV.alpha = 0.0
                self.strikeTeamMasterIV.alpha = 1.0
                self.femaMasterIV.alpha = 0.0
                self.otherMasterIV.alpha = 0.0
            })
            femaTaskForceSwitch.setOn(false, animated: true)
            otherSwitch.setOn(false, animated: true)
            type = TypeOfForm.strikeForceForm.rawValue
            typeOfForm = TypeOfForm.strikeForceForm
        }
    }
    
    @IBAction func femaTaskForceSTapped(_ sender: Any) {
        if !femaTaskForceSwitch.isOn {
            femaTaskForceSwitch.setOn(false, animated: true)
        } else {
            localIncidentSwitch.setOn(false, animated: true)
            strikeTeamSwitch.setOn(false, animated: true)
            femaTaskForceSwitch.setOn(true, animated: true)
            UIView.animate(withDuration: 0.5, animations: {
                self.localIncidentMasterIV.alpha = 0.0
                self.strikeTeamMasterIV.alpha = 0.0
                self.femaMasterIV.alpha = 1.0
                self.otherMasterIV.alpha = 0.0
            })
            otherSwitch.setOn(false, animated: true)
            type = TypeOfForm.femaTaskForceForm.rawValue
            typeOfForm = TypeOfForm.femaTaskForceForm
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
            UIView.animate(withDuration: 0.5, animations: {
                self.localIncidentMasterIV.alpha = 0.0
                self.strikeTeamMasterIV.alpha = 0.0
                self.femaMasterIV.alpha = 0.0
                self.otherMasterIV.alpha = 1.0
            })
            type = TypeOfForm.otherForm.rawValue
            typeOfForm = TypeOfForm.otherForm
        }
    }
    
    
    
    
}
