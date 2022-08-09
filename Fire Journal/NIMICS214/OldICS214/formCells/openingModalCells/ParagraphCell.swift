//
//  ParagraphCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 10/24/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

class ParagraphCell: UITableViewCell {

    @IBOutlet weak var header1L: UILabel!
    @IBOutlet weak var paragraph1L: UILabel!
    @IBOutlet weak var header2L: UILabel!
    @IBOutlet weak var paragraph2L: UILabel!
    @IBOutlet weak var header3L: UILabel!
    @IBOutlet weak var paragraph3L: UILabel!
    
    private var theHeader1Text: String = ""
    var header1Text: String = "" {
        didSet {
            self.theHeader1Text = self.header1Text
            self.header1L.text = self.theHeader1Text
        }
    }
    
    private var theHeader2Text: String = ""
    var header2Text: String = "" {
        didSet {
            self.theHeader2Text = self.header2Text
            self.header2L.text = self.theHeader2Text
        }
    }
    
    private var theHeader3Text: String = ""
    var header3Text: String = "" {
        didSet {
            self.theHeader3Text = self.header3Text
            self.header3L.text = self.theHeader3Text
        }
    }
    
    private var theParagraph1Text: String = ""
    var paragraph1Text: String = "" {
        didSet {
            self.theParagraph1Text = self.paragraph1Text
            self.paragraph1L.text = self.theParagraph1Text
        }
    }
    
    private var theParagraph2Text: String = ""
    var paragraph2Text: String = "" {
        didSet {
            self.theParagraph2Text = self.paragraph2Text
            self.paragraph2L.text = self.theParagraph2Text
        }
    }
    
    private var theParagraph3Text: String = ""
    var paragraph3Text: String = "" {
        didSet {
            self.theParagraph3Text = self.paragraph3Text
            self.paragraph3L.text = self.theParagraph3Text
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
