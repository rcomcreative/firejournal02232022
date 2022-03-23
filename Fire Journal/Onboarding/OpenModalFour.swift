//
//  OpenModalFour.swift
//  dashboard
//
//  Created by DuRand Jones on 10/9/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

class OpenModalFour: UIView {
    
    
    @IBOutlet weak var backgroundIV: UIImageView!
    @IBOutlet weak var headerIV: UIImageView!
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var descriptionL: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        roundViews()
    }
    
    func roundViews() {
        self.layer.cornerRadius = 20
        self.clipsToBounds = true
    }
    
}
