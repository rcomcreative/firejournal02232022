//
//  ImageTextFieldTextViewCell.swift
//  dashboard
//
//  Created by DuRand Jones on 8/24/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol ImageTextFieldTextViewCellDelegate: AnyObject {
    func cellSelectedTapped(type: MenuItems)
}

class ImageTextFieldTextViewCell: UITableViewCell,UITextViewDelegate {

    //    MARK: -objects
    @IBOutlet weak var iconIV: UIImageView!
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var descriptionTV: UITextView!
    @IBOutlet weak var selectB: UIButton!
    @IBOutlet weak var newFormB: UIButton!
    
    //    MARK: -properties
    var myShift: MenuItems!
    weak var delegate:ImageTextFieldTextViewCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //    MARK: -button action
    @IBAction func selectionBTapped(_ sender: Any) {
        delegate?.cellSelectedTapped(type: myShift)
    }
    
    
}
