//
//  ResourceHeader.swift
//  DashboardTest
//
//  Created by DuRand Jones on 2/3/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol ResourceHeaderDelegate: AnyObject {
    func resourceSaveBTapped()
    func resourceCancelBTapped()
    func resourceInfoBTapped()
}

class ResourceHeader: UIView {

//    MARK: -OBJECTS-
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backgroundIV: UIImageView!
    @IBOutlet weak var resourceStatusIV: UIImageView!
    @IBOutlet weak var resourceIconIV: UIImageView!
    @IBOutlet weak var resourceCustomL: UILabel!
    @IBOutlet weak var resourceSaveB: UIButton!
    @IBOutlet weak var resourceCancelB: UIButton!
    @IBOutlet weak var resourceInfoB: UIButton!
    
//    MARK: -PROPERTIES-
    weak var delegate: ResourceHeaderDelegate? = nil
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
//    MARK: -ACTIONS-
    @IBAction func resourceSaveBTapped(_ sender: Any) {
        delegate?.resourceSaveBTapped()
    }
    @IBAction func resourceCancelBTapped(_ sender: Any) {
        delegate?.resourceCancelBTapped()
    }
    @IBAction func resourceInfoBTapped(_ sender: Any) {
        delegate?.resourceInfoBTapped()
    }
    

}
