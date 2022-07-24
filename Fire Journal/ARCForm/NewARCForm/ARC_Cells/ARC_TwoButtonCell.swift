//
//  ARC_TwoButtonCell.swift
//  FJ ARC Plus
//
//  Created by DuRand Jones on 9/8/20.
//  Copyright © 2020 com.purecommand.FireJournal. All rights reserved.
//

import UIKit

protocol ARC_TwoButtonCellDelegate: AnyObject {
    func twoButtonMasterBTapped()
    func twoButtonAdditionalBTapped()
}

class ARC_TwoButtonCell: UITableViewCell {
    
//    MARK: -OBJECTS-
    @IBOutlet weak var masterB: UIButton!
    @IBOutlet weak var additionalB: UIButton!
    
    
//    MARK: -PROPERTIES-
    weak var delegate: ARC_TwoButtonCellDelegate? = nil
    
    private var indexPath = IndexPath(item: 0, section: 0)
    var path: IndexPath? {
        didSet {
            self.indexPath = self.path ?? IndexPath(item: 0, section: 0)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        masterB.layer.cornerRadius = 8.0
        masterB.clipsToBounds = true
        additionalB.layer.cornerRadius = 8.0
        additionalB.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func masterBTapped(_ sender: Any) {
        delegate?.twoButtonMasterBTapped()
    }
    
    @IBAction func additionalBTapped(_ sender: Any) {
        delegate?.twoButtonAdditionalBTapped()
    }
    
}
