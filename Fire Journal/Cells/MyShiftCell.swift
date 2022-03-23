//
//  MyShiftCell.swift
//  dashboard
//
//  Created by DuRand Jones on 8/15/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol MyShiftCellDelegate: AnyObject {
    func myShiftCellTapped(myShift: MenuItems)
}


class MyShiftCell: UITableViewCell {
    
    //    MARK: Objects
    @IBOutlet weak var myShiftIV: UIImageView!
    @IBOutlet weak var myShiftL: UILabel!
    @IBOutlet weak var myShiftBarIV: UIImageView!
    @IBOutlet weak var myShiftButton: UIButton!
    // MARK: Properties
    var myShift: MenuItems! = nil
    
    weak var delegate: MyShiftCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func myShiftTapped(_ sender: Any) {
        delegate?.myShiftCellTapped(myShift: myShift)
    }
    
}
