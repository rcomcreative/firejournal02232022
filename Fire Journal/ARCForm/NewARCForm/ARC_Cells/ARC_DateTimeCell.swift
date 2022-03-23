//
//  ARC_DateTimeCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 6/12/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol ARC_DateTimeCellDelegate: AnyObject {
    func theTimeBTapped(tag: Int)
}

class ARC_DateTimeCell: UITableViewCell {
    
//    MARK: -OBJECTS-
    @IBOutlet weak var dateL: UILabel!
    @IBOutlet weak var dateTF: UITextField!
    @IBOutlet weak var timeB: UIButton!
    
//    MARK: -PROPERTIES-
    
    private var dateName = ""
    var dName: String? {
        didSet {
            self.dateName = self.dName ?? ""
            self.dateL.text = self.dateName
        }
    }
    
    private var dateText = ""
    var dateT: String? {
        didSet {
            self.dateText = self.dateT ?? ""
            self.dateTF.text = self.dateText
        }
    }
    
    private var indexPath = IndexPath(item: 0, section: 0)
    var path: IndexPath? {
        didSet {
            self.indexPath = self.path ?? IndexPath(item: 0, section: 0)
        }
    }
    
    
    weak var delegate: ARC_DateTimeCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func timeBTapped(_ sender: Any) {
        delegate?.theTimeBTapped(tag: self.tag )
    }
    
}
