//
//  ContactListCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 9/12/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

class ContactListCell: UITableViewCell {
    
    @IBOutlet weak var contactIV: UIImageView!
    @IBOutlet weak var contact1L: UILabel!
    @IBOutlet weak var contact2L: UILabel!
    @IBOutlet weak var contact3L: UILabel!
    @IBOutlet weak var contact1TF: UITextField!
    @IBOutlet weak var contact2TF: UITextField!
    @IBOutlet weak var contact3TF: UITextField!
    @IBOutlet weak var contactChosenIV: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCircularAvatar() {
        contactIV.layer.cornerRadius = contactIV.bounds.size.width / 2.0
        contactIV.layer.masksToBounds = true
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        setCircularAvatar()
    }
    
    func configureWithContactEntry(_ contact: ContactChosen) {
        contact1TF.text = contact.name
        contact3TF.text = contact.email ?? ""
        contact2TF.text = contact.phone ?? ""
        contactIV.image = contact.image ?? UIImage(named: "ContactsIcon")
        contactChosenIV.image = UIImage(named:"addContact")
        contactChosenIV.isHidden = true
        contactChosenIV.alpha = 0.0
        setCircularAvatar()
    }
    
}
