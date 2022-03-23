//
//  JournalMasterCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 10/27/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

class JournalMasterCell: UITableViewCell {
    
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var instructionL: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
