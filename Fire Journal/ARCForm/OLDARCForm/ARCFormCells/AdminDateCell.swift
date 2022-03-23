//
//  AdminDateCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/12/18.
//  Copyright © 2018 PureCommandLLC. All rights reserved.
//

import UIKit

@objc protocol AdminDataCellDelegate:class {
    func dateBTap()
}

class AdminDateCell: UITableViewCell {
    
    @IBOutlet weak var questionL: UILabel!
    @IBOutlet weak var monthL: UILabel!
    @IBOutlet weak var dayL: UILabel!
    @IBOutlet weak var yearL: UILabel!
    @IBOutlet weak var dateB: UIButton!
    @IBOutlet weak var mmL: UILabel!
    @IBOutlet weak var ddL: UILabel!
    @IBOutlet weak var yyyyL: UILabel!
    
    weak var delegate:AdminDataCellDelegate? = nil
    
    @IBAction func dateBTapped(_ sender: Any) {
        delegate?.dateBTap()
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
