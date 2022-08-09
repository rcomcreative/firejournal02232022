//
//  SectionHeaderCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 8/30/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

class ModalHeaderCell: UITableViewCell {

    @IBOutlet weak var sectionIV: UIImageView!
    @IBOutlet weak var formNameL: UILabel!
    @IBOutlet weak var formDescriptionL: UILabel!
    
    private var theDescriptionText: String = ""
    var descriptionText: String = "" {
        didSet {
            self.theDescriptionText = self.descriptionText
            self.formNameL.text = theDescriptionText
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        formNameL.text = "ACTIVITY LOG (ICS 214)"
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
