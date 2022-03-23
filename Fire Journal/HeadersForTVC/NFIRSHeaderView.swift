//
//  NFIRSHeaderView.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/4/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit



class NFIRSHeaderView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var colorV: UIView!
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var toggleB: UIButton!
    @IBOutlet weak var headerDescL: UILabel!
    var title: String = ""
    var modDescription: String = ""
    var type: NFIRSModule!
    
    func headerText(type: NFIRSModule) {
        
        switch  type{
        case .modA:
            title = "NFIRS-1 Basic SECTION A"
            modDescription = "The Basic Module (NFIRS–1) captures general information on every incident (or emergency call) to which the department responds."
        case .modB:
            title = "NFIRS-1 Basic SECTION B"
            modDescription = "The exact location of the incident is used for spatial analyses and response planning that can be linked to demographic data. Incident address information is required at the local government level to establish an official document of record."
        case .modC:
            title = "NFIRS-1 Basic SECTION C"
            modDescription = "This is the actual situation that emergency personnel found on the scene when they arrived.These codes include the entire spectrum of fire department activities from fires to EMS to public service."
        case .modD:
            title = "NFIRS-1 Basic SECTION D"
            modDescription = "This is the actual situation that emergency personnel found on the scene when they arrived.These codes include the entire spectrum of fire department activities from fires to EMS to public service."
        case .modE1:
            title = "NFIRS-1 Basic SECTION E1,E2,E3"
            modDescription = "All dates and times are entered as numerals. For time of day, the 24-hour clock is used. The actual month, day, year, and time of day (hour, minute, and (optional in on-line entry) seconds) when the alarm was received by the fire department.This is not an elapsed time."
        case .modF:
            title = "NFIRS-1 Basic SECTION F"
            modDescription = "These data elements, together with Incident Type, enable a fire department to document the breadth of activities and the resources required by the responding fire department to effectively handle the incident."
        case .modG1:
            title = "NFIRS-1 Basic SECTION G1, G2"
            modDescription = "The total complement of fire department personnel and apparatus (suppression, EMS, other) that respond- ed to the incident.This includes all fire and EMS personnel assigned to the incident whether they arrived at the scene or were canceled before arrival."
        case .modH1:
            title = "NFIRS-1 Basic SECTION H1,H2,H3"
            modDescription = "Section H captures information on the number of civilians and firefighters injured or killed as a result of the incident. Other information in this section relates to whether a detector alerted occupants in a structure and whether hazardous materials were released."
        case .modI:
            title = "NFIRS-1 Basic SECTION I"
            modDescription = "This data element captures the overall use of a property. If a property has two or more uses, then the Mixed Use Property designation applies."
        case .modJ:
            title = "NFIRS-1 Basic SECTION J"
            modDescription = "This entry refers to the actual use of the property where the incident occurred, not the overall use of mixed use properties of which the property is part (see Mixed Use Property, Section I)."
        case .modK1:
            title = "NFIRS-1 Basic SECTION K1,K2"
            modDescription = "The full name of the company or agency occupying, managing, or leasing the property where the incident occurred. The full name of the company or agency that owns the property where the incident occurred."
        case .modL:
            title = "NFIRS-1 Basic SECTION L"
            modDescription = "The Remarks section is an area for any comments that might be made concerning the incident. It is also a place to describe what happened, fire department operations, or unusual conditions encountered."
        case .modM:
            title = "NFIRS-1 Basic SECTION M"
            modDescription = "Section M requires the identifcation and signatures of the person completing the incident report and his/ her supervisor. A completed example of the  fields used is presented at the end of this section."
        case .modCompleted:
            title = "NFIRS-1 Basic Completed Modules"
            modDescription = "This area of the Basic Module is used to determine the totality of all the modules submitted for a specific incident. It acts as a checklist for completed modules under the paper form system."
        case .modRequired:
            title = "NFIRS-1 Basic Modules Required"
            modDescription = "The block indicates whether a Fire Module or Structure Fire Module is required according to the Incident Type recorded in Section C of this module."
        default:
            title = "got nothing honey"
            modDescription = "what the fuck"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleL.text = title
        headerDescL.text = modDescription
    }
    
    
    
}
