//
//  ARC_DateTimeAdminCell.swift
//  FJ ARC Plus
//
//  Created by DuRand Jones on 8/26/20.
//  Copyright © 2020 com.purecommand.FJARCPlus. All rights reserved.
//

import UIKit
import Foundation

protocol DateTimeAdminDelegate: AnyObject {
    func dateTimeAdminTimeBTapped(index: IndexPath, tag: Int)
}

class ARC_DateTimeAdminCell: UITableViewCell {
    
//    MARK: -OBJECTS-
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var inputTF: UITextField!
    @IBOutlet weak var timeB: UIButton!
    
//    MARK: -PROPERTIES-
    weak var delegate: DateTimeAdminDelegate? = nil
    
    private var indexPath = IndexPath(item: 0, section: 0)
    var path: IndexPath? {
        didSet {
            self.indexPath = self.path ?? IndexPath(item: 0, section: 0)
        }
    }
    
    private var theDescription = ""
    var described: String? {
        didSet {
            self.theDescription = self.described ?? ""
            self.inputTF.text = self.theDescription
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
    
    @IBAction func timeBTapped(_ sender: Any) {
        delegate?.dateTimeAdminTimeBTapped(index: indexPath, tag: self.tag)
    }
    
    
}
