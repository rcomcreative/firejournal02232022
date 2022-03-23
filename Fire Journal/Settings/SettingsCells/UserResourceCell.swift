//
//  UserResourceCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/18/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

class UserResourceCell: UITableViewCell {
    
    @IBOutlet weak var resourceL: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    var fdResource: UserFDResources? {
        didSet {
            resourceL.text = fdResource?.fdResource
        }
    }
    
    var resource: UserResources? {
        didSet {
            resourceL.text = resource?.resource
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
        // update UI
        accessoryType = selected ? .checkmark : .none
    }
    
}
