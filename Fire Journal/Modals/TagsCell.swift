//
//  TagsCell.swift
//  dashboard
//
//  Created by DuRand Jones on 10/31/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

class TagsCell: UITableViewCell {
    
    @IBOutlet weak var tagsL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
         selectionStyle = .none
    }
    
    var tags: UserTags? {
        didSet {
            tagsL.text = tags?.userTag ?? ""
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
        // update UI
        accessoryType = selected ? .checkmark : .none
    }
    
}
