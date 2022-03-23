//
//  ResourceGroupCell.swift
//  dashboard
//
//  Created by DuRand Jones on 10/25/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

class ResourceGroupCell: UITableViewCell {
    
    @IBOutlet weak var subjectGroupNameL: UILabel!
    @IBOutlet weak var subjectGroupL: UILabel!
    

    var resource: UserResourcesGroups? {
        didSet {
            subjectGroupNameL.text = resource?.resourcesGroupName
            subjectGroupL.text = resource?.resourcesGroup
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
