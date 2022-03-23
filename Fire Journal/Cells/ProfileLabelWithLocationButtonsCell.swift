//
//  ProfileLabelWithLocationButtonsCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/14/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol ProfileLabelWithLocationButtonsDelegate: AnyObject {
    func theProfileLocationBTapped()
    func theProfileWorldBTapped()
}

class ProfileLabelWithLocationButtonsCell: UITableViewCell {
    
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var locationB: UIButton!
    @IBOutlet weak var worldB: UIButton!
    weak var delegate:ProfileLabelWithLocationButtonsDelegate? = nil
    
    @IBAction func locationBTapped(_ sender: Any) {
        delegate?.theProfileLocationBTapped()
    }
    @IBAction func worldBTapped(_ sender: Any) {
        delegate?.theProfileWorldBTapped()
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
