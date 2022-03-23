//
//  ARCSegmentCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/23/18.
//  Copyright © 2018 PureCommandLLC. All rights reserved.
//

import UIKit

protocol ARCSegmentCellDelegate:class {
    func arcTypeChosen(type: Int)
}

class ARCSegmentCell: UITableViewCell {

    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var arcSegment: UISegmentedControl!
    @IBOutlet weak var masterContinueB: UIButton!
    
    var type: Int = 0
    
    weak var delegate: ARCSegmentCellDelegate? = nil
    
    @IBAction func arcSegmentTapped(_ sender: Any) {
        switch arcSegment.selectedSegmentIndex
        {
        case 0:
            type = 0
        case 1:
            type = 1
        default:
            break;
        }
    }
    
    @IBAction func masterContinueBTapped(_ sender: Any) {
        delegate?.arcTypeChosen(type: type)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
