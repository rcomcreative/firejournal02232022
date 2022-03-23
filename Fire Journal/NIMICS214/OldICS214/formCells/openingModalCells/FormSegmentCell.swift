//
//  SegmentCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 10/24/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit


protocol FormSegmentCellDelegate: AnyObject {

    func typeChosen(type: Int)
}

class FormSegmentCell: UITableViewCell {

    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var openingSegment: UISegmentedControl!
    var type: Int = 0
    
    weak var delegate: FormSegmentCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        continueButton.layer.cornerRadius = 8.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        delegate?.typeChosen(type: type)
    }
    
    @IBAction func openingSegmentTapped(_ sender: Any) {
        switch openingSegment.selectedSegmentIndex
        {
        case 0:
            type = 0
        case 1:
            type = 1
        default:
            break;
        }
        print(type)
    }
    
}
