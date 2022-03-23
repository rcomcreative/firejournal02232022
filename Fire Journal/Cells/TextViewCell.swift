//
//  TextViewCell.swift
//  dashboard
//
//  Created by DuRand Jones on 8/17/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit


class TextViewCell: UITableViewCell, UITextViewDelegate {
    
    @IBOutlet weak var modalInstructions: UITextView!
    //    MARK: -PROPERTIES
    var myShift: MenuItems! = nil
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
