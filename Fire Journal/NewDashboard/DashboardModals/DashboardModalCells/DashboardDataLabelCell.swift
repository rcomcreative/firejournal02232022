//
//  DashboardDataLabelCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/3/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

class DashboardDataLabelCell: UITableViewCell {

    @IBOutlet weak var dashboardDataL: UILabel!
    
    var dashData: String? {
        didSet {
            dashboardDataL.text = self.dashData ?? ""
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        accessoryType = selected ? .checkmark : .none
    }
    
}
