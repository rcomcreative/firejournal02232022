//
//  TextFieldWSwitch.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/7/18.
//  Copyright © 2018 PureCommandLLC. All rights reserved.
//

import UIKit

class TextFieldWSwitch: UITableViewCell {

    
    @IBOutlet weak var inputLabel: UILabel!
    @IBOutlet weak var noLabel: UILabel!
    @IBOutlet weak var yesLabel: UILabel!
    @IBOutlet weak var yesNoSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
