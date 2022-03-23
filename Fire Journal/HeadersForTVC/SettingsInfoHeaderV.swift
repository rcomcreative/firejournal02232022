//
//  SettingsInfoHeaderV.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/26/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol SettingsInfoHeaderVDelegate: AnyObject {
    func settingsInfoBTapped()
}

class SettingsInfoHeaderV: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var colorV: UIView!
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var descriptionTV: UITextView!
    @IBOutlet weak var infoB: UIButton!
    
//    MARK: -PROPERTIES-
    weak var delegate: SettingsInfoHeaderVDelegate? = nil
    
    @IBAction func infoBTapped(_ sender: Any) {
        delegate?.settingsInfoBTapped()
    }
    
}
