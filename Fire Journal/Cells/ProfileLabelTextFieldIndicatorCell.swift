//
//  ProfileLabelTextFieldIndicatorCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/14/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

class ProfileLabelTextFieldIndicatorCell: UITableViewCell {

    @IBOutlet weak var descriptionTF: UITextField!
    @IBOutlet weak var subjectL: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
