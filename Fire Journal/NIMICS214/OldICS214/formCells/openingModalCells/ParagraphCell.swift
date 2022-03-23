//
//  ParagraphCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 10/24/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

class ParagraphCell: UITableViewCell {

    @IBOutlet weak var header1L: UILabel!
    @IBOutlet weak var paragraph1L: UILabel!
    @IBOutlet weak var header2L: UILabel!
    @IBOutlet weak var paragraph2L: UILabel!
    @IBOutlet weak var header3L: UILabel!
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
