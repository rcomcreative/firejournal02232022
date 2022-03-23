//
//  dismissSaveCell.swift
//  dashboard
//
//  Created by DuRand Jones on 8/18/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol dismissSaveCellDelegate: AnyObject {
    func dismissBTapped()
    func saveBTapped()
}

class dismissSaveCell: UITableViewCell {
    
    //    MARK: -buttons
    @IBOutlet weak var dismissB: UIButton!
    @IBOutlet weak var saveB: UIButton!
    //    MARK: -properties
    weak var delegate:dismissSaveCellDelegate? = nil
    var myShift: MenuItems! = nil
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //    MARK: button actions
    @IBAction func dismissTapped(_ sender: Any) {
        delegate?.dismissBTapped()
    }
    @IBAction func saveTapped(_ sender: Any) {
        delegate?.saveBTapped()
    }
    
    
}
