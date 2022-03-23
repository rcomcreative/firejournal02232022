//
//  NewModalHeaderV.swift
//  StationCommand
//
//  Created by DuRand Jones on 4/16/21.
//

import UIKit

protocol NewModalHeaderVDelegate: AnyObject {
    func modalSaveBTapped(_ theView: TheViews)
    func modalCloseBTapped()
    func theInfoBTapped()
}

class NewModalHeaderV: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var closeB: UIButton!
    @IBOutlet weak var newTitle: UILabel!
    @IBOutlet weak var saveB: UIButton!
    @IBOutlet weak var infoB: UIButton!
    var theTitleL = UILabel()
    
    private var theViews: TheViews = .incident
    var theView: TheViews = .incident {
        didSet {
            self.theViews = theView
        }
    }
    
    private var theNewTitle: String = ""
    var theTitle: String = ""
    
    weak var delegate: NewModalHeaderVDelegate? = nil
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }
    
    private func setUpView() {
        
        theTitleL.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(theTitleL)
        theTitleL.font = .systemFont(ofSize: 24  )
        theTitleL.textColor = .white
        theTitleL.adjustsFontForContentSizeCategory = false
        theTitleL.textAlignment = .center
        NSLayoutConstraint.activate([
            theTitleL.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 147),
            theTitleL.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -147),
            theTitleL.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            theTitleL.heightAnchor.constraint(equalToConstant: 35)
            ])
    }
    
    func configureTheLabel() {
        theTitleL.text = theTitle
        theTitleL.setNeedsDisplay()
    }
    
    @IBAction func closeBTapped(_ sender: UIButton) {
        delegate?.modalCloseBTapped()
    }
    
    @IBAction func saveBTapped(_ sender: UIButton) {
        delegate?.modalSaveBTapped(theViews)
    }
    
    @IBAction func infoBTapped(_ sender: Any) {
        delegate?.theInfoBTapped()
    }
}
