//
//  AddButtonCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 9/13/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol AddButtonCellDelegate: AnyObject {
    func theAddContactButtonTapped(indexPath: IndexPath)
}

class AddButtonCell: UITableViewCell {

    
    @IBOutlet weak var addButton: UIButton!
    var indexPath = IndexPath(item: 0, section: 0)
    
    weak var delegate: AddButtonCellDelegate? = nil
    
    @IBAction func addBTapped(_ sender: Any) {
        print("been tapped here")
        delegate?.theAddContactButtonTapped(indexPath: indexPath)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
