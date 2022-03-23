//
//  ARC_LabelExpandedCell.swift
//  FJ ARC Plus
//
//  Created by DuRand Jones on 8/27/20.
//  Copyright © 2020 com.purecommand.FJARCPlus. All rights reserved.
//

import UIKit

class ARC_LabelExpandedCell: UITableViewCell {
    
//    MARK: -OBJECTS-
    @IBOutlet weak var subjectL: UILabel!
    
//    MARK: -PROPERTIES-

    private var theSubject = ""
    var label: String? {
        didSet {
            self.theSubject = self.label ?? ""
            self.subjectL.text = self.theSubject
        }
    }
    
    private var indexPath = IndexPath(item: 0, section: 0)
    var path: IndexPath? {
        didSet {
            self.indexPath = self.path ?? IndexPath(item: 0, section: 0)
        }
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
