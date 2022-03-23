//
//  CellHeaderCancelSave.swift
//  dashboard
//
//  Created by DuRand Jones on 10/24/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation

protocol CellHeaderCancelSaveDelegate: AnyObject {
    func cellCancelled()
    func cellSaved()
}

class CellHeaderCancelSave: UIView {
    @IBOutlet weak var cancelB: UIButton!
    @IBOutlet weak var headerTitleL: UILabel!
    @IBOutlet weak var saveB: UIButton!
    weak var delegate:CellHeaderCancelSaveDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func cancelBTapped(_ sender: Any) {
        delegate?.cellCancelled()
    }
    @IBAction func saveBTapped(_ sender: Any) {
        delegate?.cellSaved()
    }
    
}
