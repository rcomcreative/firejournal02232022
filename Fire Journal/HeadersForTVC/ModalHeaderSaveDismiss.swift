//
//  ModalHeaderSaveDismiss.swift
//  Fire Journal
//
//  Created by DuRand Jones on 2/15/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol ModalHeaderSaveDismissDelegate: AnyObject {
    func modalDismiss()
    func modalSave(myShift: MenuItems)
    func modalInfoBTapped(myShift: MenuItems)
}

class ModalHeaderSaveDismiss: UIView {
    @IBOutlet weak var modalHCancelB: UIButton!
    @IBOutlet weak var modalHSaveB: UIButton!
    @IBOutlet weak var modalHTitleL: UILabel!
    var myShift: MenuItems!
    weak var delegate:ModalHeaderSaveDismissDelegate? = nil
    @IBOutlet weak var infoB: UIButton!
    
    
    @IBOutlet weak var contentView: UIView!
    
    @IBAction func modalHDismissTapped(_ sender: UIButton) {
        delegate?.modalDismiss()
    }
    
    @IBAction func modalHSaveTapped(_ sender: Any) {
        delegate?.modalSave(myShift: myShift)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @IBAction func infoBTapped(_ sender: UIButton) {
        delegate?.modalInfoBTapped(myShift: MenuItems.incidents)
    }
    
}
