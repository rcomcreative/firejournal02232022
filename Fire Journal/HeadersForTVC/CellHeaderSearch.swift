//
//  CellHeaderSearch.swift
//  dashboard
//
//  Created by DuRand Jones on 9/21/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol CellHeaderSearchDelegate: AnyObject {
    func theSearchButtonTapped(type:MenuItems)
}

class CellHeaderSearch: UIView {
    
    var myShift:MenuItems!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var titleHeader: UILabel!
    @IBOutlet weak var contentView: UIView!
    weak var delegate: CellHeaderSearchDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    @IBAction func searchBTapped(_ sender: Any) {
        delegate?.theSearchButtonTapped(type: myShift)
    }
    
}
