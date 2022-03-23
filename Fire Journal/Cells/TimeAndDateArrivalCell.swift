//
//  TimeAndDateArrivalCell.swift
//  dashboard
//
//  Created by DuRand Jones on 9/11/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol TimeAndDateArrivalCellDelegate: AnyObject {
    func alarmTimeBTapped(incidentType:IncidentTypes)
    func alarmNotesBTapped(incidentType:IncidentTypes)
}

class TimeAndDateArrivalCell: UITableViewCell {
    //    MARK: -objects
    @IBOutlet weak var timeB: UIButton!
    @IBOutlet weak var noteB: UIButton!
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var monthL: UILabel!
    @IBOutlet weak var dayL: UILabel!
    @IBOutlet weak var yearL: UILabel!
    @IBOutlet weak var hourL: UILabel!
    @IBOutlet weak var minuteL: UILabel!
    @IBOutlet weak var timeDateTF: UITextField!
    //    MARK: -PROPERTIES
    var incidentType:IncidentTypes!
    weak var delegate:TimeAndDateArrivalCellDelegate? = nil
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func clockBTapped(_ sender: Any) {
        delegate?.alarmTimeBTapped(incidentType: incidentType)
    }
    @IBAction func noteBTapped(_ sender: Any) {
        delegate?.alarmNotesBTapped(incidentType: incidentType)
    }
    
    
    
}
