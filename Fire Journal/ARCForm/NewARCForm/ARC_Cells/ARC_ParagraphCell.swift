//
//  ARC_ParagraphCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 10/24/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

class ARC_ParagraphCell: UITableViewCell {

//    MARK: -OBJECTS-
    @IBOutlet weak var header1L: UILabel!
    @IBOutlet weak var paragraph1L: UILabel!
    @IBOutlet weak var header2L: UILabel!
    @IBOutlet weak var paragraph2L: UILabel!
    @IBOutlet weak var header3L: UILabel!
    @IBOutlet weak var paragraph3L: UILabel!
    
//    MARK: -PROPERTIES-
    
    
    private var indexPath = IndexPath(item: 0, section: 0)
    var path: IndexPath? {
        didSet {
            self.indexPath = self.path ?? IndexPath(item: 0, section: 0)
        }
    }
    
    private var header1: String = ""
    var headerOne: String? {
        didSet {
            self.header1 = self.headerOne ?? ""
            self.header1L.text = self.header1
        }
    }
    
    private var header2: String = ""
    var headerTwo: String? {
        didSet {
            self.header2 = self.headerTwo ?? ""
            self.header2L.text = self.header2
        }
    }
    
    private var header3: String = ""
    var headerThree: String? {
        didSet {
            self.header3 = self.headerThree ?? ""
            self.header3L.text = self.header3
        }
    }
    
    private var paragraph1: String = ""
    var paragraphOne: String? {
        didSet {
            self.paragraph1 = self.paragraphOne ?? ""
            self.paragraph1L.text = self.paragraph1
        }
    }
    
    private var paragraph2: String = ""
    var paragraphTwo: String? {
        didSet {
            self.paragraph2 = self.paragraphTwo ?? ""
            self.paragraph2L.text = self.paragraph2
        }
    }
    
    private var paragraph3: String = ""
    var paragraphThree: String? {
        didSet {
            self.paragraph3 = self.paragraphThree ?? ""
            self.paragraph3L.text = self.paragraph3
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
