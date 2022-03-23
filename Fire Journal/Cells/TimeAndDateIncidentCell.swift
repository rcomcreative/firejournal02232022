//
//  TimeAndDateIncidentCell.swift
//  dashboard
//
//  Created by DuRand Jones on 9/11/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol TimeAndDateIncidentCellDelegate: AnyObject {
    func theTimeBWasTapped(incidentType: IncidentTypes)
    func theNotesBWasTapped(incidentType: IncidentTypes)
}

class TimeAndDateIncidentCell: UITableViewCell {
    //    MARK: -objects
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var monthL: UILabel!
    @IBOutlet weak var dayL: UILabel!
    @IBOutlet weak var yearL: UILabel!
    @IBOutlet weak var hourL: UILabel!
    @IBOutlet weak var minutesL: UILabel!
    @IBOutlet weak var clockB: UIButton!
    @IBOutlet weak var notesB: UIButton!
    @IBOutlet weak var timeAndDateTF: UITextField!
    
    //    MARK: -PROPERTIES
    var incidentType: IncidentTypes!
    weak var delegate:TimeAndDateIncidentCellDelegate? = nil

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
        delegate?.theTimeBWasTapped(incidentType: incidentType)
    }
    @IBAction func notesBTapped(_ sender: Any) {
        delegate?.theNotesBWasTapped(incidentType: incidentType)
    }
    
    
}
