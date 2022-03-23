//
//  ARCOpeningParagraphCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 5/13/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

class ARCOpeningParagraphCell: UITableViewCell {

    @IBOutlet weak var subject1L: UILabel!
    @IBOutlet weak var paragraph1L: UILabel!
    @IBOutlet weak var subject2L: UILabel!
    @IBOutlet weak var paragraph2L: UILabel!
    @IBOutlet weak var subject3L: UILabel!
    @IBOutlet weak var paragraph3L: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
