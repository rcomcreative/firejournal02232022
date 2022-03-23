//
//  MasterCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 9/8/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

@objc class MasterCell: UITableViewCell {
    @IBOutlet weak var headerL: UILabel!
    @IBOutlet weak var fromDateL: UILabel!
    @IBOutlet weak var toDate: UILabel!
    @IBOutlet weak var iconIV: UIImageView!
    @IBOutlet weak var markerIV: UIImageView!
    @IBOutlet weak var completedL: UILabel!
    var tapped: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
