//
//  SettingsMyResourcesHeaderV.swift
//  DashboardTest
//
//  Created by DuRand Jones on 2/5/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol SettingsMyResourcesHeaderVDelegate: AnyObject {
    func myResourcesInfoBTapped()
}

class SettingsMyResourcesHeaderV: UIView {

//    MARK: -OBJECTS-
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var myResourcesIconIV: UIImageView!
    @IBOutlet weak var myResourcesTitleL: UILabel!
    @IBOutlet weak var infoB: UIButton!
    @IBOutlet weak var backgroundV: UIView!
    
//    MARK: -PROPERTIES-
    weak var delegate: SettingsMyResourcesHeaderVDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func infoBTapped(_ sender: Any) {
        delegate?.myResourcesInfoBTapped()
    }
    

}
