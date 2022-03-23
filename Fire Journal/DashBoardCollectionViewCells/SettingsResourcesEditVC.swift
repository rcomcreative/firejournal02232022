//
//  SettingsResourcesEditVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/5/19.
//  Copyright © 2019 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData


class SettingsResourcesEditVC: UIViewController {
    
//    MARK: -PROPERTIES-
var count: Int = 0
 let userDefaults = UserDefaults.standard
 var context:NSManagedObjectContext?
 let nc = NotificationCenter.default
    
//    MARK: -OBJECTS-
    @IBOutlet weak var settingsResourcesEditV: UIView!
    @IBOutlet weak var settingsResourceGradientIV: UIImageView!
    @IBOutlet weak var resourceIconIV: UIImageView!
    @IBOutlet weak var infoB: UIButton!
    @IBOutlet weak var cancelB: UIButton!
    @IBOutlet weak var saveB: UIButton!
    @IBOutlet weak var statusIV: UIImageView!
    @IBOutlet weak var statusSegment: UISegmentedControl!
    @IBOutlet weak var defaultMember1EditB: UIButton!
    @IBOutlet weak var defaultMember2EditB: UIButton!
    @IBOutlet weak var defaultMember3EditB: UIButton!
    @IBOutlet weak var defaultMember4EditB: UIButton!
    @IBOutlet weak var defaultMember5EditB: UIButton!
    @IBOutlet weak var defaultMember6EditB: UIButton!
    @IBOutlet weak var positionCountB: UIButton!
    
//    MARK: -LABELS-
    @IBOutlet weak var postionsL: UILabel!
    @IBOutlet weak var manufacturersL: UILabel!
    @IBOutlet weak var idL: UILabel!
    @IBOutlet weak var shopNumberL: UILabel!
    @IBOutlet weak var apparatusL: UILabel!
    @IBOutlet weak var specialitiesL: UILabel!
    @IBOutlet weak var descriptionL: UILabel!
    
//    MARK: -TEXTFIELDS
    @IBOutlet weak var title1TF: UITextField!
    @IBOutlet weak var defaultMember1TF: UITextField!
    @IBOutlet weak var title2TF: UITextField!
    @IBOutlet weak var defaultMember2TF: UITextField!
    @IBOutlet weak var title3TF: UITextField!
    @IBOutlet weak var defaultMember3TF: UITextField!
    @IBOutlet weak var title4TF: UITextField!
    @IBOutlet weak var defaultMember4TF: UITextField!
    @IBOutlet weak var title5TF: UITextField!
    @IBOutlet weak var defaultMember5TF: UITextField!
    @IBOutlet weak var title6TF: UITextField!
    @IBOutlet weak var defaultMember6TF: UITextField!
    @IBOutlet weak var positionTF: UITextField!
    @IBOutlet weak var manufacturerTF: UITextField!
    @IBOutlet weak var idTF: UITextField!
    @IBOutlet weak var shopNumberTF: UITextField!
    @IBOutlet weak var apparatusTF: UITextField!
    @IBOutlet weak var specialitiesTF: UITextField!
    @IBOutlet weak var descriptionTV: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

                nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
                // Do any additional setup after loading the view.
            }
            
        //     MARK: -
        //        MARK: Notification Handling
               @objc func managedObjectContextDidSave(notification: Notification) {
                   DispatchQueue.main.async {
                    self.context?.mergeChanges(fromContextDidSave: notification)
                   }
               }
    

//   MARK: -BUTTON ACTIONS-
    @IBAction func cancelBTapped(_ sender: UIButton) {
    }
    @IBAction func infoBTapped(_ sender: UIButton) {
    }
    @IBAction func saveBTapped(_ sender: UIButton) {
    }
    @IBAction func segmentTapped(_ sender: UISegmentedControl) {
    }
    @IBAction func defaultMember1EditTapped(_ sender: UIButton) {
    }
    @IBAction func defaultMember2EditTapped(_ sender: UIButton) {
    }
    @IBAction func defaultMember3EditTapped(_ sender: UIButton) {
    }
    @IBAction func defaultMember4EditTapped(_ sender: UIButton) {
    }
    @IBAction func defaultMember5EditTapped(_ sender: UIButton) {
    }
    @IBAction func defaultMember6EditTapped(_ sender: UIButton) {
    }
    @IBAction func positionsBTapped(_ sender: UIButton) {
    }
    
}

extension SettingsResourcesEditVC: UITextFieldDelegate {
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        MARK: -TODO-
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
//        MARK: -TODO-
    }
}

extension SettingsResourcesEditVC: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
//        MARK: -TODO-
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        //        MARK: -TODO-
        return true
    }
}
