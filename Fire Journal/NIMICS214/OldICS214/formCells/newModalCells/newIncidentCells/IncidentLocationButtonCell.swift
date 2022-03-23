//
//  IncidentLocationButtonCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 10/30/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit


protocol IncidentLocationDelegate: AnyObject {

    func localationTapped()
    func mapCallTapped()
}

class IncidentLocationButtonCell: UITableViewCell {
    
    @IBOutlet weak var locationL: UILabel!
    
    
    weak var delegate: IncidentLocationDelegate? = nil
    
    @IBAction func localLocationBTapped(_ sender: Any) {
        delegate?.localationTapped()
    }
    @IBAction func worldLocationBTapped(_ sender: Any) {
        delegate?.mapCallTapped()
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
