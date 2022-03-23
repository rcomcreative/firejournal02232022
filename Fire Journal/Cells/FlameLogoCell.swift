//
//  FlameLogoCell.swift
//  dashboard
//
//  Created by DuRand Jones on 8/20/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol FlameLogoCellDelegate: AnyObject {
    func pureCommandBTapped()
}

class FlameLogoCell: UITableViewCell {
    
    @IBOutlet weak var pcLogoB: UIButton!
    weak var delegate: FlameLogoCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func pcLogoBTapped(_ sender: Any) {
        delegate?.pureCommandBTapped()
    }
    
    
}
