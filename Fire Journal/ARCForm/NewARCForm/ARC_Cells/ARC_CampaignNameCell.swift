//
//  ARC_CampaignNameCell.swift
//  FJ ARC Plus
//
//  Created by DuRand Jones on 9/8/20.
//  Copyright © 2020 com.purecommand.FJARCPlus. All rights reserved.
//

import UIKit
import Foundation

protocol  ARC_CampaignNameCellDelegate: AnyObject {
    func campaignNameCreateBTapped(name: String, path: IndexPath)
}


class ARC_CampaignNameCell: UITableViewCell {
    
//    MARK: -OBJECTS-
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var campaignTF: UITextField!
    @IBOutlet weak var createB: UIButton!
    
//    MARK: -PROPERTIES-
    
    weak var delegate: ARC_CampaignNameCellDelegate? = nil
    
    private var indexPath = IndexPath(item: 0, section: 0)
    var path: IndexPath? {
        didSet {
            self.indexPath = self.path ?? IndexPath(item: 0, section: 0)
        }
    }
    
    private var theName: String = ""
    var campaignName: String? {
        didSet {
            self.theName = self.campaignName ?? ""
        }
    }
    
    private var theSubject: String = ""
    var subject: String? {
        didSet {
            self.theSubject = subject ?? ""
            self.subjectL.text = self.theSubject
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        createB.layer.cornerRadius = 8
        createB.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func createBTapped(_ sender: Any) {
       _ = self.textFieldShouldEndEditing(self.campaignTF)
        delegate?.campaignNameCreateBTapped(name: theName, path: indexPath)
    }
    
    
}

extension ARC_CampaignNameCell: UITextFieldDelegate {
    
//    MARK: -TEXTFIELD DELEGATE-
    func textFieldDidBeginEditing(_ textField: UITextField) {
       if let text = textField.text {
            campaignName = text
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            campaignName = text
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let text = textField.text {
          campaignName = text
        }
        return true
    }
}
