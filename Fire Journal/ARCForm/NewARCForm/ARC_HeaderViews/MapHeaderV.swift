//
//  MapHeaderV.swift
//  FJ ARC Plus
//
//  Created by DuRand Jones on 8/25/20.
//  Copyright © 2020 com.purecommand.FireJournal. All rights reserved.
//

import UIKit

protocol MapHeaderDelegate: AnyObject {
    func theBackButtonTapped()
    func theNewFormTapped()
}

class MapHeaderV: UIView {
    
//    MARK: -OBJECTS-
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backB: UIButton!
    @IBOutlet weak var addNewB: UIButton!
    
//    MARK: -PROPERTIES-
    weak var delegate: MapHeaderDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
    }
    
    @IBAction func backBTapped(_ sender: Any) {
        delegate?.theBackButtonTapped()
    }
    
    @IBAction func addNewBTapped(_ sender: Any) {
        delegate?.theNewFormTapped()
    }
    
}
