//
//  LabelWithInfoCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/27/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol LabelWithInfoCellDelegate: AnyObject {
    func theInfoBTapped()
}

class LabelWithInfoCell: UITableViewCell {

    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var infoB: UIButton!
    weak var delegate: LabelWithInfoCellDelegate? = nil
    
    @IBAction func infoBTapped(_ sender: Any) {
        delegate?.theInfoBTapped()
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
