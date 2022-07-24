//
//  FormHeaderV.swift
//  FJ ARC Plus
//
//  Created by DuRand Jones on 8/25/20.
//  Copyright © 2020 com.purecommand.FireJournal. All rights reserved.
//

import UIKit

protocol FormHeaderDelegate: AnyObject {
    func formBackBTapped()
    func formSaveBTapped()
    func formNewBTapped()
}

class FormHeaderV: UIView {
    
//    MARK: -OBJECTS-
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backB: UIButton!
    @IBOutlet weak var newFormB: UIButton!
    @IBOutlet weak var saveB: UIButton!
    
//    MARK: -PROPERTIES-
    weak var delegate: FormHeaderDelegate? = nil
    
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
        delegate?.formBackBTapped()
    }
    @IBAction func newFormBTapped(_ sender: Any) {
        delegate?.formNewBTapped()
    }
    @IBAction func saveBTapped(_ sender: Any) {
        delegate?.formSaveBTapped()
    }
    

}
