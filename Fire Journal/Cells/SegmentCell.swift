//
//  SegmentCell.swift
//  dashboard
//
//  Created by DuRand Jones on 8/23/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol SegmentCellDelegate:class{
    func sectionChosen(type: MenuItems)
}

class SegmentCell: UITableViewCell {
    //    MARK: -objects
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var typeSegment: UISegmentedControl!
    //    MARK: -properties
    var myShift:MenuItems = .journal
    var type:MenuItems = .journal
    weak var delegate:SegmentCellDelegate? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
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
        case .incidents:
            switch typeSegment.selectedSegmentIndex {
            case 0:
                type = .fire
            case 1:
                type = .ems
            case 2:
                type = .rescue
            default:
                type = .fire
            }
        case .incidentExposure:
            switch typeSegment.selectedSegmentIndex {
            case 0:
                type = .delete
            case 1:
                type = .change
            case 2:
                type = .noactivity
            default:
                type = .noactivity
            }
        case .nfirsGender:
            switch typeSegment.selectedSegmentIndex {
            case 0:
                type = .mr
            case 1:
                type = .ms
            case 2:
                type = .mrs
            default:
                type = .mr
            }
        default:
            print("nothing here")
        }
        delegate?.sectionChosen(type: type)
    }
    
    
}
