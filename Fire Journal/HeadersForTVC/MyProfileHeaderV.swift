//
//  MyProfileHeaderV.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/23/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol MyProfileHeaderVDelegate: AnyObject {
    func myProfileHeaderInfoBTapped()
}

class MyProfileHeaderV: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var colorV: UIView!
    @IBOutlet weak var subjetL: UILabel!
    @IBOutlet weak var descriptionTV: UITextView!
    @IBOutlet weak var infoB: UIButton!
    
//    MARK: -PROPERTIES-
    weak var delegate: MyProfileHeaderVDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func infoBTapped(_ sender: Any) {
        delegate?.myProfileHeaderInfoBTapped()
    }
    
}
