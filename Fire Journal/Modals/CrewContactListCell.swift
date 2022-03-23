//
//  CrewContactListCell.swift
//  dashboard
//
//  Created by DuRand Jones on 10/26/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class CrewContactListCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var contactIV: UIImageView!
    @IBOutlet weak var contact1L: UILabel!
    @IBOutlet weak var contact2L: UILabel!
    @IBOutlet weak var contact3L: UILabel!
    @IBOutlet weak var contact1TF: UITextField!
    @IBOutlet weak var contact2TF: UITextField!
    @IBOutlet weak var contact3TF: UITextField!
    
    var contact: ContactChosen? {
        didSet {
            contact1TF.text = contact?.name ?? ""
            contact2TF.text = contact?.phone ?? ""
            contact3TF.text = contact?.email ?? ""
            let image = contact?.image ?? UIImage(named: "ContactsIcon")
            contactIV.image = image
            setCircularAvatar()
        }
    }
    
    var contact2: CNContact? {
        didSet {
            let fname = contact2?.givenName ?? ""
            let lname = contact2?.familyName ?? ""
            contact1TF.text = "\(fname) \(lname)"
            if let email = contact2?.emailAddresses.first?.value {
                contact2TF.text = email as String
            }
            if let phone = contact2?.phoneNumbers.first?.value {
                contact3TF.text = phone.stringValue
            }
            
            let image = UIImage(named: "ContactsIcon")
            contactIV.image = image
            setCircularAvatar()
            
            if contact2?.imageDataAvailable ?? false {
                if let data = contact2?.thumbnailImageData {
                    let image = UIImage(data: data)
                    contactIV.image = image
                    setCircularAvatar()
                }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
        // update UI
        accessoryType = selected ? .checkmark : .none
    }
    
    func setCircularAvatar() {
        contactIV.layer.cornerRadius = contactIV.bounds.size.width / 2.0
        contactIV.layer.masksToBounds = true
        contactIV.setNeedsDisplay()
    }
    
}
