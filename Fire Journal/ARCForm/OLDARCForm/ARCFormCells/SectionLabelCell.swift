//
//  sectionLabelCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/8/18.
//  Copyright © 2018 PureCommandLLC. All rights reserved.
//

import UIKit

class SectionLabelCell: UITableViewCell {

    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var titleBackgroundV: UIView!
    var backColor: UIColor!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleBackgroundV.backgroundColor = backColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
