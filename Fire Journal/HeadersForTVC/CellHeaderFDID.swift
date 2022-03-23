//
//  CellHeaderFDID.swift
//  dashboard
//
//  Created by DuRand Jones on 10/16/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol CellHeaderFDIDDelegate: AnyObject {
    func theFDIDCancelBTapped()
}

class CellHeaderFDID: UIView {

    @IBOutlet weak var cancelB: UIButton!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak internal var contentView: UIView!
    weak var delegate:CellHeaderFDIDDelegate? = nil
    
    @IBAction func cancelBTapped(_ sender: Any) {
        delegate?.theFDIDCancelBTapped()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
