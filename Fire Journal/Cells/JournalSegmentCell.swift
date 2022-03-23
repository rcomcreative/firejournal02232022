//
//  JournalSegmentCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 2/8/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol JournalSegmentDelegate: AnyObject {
    func journalSectionChosen(type: MenuItems)
}

class JournalSegmentCell: UITableViewCell {

    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var typeSegment: UISegmentedControl!
    //    MARK: -properties
    var myShift:MenuItems = .journal
    var type:MenuItems = .journal
    weak var delegate:JournalSegmentDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func typeSegmentTapped(_ sender: Any) {
        switch myShift {
        case .journal:
            switch typeSegment.selectedSegmentIndex {
            case 0:
                type = .station
            case 1:
                type = .community
            case 2:
                type = .members
            case 3:
                type = .training
            default:
                type = .station
            }
        default: break
        }
        delegate?.journalSectionChosen(type: type)
    }
    
}
