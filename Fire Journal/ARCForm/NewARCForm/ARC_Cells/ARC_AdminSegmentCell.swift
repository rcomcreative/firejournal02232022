//
//  ARC_AdminSegmentCell.swift
//  FJ ARC Plus
//
//  Created by DuRand Jones on 8/27/20.
//  Copyright © 2020 com.purecommand.FireJournal. All rights reserved.
//

import UIKit
import Foundation

protocol  ARC_AdminSegmentDelegate: AnyObject {
    func theAdminSegmentWasTapped(type: ARC_FormType, tag: Int, indexPath: IndexPath)
}

class ARC_AdminSegmentCell: UITableViewCell {
    
//    MARK: -OBJECTS
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var segment: UISegmentedControl!
    
//    MARK: -PROPERTIES-
    
    weak var delegate: ARC_AdminSegmentDelegate? = nil
    
    private var type: ARC_FormType = .arcOrp
    var theType: ARC_FormType? {
        didSet {
            self.type = self.theType ?? ARC_FormType.arcOrp
            switch self.type {
            case .arcOrp:
                segment.selectedSegmentIndex = 0
            case .mySmokeAlarm:
                segment.selectedSegmentIndex = 1
            case .other:
                segment.selectedSegmentIndex = 2
            }
        }
    }
    
    private var indexPath = IndexPath(item: 0, section: 0)
    var path: IndexPath? {
        didSet {
            self.indexPath = self.path ?? IndexPath(item: 0, section: 0)
        }
    }
    
    private var theSubject = ""
    var label: String? {
        didSet {
            self.theSubject = self.label ?? ""
            self.subjectL.text = self.theSubject
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
    @IBAction func segmentTapped(_ sender: Any) {
        switch segment.selectedSegmentIndex {
            case 0:
                type = .arcOrp
            case 1:
                type = .mySmokeAlarm
            case 2:
                type = .other
            default: break
        }
        delegate?.theAdminSegmentWasTapped(type: type, tag: self.tag, indexPath: indexPath)
    }
    
}
