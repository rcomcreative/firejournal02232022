//
//  NewICS214ResourcesAssignedCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 6/25/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol NewICS214ResourcesAssignedCellDelegate: AnyObject {
    func addBTapped()
}


class NewICS214ResourcesAssignedCell: UITableViewCell {
    
    @IBOutlet weak var addB: UIButton!
    weak var delegate: NewICS214ResourcesAssignedCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addB.layer.cornerRadius = 8.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addBTapped(_ sender: Any) {
        delegate?.addBTapped()
    }
    
    
}
