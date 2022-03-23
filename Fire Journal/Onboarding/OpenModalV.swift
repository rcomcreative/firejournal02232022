//
//  OpenModalV.swift
//  dashboard
//
//  Created by DuRand Jones on 10/8/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

class OpenModalV: UIView {
    
    @IBOutlet weak var backgroundIV: UIImageView!
    @IBOutlet weak var headerIV: UIImageView!
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var descriptionL: UILabel!
    @IBOutlet weak var contentView: UIView!
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("OpenModalV", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        roundViews()
    }
    
    func roundViews() {
        self.layer.cornerRadius = 20
        self.clipsToBounds = true
    }
    
}
