//
//  SettingsTVCell.swift
//  DashboardTest
//
//  Created by DuRand Jones on 11/18/19.
//  Copyright © 2019 inSky LE. All rights reserved.
//

import UIKit

class SettingsTVCell: UITableViewCell {
    
    @IBOutlet weak var settingBackgroundIV: UIImageView!
    @IBOutlet weak var iconIV: UIImageView!
    @IBOutlet weak var settingsSubjectL: UILabel!
    @IBOutlet weak var indicatorSymbol: UIImageView!
    var settingType:FJSettings!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
