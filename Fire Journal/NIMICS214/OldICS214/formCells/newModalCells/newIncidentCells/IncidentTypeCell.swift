//
//  IncidentTypeCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 10/30/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit


protocol IncidentTypeDelegate: AnyObject {

    func theIncidentTypeChosen(type: Int)
}

class IncidentTypeCell: UITableViewCell {
    
    
    var type: Int = 0
    
    weak var delegate: IncidentTypeDelegate? = nil
    
    
    @IBOutlet weak var incidentTypeSegment: UISegmentedControl!
    @IBAction func incidentSegmentTapped(_ sender: Any) {
        switch incidentTypeSegment.selectedSegmentIndex {
        case 0:
            type = 0
            delegate?.theIncidentTypeChosen(type: type)
        case 1:
            type = 1
            delegate?.theIncidentTypeChosen(type: type)
        case 2:
            type = 2
            delegate?.theIncidentTypeChosen(type: type)
        default:
            break
        }
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
