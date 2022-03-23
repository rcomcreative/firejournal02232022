//
//  LabelCell.swift
//  dashboard
//
//  Created by DuRand Jones on 8/17/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit
import CoreData

protocol LabelCellDelegate: AnyObject {
    func theInfoBTapped(index: IndexPath)
}

class LabelCell: UITableViewCell {
    
    @IBOutlet weak var modalTitleL: UILabel!
    @IBOutlet weak var infoB: UIButton!
    
    var theObjectID: NSManagedObjectID! = nil
    var objectID: NSManagedObjectID! = nil {
        didSet {
            self.theObjectID = self.objectID
        }
    }
    
    var myShift: MenuItems! = nil
    weak var delegate: LabelCellDelegate? = nil
    private var theIndexPath: IndexPath = IndexPath.init(row: 0, section: 0)
    var indexPath = IndexPath.init(row: 0, section: 0) {
        didSet {
            self.theIndexPath = self.indexPath
        }
    }
    
    private var theSubject: String = ""
    var subject: String = "" {
        didSet {
            self.theSubject = self.subject
            modalTitleL.text = self.theSubject
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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

        // Configure the view for the selected state
    }
    
    @IBAction func infoBTapped(_ sender: UIButton) {
        delegate?.theInfoBTapped(index: theIndexPath)
    }
    
    
}
