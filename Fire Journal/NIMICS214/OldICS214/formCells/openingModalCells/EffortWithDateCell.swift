//
//  EffortWithDateself.swift
//  ARCForm
//
//  Created by DuRand Jones on 10/24/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit


protocol EffortWithDateDelegate: AnyObject {

    func theSearchButtonTapped(incidentNum: String, incidentDate: Date? )
    func theSearchButtonTappedNoDate(incidentNum: String)
    func theNewIncidentButtonTapped()
    func theTimeButtonWasTappedForIncident()
}

class EffortWithDateCell: UITableViewCell, UITextFieldDelegate {

    
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var question1L: UILabel!
    @IBOutlet weak var question2L: UILabel!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var newIncidentB: UIButton!
    
    @IBOutlet weak var question1TF: UITextField!
    @IBOutlet weak var question2TF: UITextField!
    @IBOutlet weak var instructionL: UILabel!
    
    var theIncidentDate: Date!
    
    private var theType: TypeOfForm = .incidentForm
    var type: TypeOfForm = .incidentForm {
        didSet {
            self.theType = self.type
            switch self.theType {
            case .incidentForm:
                self.titleText = "Local Incident"
            case .femaTaskForceForm:
                self.titleText = "FEMA Task Force"
            case .strikeForceForm:
                self.titleText = "Strike Team"
            case .otherForm:
                self.titleText = "Other"
            default: break
            }
        }
    }
    
    private var theInstructionsText: String = ""
    var instructionsText: String = "" {
        didSet {
            self.theInstructionsText = self.instructionsText
            self.instructionL.text = self.theInstructionsText
        }
    }
    
    private var theTitleText: String = ""
    var titleText: String = "" {
        didSet {
            self.theTitleText = self.titleText
            self.titleL.text = self.theTitleText
            self.titleL.setNeedsDisplay()
        }
    }
    
    weak var delegate: EffortWithDateDelegate? = nil
    
    @IBAction func timeBTapped(_ sender: Any) {
        delegate?.theTimeButtonWasTappedForIncident()
    }
    
    @IBAction func incidentContinueBTapped(_ sender: Any) {
        let incidentNumber:String = ""
        delegate?.theSearchButtonTappedNoDate(incidentNum: incidentNumber)
    }
    
    @IBAction func newIncidentBTapped(_ sender: Any) {
        delegate?.theNewIncidentButtonTapped()
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        newIncidentB.layer.cornerRadius = 8.0
        continueButton.layer.cornerRadius = 8.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
