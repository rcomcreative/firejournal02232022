//
//  ResourceCell.swift
//  dashboard
//
//  Created by DuRand Jones on 10/24/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

class ResourceCell: UITableViewCell {

    @IBOutlet weak var resourceL: UILabel!

    
    var resource: UserResources? {
        didSet {
            resourceL.text = resource?.resource
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // update UI
        accessoryType = selected ? .checkmark : .none
    }
    
}
