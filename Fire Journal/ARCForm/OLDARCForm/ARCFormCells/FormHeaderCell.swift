//
//  SectionHeaderCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/9/18.
//  Copyright © 2018 PureCommandLLC. All rights reserved.
//

import UIKit

class FormHeaderCell: UITableViewCell {

    @IBOutlet weak var formTitleL: UILabel!
    @IBOutlet weak var formNameL: UILabel!
    @IBOutlet weak var formIV: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
