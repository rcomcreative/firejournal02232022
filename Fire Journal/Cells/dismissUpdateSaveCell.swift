//
//  dismissUpdateSaveCell.swift
//  dashboard
//
//  Created by DuRand Jones on 8/18/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol dismissUpdateSaveCellDelegate: AnyObject {
    func theDismissedTapped()
    func theUpdateTapped()
    func theSaveTapped()
}

class dismissUpdateSaveCell: UITableViewCell {
    
    //    MARK: -OBJECTS
    @IBOutlet weak var dismissB: UIButton!
    @IBOutlet weak var updateB: UIButton!
    @IBOutlet weak var saveB: UIButton!
    //    MARK: -properties
    weak var delegate:dismissUpdateSaveCellDelegate? = nil
    var myShift: MenuItems! = nil
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //    MARK: -BUTTON ACTIONS
    @IBAction func dismissBTapped(_ sender: Any) {
        delegate?.theDismissedTapped()
    }
    @IBAction func updateBTapped(_ sender: Any) {
        delegate?.theUpdateTapped()
    }
    @IBAction func saveBTapped(_ sender: Any) {
        delegate?.theSaveTapped()
    }
    
    
}
