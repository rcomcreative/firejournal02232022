//
//  ResourceAndCrewView.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/5/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol ResourceAndCrewViewDelegate: class {
    func theResourceCrewBTapped()
}

class ResourceAndCrewView: UIView {
    
    //    MARK: -Objects-
    @IBOutlet weak var resourceIconIV: UIImageView!
    @IBOutlet weak var resourceStatusIV: UIImageView!
    @IBOutlet weak var crew1L: UILabel!
    @IBOutlet weak var crew2L: UILabel!
    @IBOutlet weak var crew3L: UILabel!
    @IBOutlet weak var crew4L: UILabel!
    @IBOutlet weak var crew5L: UILabel!
    @IBOutlet weak var crew6L: UILabel!
    @IBOutlet weak var crewB: UIButton!
    
    //    MARK: -Properties
    weak var delegate: ResourceAndCrewViewDelegate? = nil
    
   override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func updateCrewBTapped(_ sender: Any) {
        delegate?.theResourceCrewBTapped()
    }
    

}
