//
//  ResourceSegmentTVCell.swift
//  DashboardTest
//
//  Created by DuRand Jones on 2/4/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol ResourceSegmentTVCellDelegate: AnyObject {
    func resourceSegmentTapped(type: Int64, imageName: String)
}

class ResourceSegmentTVCell: UITableViewCell {

//    MARK: -objects-
    @IBOutlet weak var resourceSegment: UISegmentedControl!
    
//    MARK: -PROPERTIES-
    weak var delegate: ResourceSegmentTVCellDelegate? = nil
    var type: Int64 = 0
    var imageName: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        switch type {
            case 0002:
                resourceSegment.selectedSegmentIndex = 0
            case 0003:
                resourceSegment.selectedSegmentIndex = 1
            case 0004:
                resourceSegment.selectedSegmentIndex = 2
            default:
                resourceSegment.selectedSegmentIndex = 0
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    MARK: -ACTIONS-
    @IBAction func ResourceSegmentTapped(_ sender: Any) {
        switch resourceSegment.selectedSegmentIndex {
            case 0:
                type = 0002
                imageName = "GreenAvailable"
            case 1:
                type = 0003
                imageName = "YellowConditional"
            case 2:
                type = 0004
                imageName = "BlackOutOfService"
            default: break
        }
        delegate?.resourceSegmentTapped(type: type, imageName:  imageName)
    }
    
    
}
