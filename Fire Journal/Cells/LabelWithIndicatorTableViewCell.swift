//
//  LabelWithIndicatorTableViewCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/20/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation

class LabelWithIndicatorTableViewCell: UITableViewCell {
    @IBOutlet weak var SubjectL: UILabel!
    var settingType:FJSettings!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
