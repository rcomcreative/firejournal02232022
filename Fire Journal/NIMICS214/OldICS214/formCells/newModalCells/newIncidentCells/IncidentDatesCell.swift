//
//  IncidentDatesCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 10/30/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit


protocol IncidentDatesDelegate: AnyObject {

    func theIncidentDateButtonTapped()
}

class IncidentDatesCell: UITableViewCell {

    weak var delegate: IncidentDatesDelegate? = nil
//    buttonAction
    @IBAction func incidentDateButtonTapped(_ sender: Any) {
        delegate?.theIncidentDateButtonTapped()
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
