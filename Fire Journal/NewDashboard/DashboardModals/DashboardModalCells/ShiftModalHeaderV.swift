//
//  ShiftModalHeaderV.swift
//  DashboardTest
//
//  Created by DuRand Jones on 1/28/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol ShiftModalHeaderVDelegate:AnyObject {
    func shiftModalSaveBTapped()
    func shiftModalCancelBTapped()
    func shiftModalInfoBTapped()
}

class ShiftModalHeaderV: UIView {
    
//    MARK: -PROPERTIES-
    @IBOutlet weak var backgroundIV: UIImageView!
    @IBOutlet weak var iconIV: UIImageView!
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var infoB: UIButton!
    @IBOutlet weak var cancelB: UIButton!
    @IBOutlet weak var saveB: UIButton!
    weak var delegate: ShiftModalHeaderVDelegate? = nil
    
    @IBOutlet weak var contentView: UIView!
    

    private var theTitle: String = ""
    var aTitle: String = "" {
        didSet {
            self.theTitle = self.aTitle
            self.subjectL.text = self.theTitle
        }
    }
    
    


    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
//    MARK: -ACTIONS-
    @IBAction func saveBTapped(_ sender: Any) {
        delegate?.shiftModalSaveBTapped()
    }
    @IBAction func cancelBTapped(_ sender: Any) {
        delegate?.shiftModalCancelBTapped()
    }
    @IBAction func infoBTapped(_ sender: Any) {
        delegate?.shiftModalInfoBTapped()
    }

}
