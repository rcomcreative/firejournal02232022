//
//  SectionHeaderCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 8/30/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

class ContactHeaderCell: UITableViewCell {

    @IBOutlet weak var sectionIV: UIImageView!
    @IBOutlet weak var formNameL: UILabel!
    @IBOutlet weak var loadingContactL: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        formNameL.text = "ACTIVITY LOG (ICS 214)"
        loadingContactL.text = "Retrieving Contacts…"
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
