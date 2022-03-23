//
//  Onboard1.swift
//  dashboard
//
//  Created by DuRand Jones on 10/11/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

class Onboard1: UIView, UITextViewDelegate {

    @IBOutlet var backgroundIV: UIImageView!
    @IBOutlet var logoHeaderIV: UIImageView!
    @IBOutlet var subjectL: UILabel!
    @IBOutlet var descriptionL: UILabel!
    @IBOutlet var contentView:UIView?
    let body:BodyText = .onboard1

    override init(frame: CGRect) {
        super.init(frame: frame)
        awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        awakeFromNib()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.descriptionL.text = body.rawValue
    }
    
    
    
}
