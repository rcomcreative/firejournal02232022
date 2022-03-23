//
//  IncidentAdditionalResoucesCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 6/1/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

class IncidentAdditionalResoucesCell: UITableViewCell {
    
    
    @IBOutlet weak var UserFDResourceIV: UIImageView!
    @IBOutlet weak var UserFDResourceTF: UITextField!
    
    var fdResource: UserFDResources? {
        didSet {
                if self.fdResource?.fdResourceImageName != "" {
                    guard let imageName = self.fdResource?.fdResourceImageName! else { return }
                    let image = UIImage(named: imageName)
                    self.UserFDResourceIV.image = image
                    self.UserFDResourceTF.text = self.fdResource?.fdResource
                }
            }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
        // update UI
        accessoryType = selected ? .checkmark : .none
    }
    
}
