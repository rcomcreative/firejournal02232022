//
//  NFIRSLabelDateTimeButtonCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/21/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol NFIRSLabelDateTimeButtonDelegate: AnyObject {
    func nfirsDateBTapped(type: IncidentTypes)
    func nfirsAlarmSameBTapped(type: IncidentTypes)
}

class NFIRSLabelDateTimeButtonCell: UITableViewCell {

    //    MARK: -Objects
    @IBOutlet weak var dateTimeTF: UITextField!
    @IBOutlet weak var dateTimeL: UILabel!
    @IBOutlet weak var dateTimeB: UIButton!
    @IBOutlet weak var sameTimeAsAlarmB:UIButton!
    //    MARK: -Properties
    var dateBTappedB:Bool = false
    var alarmSameB:Bool = false
    var type:IncidentTypes!
    weak var delegate:NFIRSLabelDateTimeButtonDelegate? = nil
    
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
        delegate?.nfirsDateBTapped(type: type)
    }
    @IBAction func alarmSameBTapped(_ sender: Any) {
        delegate?.nfirsAlarmSameBTapped(type: type)
    }
}
