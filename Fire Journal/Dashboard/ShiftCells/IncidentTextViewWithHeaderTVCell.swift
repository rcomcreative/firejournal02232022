//
//  IncidentTextViewWithHeaderTVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/18/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit

class IncidentTextViewWithHeaderTVCell: UITableViewCell {
    
    let descriptionTV = UITextView()
    let theBackgroundView = UIView()
    
    private var theDescription: String = ""
    var information: String = "" {
        didSet {
            self.theDescription = self.information
            self.descriptionTV.text = self.theDescription
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
