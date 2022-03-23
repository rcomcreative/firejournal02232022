//
//  LabelCell.swift
//  dashboard
//
//  Created by DuRand Jones on 8/17/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

class LabelCell: UITableViewCell {
    
    @IBOutlet weak var modalTitleL: UILabel!
    var myShift: MenuItems! = nil
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
