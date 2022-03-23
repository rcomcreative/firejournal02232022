//
//  NFIRSLabelTimeButtonCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/9/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol NFIRSLabelTimeButtonDelegate: AnyObject {
    func nfirsTimeBTapped(type: IncidentTypes)
}

class NFIRSLabelTimeButtonCell: UITableViewCell {
    
    //    MARK: -Objects
    @IBOutlet weak var dateTimeTF: UITextField!
    @IBOutlet weak var dateTimeL: UILabel!
    @IBOutlet weak var dateTimeB: UIButton!
    //    MARK: -Properties
    var dateBTappedB:Bool = false
    var alarmSameB:Bool = false
    var type:IncidentTypes!
    weak var delegate:NFIRSLabelTimeButtonDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func timeBTapped(_ sender: Any) {
        delegate?.nfirsTimeBTapped(type: type)
    }
    
    
}
