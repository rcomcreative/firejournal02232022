//
//  MapFormHeaderV.swift
//  Fire Journal
//
//  Created by DuRand Jones on 2/18/21.
//  Copyright © 2021 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol MapFormHeaderVDelegate: AnyObject {
    func mapFormHeaderBackBTapped(type: IncidentTypes)
    func mapFormHeaderSaveBTapped()
}

class MapFormHeaderV: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backB: UIButton!
    @IBOutlet weak var saveB: UIButton!
    
    var incidentType: IncidentTypes!
    weak var delegate: MapFormHeaderVDelegate? = nil
    
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
        delegate?.mapFormHeaderBackBTapped(type: incidentType)
    }
    
    @IBAction func saveBTapped(_ sender: Any) {
        delegate?.mapFormHeaderSaveBTapped()
    }
    
}
