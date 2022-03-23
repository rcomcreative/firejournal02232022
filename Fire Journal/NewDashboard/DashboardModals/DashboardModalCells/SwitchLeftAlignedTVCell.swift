//
//  SwitchLeftAlignedTVCell.swift
//  DashboardTest
//
//  Created by DuRand Jones on 1/28/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol SwitchLeftAlignedTVCellDelegate: AnyObject {
    func switchLeftAlignedHasBeenTapped(switchB: Bool)
}

class SwitchLeftAlignedTVCell: UITableViewCell {
//    MARK: -OBJECTS
    @IBOutlet weak var leftAllignedSwitch: UISwitch!
    @IBOutlet weak var leftAlignedSubjectL: UILabel!
    var theSwitchB: Bool = true
    weak var delegate: SwitchLeftAlignedTVCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func leftAlignedSwitchTapped(_ sender: Any) {
        theSwitchB.toggle()
        delegate?.switchLeftAlignedHasBeenTapped(switchB: theSwitchB)
    }
    
    
}
