//
//  LinkeJournalCell.swift
//  dashboard
//
//  Created by DuRand Jones on 10/17/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation


//@available(iOS 13.0, *)
class LinkeJournalCell: UITableViewCell {
    
//    var backgrndColor = UIColor.systemBackground//UIColor(red:0.33, green:0.5, blue:0.66, alpha:1)
    @IBOutlet weak var journalTypeIV: UIImageView!
    @IBOutlet weak var journalHeader: UILabel!
    @IBOutlet weak var journalDateL: UILabel!
    @IBOutlet weak var journalLocationL: UILabel!
    @IBOutlet weak var selectedV: UIView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.backgroundColor = backgrndColor
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
