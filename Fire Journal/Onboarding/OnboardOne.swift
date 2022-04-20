//
//  OnboardOne.swift
//  dashboard
//
//  Created by DuRand Jones on 10/11/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

class OnboardOne: UIViewController {

    @IBOutlet weak var backgroundIV: UIImageView!
    @IBOutlet weak var logoHeaderIV: UIImageView!
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var descriptionL: UILabel!
    let body: BodyText = .onboard1
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        let attributedParagraph:NSMutableParagraphStyle = NSMutableParagraphStyle.init()
        attributedParagraph.lineSpacing = 9
        let attributedString:NSAttributedString = NSAttributedString.init(string: body.rawValue, attributes: [NSAttributedString.Key.paragraphStyle: attributedParagraph])
        descriptionL.attributedText = attributedString
        descriptionL.lineBreakMode = NSLineBreakMode.byWordWrapping
        descriptionL.numberOfLines = 0
        descriptionL.setNeedsDisplay()
    }
    

}
