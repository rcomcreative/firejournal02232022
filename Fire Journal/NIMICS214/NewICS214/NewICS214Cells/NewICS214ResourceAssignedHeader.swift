//
//  NewICS214ResourceAssignedHeader.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/14/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol NewICS214ResourceAssignedHeaderDelegate:AnyObject {
    func NewICS214ResourceAssignedHeaderCancelTapped()
    func NewICS214ResourceAssignedHeaderSaveTapped()
    func NewICS214ResourceAssignedHeaderInfoTapped()
}

class NewICS214ResourceAssignedHeader: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var saveB: UIButton!
    @IBOutlet weak var cancelB: UIButton!
    @IBOutlet weak var infoB: UIButton!
    @IBOutlet weak var SubjectL: UILabel!
    @IBOutlet weak var backgroundV: UIImageView!
    
    weak var delegate: NewICS214ResourceAssignedHeaderDelegate? = nil
    
    @IBAction func saveBtapped(_ sender: Any) {
        delegate?.NewICS214ResourceAssignedHeaderSaveTapped()
    }
    @IBAction func cancelBTapped(_ sender: Any) {
        delegate?.NewICS214ResourceAssignedHeaderCancelTapped()
    }
    @IBAction func infoBTapped(_ sender: Any) {
        delegate?.NewICS214ResourceAssignedHeaderInfoTapped()
    }
    
}
