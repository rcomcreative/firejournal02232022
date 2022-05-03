//
//  OnboardTenVC.swift
//  dashboard
//
//  Created by DuRand Jones on 10/12/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

class OnboardTenVC: UIViewController {
    
    @IBOutlet weak var backgroundIV: UIImageView!
    @IBOutlet weak var logoHeaderIV: UIImageView!
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var descriptionL: UILabel!
    let body:BodyText = .onboard10
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
    }

}
