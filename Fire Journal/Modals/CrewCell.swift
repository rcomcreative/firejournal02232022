//
//  CrewCell.swift
//  dashboard
//
//  Created by DuRand Jones on 10/26/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

class CrewCell: UITableViewCell {
    
    @IBOutlet weak var crewL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }
    
    var contact: UserAttendees? {
        didSet {
            crewL.text = contact?.attendee ?? ""
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
        // update UI
        accessoryType = selected ? .checkmark : .none
    }
    
}
