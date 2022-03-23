//
//  MapInfoVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 2/26/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol MapInfoVCDelegate: AnyObject {
    func segmentChosen(type: Int)
    func allIncidentsTapped()
    func fireIncidentsTapped()
    func emsIncidentsTapped()
    func rescueIncidentsTapped()
    func ics214Tapped()
    func arcFormsTapped()
    func mapInfoCancelTapped()
}

class MapInfoVC: UIViewController {
    
//    MARK: -OBJECTS-
    @IBOutlet weak var mapInfoV: UIView!
    @IBOutlet weak var mapInfoSegment: UISegmentedControl!
    @IBOutlet weak var allIncidentSmB: UIButton!
    @IBOutlet weak var allIncidentB: UIButton!
    @IBOutlet weak var fireIncidentSmB: UIButton!
    @IBOutlet weak var fireIncidentB: UIButton!
    @IBOutlet weak var emsIncidentSmB: UIButton!
    @IBOutlet weak var emsIncidentB: UIButton!
    @IBOutlet weak var rescueIncidentSmB: UIButton!
    @IBOutlet weak var rescueIncidentB: UIButton!
    @IBOutlet weak var ics214SmB: UIButton!
    @IBOutlet weak var ics214B: UIButton!
    @IBOutlet weak var arcFormSmB: UIButton!
    @IBOutlet weak var arcFormB: UIButton!
    @IBOutlet weak var mapInfoCancelB: UIButton!
    @IBOutlet weak var arcFormL: UILabel!
    
//    MARK: -PROPERTIES-
    weak var delegate: MapInfoVCDelegate? = nil
    var type: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapInfoSegment.selectedSegmentIndex = type
        // Do any additional setup after loading the view.
        roundViews()
    }
    
    func roundViews() {
        self.view.layer.cornerRadius = 0
        self.view.clipsToBounds = true
        mapInfoV.layer.cornerRadius = 20
        mapInfoV.clipsToBounds = true
    }
    
    override func viewWillLayoutSubviews() {
        allIncidentSmB.setBackgroundImage(BuildButtons.allIncidentsIcon, for: .normal)
        fireIncidentSmB.setBackgroundImage(BuildButtons.fireIncidentsIcon, for: .normal)
        emsIncidentSmB.setBackgroundImage(BuildButtons.emsIncidentsIcon, for: .normal)
        rescueIncidentSmB.setBackgroundImage(BuildButtons.rescueIncidentsIcon, for: .normal)
        ics214SmB.setBackgroundImage(BuildButtons.ics214Icon, for: .normal)
        arcFormSmB.setBackgroundImage(BuildButtons.ARCFormIcon, for: .normal)
        if Device.IS_IPHONE {
            arcFormB.isHidden = true
            arcFormB.isEnabled = false
            arcFormB.alpha = 0.0
            arcFormSmB.isHidden = true
            arcFormSmB.isEnabled = false
            arcFormSmB.alpha = 0.0
            arcFormL.alpha = 0.0
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
//    MARK: -ACTIONS-
    @IBAction func mapInfoSegmentTapped(_ sender: UISegmentedControl) {
        switch mapInfoSegment.selectedSegmentIndex
        {
        case 0:
            type = 0
        case 1:
            type = 1
        case 2:
            type = 2
        default:
            type = 0
        }
        delegate?.segmentChosen(type: type)
    }
    @IBAction func allIncidentsBTapped(_ sender: Any) {
        delegate?.allIncidentsTapped()
    }
    @IBAction func fireIncidentBTapped(_ sender: Any) {
        delegate?.fireIncidentsTapped()
    }
    @IBAction func emsIncidentsBTapped(_ sender: Any) {
        delegate?.emsIncidentsTapped()
    }
    @IBAction func rescueIncidentsBTapped(_ sender: Any) {
        delegate?.rescueIncidentsTapped()
    }
    @IBAction func ics214BTapped(_ sender: Any) {
        delegate?.ics214Tapped()
    }
    @IBAction func arcFormBTapped(_ sender: Any) {
        delegate?.arcFormsTapped()
    }
    @IBAction func mapInfoCancelTapped(_ sender: Any) {
        delegate?.mapInfoCancelTapped()
    }
    
    
}
