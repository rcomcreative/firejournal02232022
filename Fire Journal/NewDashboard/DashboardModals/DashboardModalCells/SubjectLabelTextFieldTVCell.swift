//
//  SubjectLabelTextFieldTVCell.swift
//  DashboardTest
//
//  Created by DuRand Jones on 1/28/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

class SubjectLabelTextFieldTVCell: UITableViewCell {
    
//    MARK: -Properties-
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var subjectTF: UITextField!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
