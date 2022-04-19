//
//  OnboardHeaderV.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/13/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol OnboardHeaderVDelegate: AnyObject {
    func theOnboardSaveBTapped()
    func theOnboardInfoBTapped()
}

class OnboardHeaderV: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var headerIconIV: UIImageView!
    @IBOutlet weak var infoB: UIButton!
    @IBOutlet weak var submitB: UIButton!
    
    weak var delegate: OnboardHeaderVDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
   
    @IBAction func saveBTapped(_ sender: Any) {
        delegate?.theOnboardSaveBTapped()
    }
    
    @IBAction func infoBTapped(_ sender: Any) {
        delegate?.theOnboardInfoBTapped()
    }
    
}
