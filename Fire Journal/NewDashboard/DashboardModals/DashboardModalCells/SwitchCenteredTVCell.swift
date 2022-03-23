//
//  SegmentCenteredTVCell.swift
//  DashboardTest
//
//  Created by DuRand Jones on 1/28/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol SwitchCenteredTVCellDelegate: AnyObject {
    func switchCenteredHasBeenTapped(switchB: Bool)
}

class SwitchCenteredTVCell: UITableViewCell {
    
    @IBOutlet weak var leftSubjectL: UILabel!
    @IBOutlet weak var centerSwitch: UISwitch!
    @IBOutlet weak var rightSubjectL: UILabel!
    var theSwitchB: Bool = true
    weak var delegate: SwitchCenteredTVCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func centerSwithTapped(_ sender: UISwitch) {
        theSwitchB.toggle()
        delegate?.switchCenteredHasBeenTapped(switchB: theSwitchB)
    }
    
}
