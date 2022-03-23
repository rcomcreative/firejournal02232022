//
//  RelieveSupervisorContactsHeaderV.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/4/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol RelieveSupervisorContactsHeaderVDelegate: AnyObject {
    func relieveSupervisorContactsSaveBTapped()
    func relieveSupervisorContactsCancelBTapped()
    func relieveSupervisorContactsInfoBTapped()
}

class RelieveSupervisorContactsHeaderV: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backgroundIV: UIImageView!
    @IBOutlet weak var iconIV: UIImageView!
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var contactsSaveB: UIButton!
    @IBOutlet weak var contactsCancelB: UIButton!
    @IBOutlet weak var contactsInfoB: UIButton!
    weak var delegate: RelieveSupervisorContactsHeaderVDelegate? = nil
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBAction func contactsInfoBTapped(_ sender: Any) {
        delegate?.relieveSupervisorContactsInfoBTapped()
    }
    @IBAction func contactsSaveBTapped(_ sender: Any) {
        delegate?.relieveSupervisorContactsSaveBTapped()
    }
    @IBAction func contactsCancelBTapped(_ sender: Any) {
        delegate?.relieveSupervisorContactsCancelBTapped()
    }
    
}
