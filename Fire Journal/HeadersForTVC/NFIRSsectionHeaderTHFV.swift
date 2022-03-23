//
//  NFIRSsectionHeaderTHFV.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/19/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol NFIRSsectionHeaderTHFVDelegate: AnyObject {
    func theSectionBTapped(header: NFIRSsectionHeaderTHFV,section: Int, collapsed: Bool, rowCount: Int)
}

class NFIRSsectionHeaderTHFV: UITableViewHeaderFooterView {

    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var descriptionL: UILabel!
    @IBOutlet weak var sectionB: UIButton!
    @IBOutlet weak var openCloseSwitch: UISwitch!
    
    var title:String = ""
    var modDescription:String = ""
    var section: Int = 0
    weak var delegate:NFIRSsectionHeaderTHFVDelegate? = nil
    var collapsed: Bool = true
    var rowCount: Int = 0
    @IBOutlet weak var collapsedB: UIButton!
    @IBOutlet weak var openCloseL: UILabel!
    
    var theSection: NFIRSSection? {
        didSet {
            guard let theSection = theSection else {
                return
            }
            titleL?.text = theSection.sectionTitle
            descriptionL?.text = theSection.sectionDescription
            section = theSection.section
            rowCount = theSection.rowCount
            setCollapsed(collapsed: theSection.isCollapsed)
        }
    }
    
    @IBAction func openCloseSwitchTapped(_ sender: UISwitch) {
        delegate?.theSectionBTapped(header: self, section: section, collapsed: collapsed, rowCount: rowCount)
    }
    
    @IBAction func sectionBTapped(_ sender: Any) {
        delegate?.theSectionBTapped(header: self, section: section, collapsed: collapsed, rowCount: rowCount)
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        openCloseSwitch.setOn(false, animated: true)
        openCloseSwitch.onTintColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1)
        openCloseSwitch.backgroundColor = UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 0.15)
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

    
    func setCollapsed(collapsed: Bool) {
        self.collapsed = collapsed
        if collapsed {
            openCloseL.text = "Open"
        } else {
            openCloseL.text = "Close"
        }
    }

}

//extension UIButton {
//    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.2) {
//        let animation = CABasicAnimation(keyPath: "transform.rotation")
//        
//        animation.toValue = toValue
//        animation.duration = duration
//        animation.isRemovedOnCompletion = false
//        animation.fillMode = CAMediaTimingFillMode.forwards
//        
//        self.layer.add(animation, forKey: nil)
//    }
//}
