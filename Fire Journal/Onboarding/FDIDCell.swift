//
//  FDIDCell.swift
//  dashboard
//
//  Created by DuRand Jones on 10/16/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

class FDIDCell: UITableViewCell {
    
    @IBOutlet weak var fdidL: UILabel!
    @IBOutlet weak var deptL: UILabel!
    @IBOutlet weak var cityL: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
