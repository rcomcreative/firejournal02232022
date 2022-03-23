//
//  ARC_LabelCell.swift
//  dashboard
//
//  Created by DuRand Jones on 8/17/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit
import CoreData

class ARC_LabelCell: UITableViewCell {
    
//    MARK: -OBJECTS-
    @IBOutlet weak var modalTitleL: UILabel!
    
//    MARK: -PROPERTIES-
    
    private var indexPath = IndexPath(item: 0, section: 0)
    var path: IndexPath? {
        didSet {
            self.indexPath = self.path ?? IndexPath(item: 0, section: 0)
        }
    }
    
    var object: NSManagedObjectID? = nil
    var theObject: NSManagedObjectID? = nil {
        didSet {
            self.object = self.theObject
        }
    }

    private var theSubject: String = ""
    var label: String? {
        didSet {
            self.theSubject = self.label ?? ""
            self.modalTitleL.text = self.theSubject
        }
    }
    
    private var theType: EntityType?
    var entity: EntityType? {
        didSet {
            self.theType = entity ?? .residence
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        accessoryType = selected ? .checkmark : .none
    }
    
}
