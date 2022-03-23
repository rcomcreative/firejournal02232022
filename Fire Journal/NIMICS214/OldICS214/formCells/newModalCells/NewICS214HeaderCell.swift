//
//  NewICS214HeaderCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/25/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol NewICS214HeaderCellDelegate: AnyObject {
    func headerCellCancel()
    func headerCellSave()
}

class NewICS214HeaderCell: UITableViewCell {

    @IBOutlet weak var iconIV: UIImageView!
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var cancelB: UIButton!
    @IBOutlet weak var saveB: UIButton!
    
    weak var delegate: NewICS214HeaderCellDelegate? = nil
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func saveBTapped(_ sender: Any) {
        delegate?.headerCellSave()
    }
    
    @IBAction func cancelBTapped(_ sender: Any) {
        delegate?.headerCellCancel()
    }
    
    
}
