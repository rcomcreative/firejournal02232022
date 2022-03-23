//
//  CellHeader.swift
//  dashboard
//
//  Created by DuRand Jones on 9/18/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol CellHeaderDelegate: AnyObject {
    func theCancelModalDataTapped()
}

class CellHeader: UIView {
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var titleHeader: UILabel!
    @IBOutlet weak var contentView: UIView!
    weak var delegate: CellHeaderDelegate? = nil
    @IBOutlet weak var backgroundV: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        commonInit()
    }
    
//    private func commonInit() {
//        Bundle.main.loadNibNamed("CellHeader", owner: self, options: nil)
//        addSubview(contentView)
//        contentView.frame = self.bounds
//        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
//    }
    
    @IBAction func cancelBTapped(_ sender: Any) {
        delegate?.theCancelModalDataTapped()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
