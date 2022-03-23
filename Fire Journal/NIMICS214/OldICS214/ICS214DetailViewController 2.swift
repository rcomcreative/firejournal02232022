//
//  ICS214DetailViewController.swift
//  ARCForm
//
//  Created by DuRand Jones on 8/18/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import Contacts
import ContactsUI
import T1Autograph
import MapKit
import CoreLocation

@objc protocol ICS214DetailViewControllerDelegate: AnyObject {
    @objc optional func completeChanged()
}

@available(iOS 11.0, *)
class ICS214DetailViewController: UITableViewController{
    //    TODO: -FormTocDelegate
    
    
    //  TODO:  -T1AutographDelegate, needs to be put back in
    func singleTextFieldInputWithForm(type: Form, input: String) {
        //
    }
    
    
    //    TODO: -autograph needs to be reintroduced
    var autograph: T1Autograph = T1Autograph()
    var outputImage: UIImageView! = UIImageView()
    
    var incidents = [IncidentEntry]()
    var cell1Answer:String!
    var cell2Answer:String!
    var cell3Answer:String!
    
    var cells = [CellParts]()
    var activities = [ICS214Activities]()
    var activityLogs = [ActivityLog]()
    var ics214resources = [ICS214Resources]()
    var ics214stucture: ICS214FormStructure!
    var fromDate: Date!
    var toDate: Date!
    var activityDate: Date!
    var signatureDate: Date!
    
    var dateType:Bool!
    var showPicker:Bool = false
    var showPickerTwo:Bool = false
    var showPickerThree:Bool = false
    var showPickerFour:Bool = false
    var completedB:Bool = false
    var signatureBool:Bool = false
    var signatureImage:UIImage?
    var masterGuid:String!
    var ics214Guid:String!
    var ics214UserAttendees:Array<UserAttendees>!
    var ics214ActivityLogs:Array<ICS214ActivityLog>!
    var ics214Activities:Array<ActivityCaptured>!
    var myShift:MenuItems = .ics214
    var titleName:String = ""
    var id = NSManagedObjectID()
    var sizeTrait: SizeTrait = .regular
    let nc = NotificationCenter.default
    
    
    var objectID: NSManagedObjectID? = nil
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var nims: ICS214Form!
    var ics214: ICS214Form!
    var icsDate: Date!
    var icsDateTo: Date!
    var dataAvailable:Bool! = false
    var teams: Array<Array<String>>!
    var resources = [ResourceAttendee]()
    
    var log: String!
    var dateString: String!
    var activitiesDate: Date!
    
    weak var delegate: ICS214DetailViewControllerDelegate? = nil
    
    //    MARK: -theCells-
    fileprivate let cellsFromData = CellAttributes()
    var theCells = [CellStorage]()
    
    //    MARK: -location-
    var locationManager: CLLocationManager!
    var city:String = ""
    var state:String = ""
    var streetNum:String = ""
    var streetName:String = ""
    var zip:String = ""
    var alertUp: Bool = false
   
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = "NIMS ICS 214"
        teams = []
        activities = []
        activityLogs = []
        resources = []
        ics214resources = []
        ics214stucture = ICS214FormStructure.init()
        incidents = []
        ics214UserAttendees = []
        ics214ActivityLogs = []
        ics214Activities = []
        
        theCells = cellsFromData.cells
        
        registerTheCellsForICS214()
        
        signatureImage = nil
        theFormBody()
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveICS214(_:)))
        navigationItem.rightBarButtonItem = saveButton
        _ = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action:nil)
        
        if (Device.IS_IPHONE){
            self.navigationController?.navigationBar.backgroundColor = UIColor.white
            let navigationBarAppearace = UINavigationBar.appearance()
            navigationBarAppearace.tintColor = UIColor.black
        } else {
            let backgroundImage = UIImage(named: "headerBar2")
            self.navigationController?.navigationBar.setBackgroundImage(backgroundImage, for: .default)
            self.navigationController?.navigationBar.tintColor = UIColor.white
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        }
        
        
        NotificationCenter.default.addObserver(self, selector:#selector(newICS214Saved), name: NSNotification.Name(rawValue: notificationKeyICS6), object: nil)
        
        NotificationCenter.default.addObserver(self, selector:#selector(mapCalled), name:NSNotification.Name(rawValue: notificationKeyICS9), object: nil)
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.nfirsCalled(_:)), name:NSNotification.Name(rawValue:FJkFORMCHOSEN_FROMDASHBOARD), object: nil)
        
        NotificationCenter.default.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
    }
    
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    @objc func nfirsCalled(_ notification:Notification) ->Void {
    
    }
    
    
    @objc func mapCalled(notification:Notification) -> Void {
        
    }
    
    @objc func newICS214Saved(notification:Notification) -> Void {
//        cells = [p0,p1,p2,p9,p3,p4,p5,p6,p7,p10,p8,p11]
        if  let userInfo = notification.userInfo {
            objectID  = userInfo["objectID"] as? NSManagedObjectID
            ics214Guid = userInfo["ics214Guid"] as? String
        }
        theFormBody()
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return cells.count
        return theCells.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(indexPath.row == 0) {
            cell.contentView.backgroundColor = UIColor(patternImage: UIImage(named:"header")!)
        }
        cell.selectionStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let type:CellParts = cells[indexPath.row]
//        let cellType:FormType = type.type["Type"]!
        
        
        let theCell = theCells[indexPath.row]
        let cellT = theCell.type
        
        switch cellT {
        case .twoTF:
            return 84
        case .oneTF:
            return 44
        case .photoAndTF:
            return 84
        case .header:
            return 150
        case .textInputCell:
            return 44
        case .fourTextOneButtonCell:
            return 288
        case .entryThreeFieldsCell:
            return 100
        case .entryTwoFieldsCell:
            return 130
        case .completedThreeFieldCell:
            return 44
        case .completedTwoFieldCell:
            return 44
        case .doubleButtonCell:
            return 180
        case .completedTwoInputWTV:
            return 178
        case .formTwoInputWTV:
            return 260
        case .pickerDateCell:
            if(showPicker) {
                return  132
            } else {
                return 0
            }
        case .pickerDateTwoCell:
            if(showPickerTwo) {
                return 132
            } else {
                return 0
            }
        case .pickerDateThreeCell:
            if(showPickerThree) {
                return 132
            } else {
                return 0
            }
        case .doubleTextFieldCell:
            return 44
        default:
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let theCell = theCells[indexPath.row]
        let cellT = theCell.type
        let valueT1 = theCell.valueType1
        let valueT2 = theCell.valueType2
//        let valueT3 = theCell.valueType3
        let theHeader = theCell.header
        let thefield1 = theCell.field1
        let thefield2 = theCell.field2
        let thefield3 = theCell.field3
        let thefield4 = theCell.field4
        let theCellValue1 = theCell.cellValue1
        let theCellValue2 = theCell.cellValue2
        let theCellValue3 = theCell.cellValue3
        let aDateType:Date = theCell.cellDate
        
        var inputDate:Date!
        if ((icsDate) != nil) {
            inputDate = icsDate
        } else {
            inputDate = Date()
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
        let dateFrom = dateFormatter.string(from: inputDate)
        
        switch cellT {
        case .header:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SectionHeaderCell", for: indexPath) as! SectionHeaderCell
            cell.completeB = completedB
            if completedB == true {
                cell.completeSwitch.setOn(false, animated: true)
            } else {
                cell.completeSwitch.setOn(true, animated: false)
            }
            cell.delegate = self
            if dataAvailable {
                if let header = ics214.ics214IncidentName {
                    if ics214.ics214EffortMaster {
                        cell.sectionL.text = header
                    } else {
                        let counted:Int = Int(exactly:ics214.ics214Count)!
                        if counted > 0 {
                            cell.sectionL.text = "\(header) - \(counted)"
                        } else {
                            cell.sectionL.text = "\(header)"
                        }
                        
                    }
                    if let effort:String = ics214.ics214Effort {
                        if effort == "FEMA Task Force" {
                            cell.sectionIV.image = UIImage(named:"ICS214FormFEMA")
                            cell.sectionAddressL.text = effort
                        } else if effort == "Local Incident" {
                            cell.sectionIV.image = UIImage(named:"ICS_214_Form_LOCAL_INCIDENT")
                            cell.sectionAddressL.text = effort
                        } else if effort == "Strike Team" {
                            cell.sectionIV.image = UIImage(named:"ICS214FormSTRIKETEAM")
                            cell.sectionAddressL.text = effort
                        } else if effort == "Other" {
                            cell.sectionIV.image = UIImage(named:"ICS214FormOTHER")
                            cell.sectionAddressL.text = effort
                        } else {
                            cell.sectionIV.image = UIImage(named:"ICS_214_Form_LOCAL_INCIDENT")
                        }
                    }
                    if completedB {
                        var completionDate = ""
                        let date = ics214.ics214CompletionDate
                        if(date != nil) {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "MM/dd/YYYY"
                            completionDate = dateFormatter.string(from: date! as Date)
                            cell.completeL.text = "Completed\nThis form has been marked as completed.\nCompleted \(completionDate)"
                        }
                    } else {
                        if let effort:String = ics214.ics214Effort {
                            if effort == "FEMA Task Force" {
                                cell.completeL.text = "Once this incident has been completed, please close form collection."
                                //                                }
                            }else if effort == "Strike Team" {
                                cell.completeL.text = "Once this incident has been completed, please close form collection."
                                //                                }
                            }else if effort == "Local Incident" {
                                cell.completeL.text = "Once this incident has been completed, please close form collection."
                            }else if effort == "Other" {
                                cell.completeL.text = "Once this incident has been completed, please close form collection."
                            }
                        }
                    }
                } else {
//                    print("move along")
                }
            }
            cell.sectionDateL.text = dateFrom
            return cell
        case .textInputCell:
            let cell = tableView.dequeueReusableCell(withIdentifier:  "TextFieldInputCell", for: indexPath) as! TextFieldInputCell
            let input = theHeader
            cell.inputLabel.text = input
            cell.delegate = self;
            cell.value = valueT1;
            let field = thefield1
            cell.formField = field
            if dataAvailable {
                switch valueT1 {
                case .fjKIncidentName:
                    if let name = ics214.ics214IncidentName {
                        cell.inputTextField.text = name
                        ics214stucture.incidentName = name
                    }
                case .fjKUnitLeader:
                    if let unitLeader = ics214.ics214UserName {
                        cell.inputTextField.text = unitLeader
                        ics214stucture.unitLeader = unitLeader
                    }
                case .fjKICSPosition:
                    if let position = ics214.ics214ICSPosition {
                        cell.inputTextField.text = position
                        ics214stucture.icsPosition = position
                    }
                case .fjKISCUnitName:
                    if let home = ics214.ics241HomeAgency {
                        cell.inputTextField.text = home
                        ics214stucture.icsUnitName = home
                    }
                default:
                    break
                }
            }
            return cell
        case .doubleButtonCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TwoButtonFourInputCell", for: indexPath) as! TwoButtonFourInputCell
            cell.delegate = self
            cell.cellLabel.text = theHeader
            cell.inputLabelOne.text = thefield1
            cell.inputLabelTwo.text = thefield2
            cell.inputLabelThree.text = thefield3
            cell.inputLabelFour.text = thefield4
            var fromDateTime: Date!
            var toDateTime: Date!
            switch valueT1 {
            case .fjKDateFrom:
                if ((icsDate) != nil) {
                    fromDateTime = icsDate
                    cell.dateFrom = fromDateTime
                    ics214stucture.dateFrom = icsDate
                }
                if((fromDateTime) != nil) {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/YYYY"
                    let dateFrom = dateFormatter.string(from: fromDateTime)
                    cell.inputTextFieldOne.text = dateFrom
                    dateFormatter.dateFormat = "HH:mm"
                    let timeFrom = dateFormatter.string(from: fromDateTime)
                    cell.inputTextFieldTwo.text = timeFrom
                }
            default:
                break
            }
            switch valueT2 {
            case .fjKDateTo:
                if dataAvailable {
                    if ((ics214.ics214ToTime) != nil) {
                        icsDateTo = ics214.ics214ToTime! as Date
                        cell.dateTo = icsDateTo
                        toDateTime = icsDateTo
                        ics214stucture.dateTo = icsDateTo
                    } else if((icsDateTo) != nil) {
                        cell.dateTo = icsDateTo
                        toDateTime = icsDateTo
                        ics214stucture.dateTo = icsDateTo
                    }
                } else if((icsDateTo) != nil) {
                    cell.dateTo = icsDateTo
                    toDateTime = icsDateTo
                    ics214stucture.dateTo = icsDateTo
                }
                if((toDateTime) != nil) {
                    dateFormatter.dateFormat = "MM/dd/YYYY"
                    let dateTo = dateFormatter.string(from: cell.dateTo)
                    cell.inputTextFieldThree.text = dateTo
                    dateFormatter.dateFormat = "HH:mm"
                    let timeTo = dateFormatter.string(from: cell.dateTo)
                    cell.inputTextFieldFour.text = timeTo
                }
            default:
                break
            }
            
            return cell
        case .fourTextOneButtonCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DoubleTextFieldWButtonCell", for: indexPath) as! DoubleTextFieldWButtonCell
            
            cell.cellLabel.text = theHeader
            cell.inputLabelOne.text = thefield1
            cell.inputLabelTwo.text = thefield2
            cell.inputLabelThree.text = thefield4
            cell.inputLabelFour.text = thefield3
            cell.dateFrom = signatureDate
            if !signatureBool {
                cell.signatureIV.isHidden = true
                cell.signatureIV.image = nil
                cell.signatureIV.alpha = 0.0
                cell.signatureB.isHidden = false
            } else {
                cell.signatureIV.isHidden = false
                cell.signatureIV.alpha = 1.0
                if signatureImage != nil {
                    cell.signatureIV.image = signatureImage
                }
                cell.signatureB.isHidden = true
            }
            cell.delegate = self
            
            if dataAvailable {
                if let name = ics214.ics214UserName {
                    cell.inputTextFieldOne.text = name
                    ics214stucture.preparedByName = name
                }
                if let position = ics214.ics214ICSPosition {
                    cell.inputTextFieldTwo.text = position
                    ics214stucture.preparedPosition = position
                }
                if((signatureDate) != nil) {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
                    let dateFrom = dateFormatter.string(from: cell.dateFrom)
                    cell.inputTextFieldFour.text = dateFrom
                    ics214stucture.preparedDate = signatureDate
                }
            }
            return cell
        case .entryThreeFieldsCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FormThreeInputCell", for: indexPath) as! FormThreeInputCell
            cell.delegate = self
            cell.cellL.text = theHeader
            cell.inputLabelOne.text = thefield1
            cell.inputLabelTwo.text = thefield2
            cell.inputLabelThree.text = thefield3
            cell.fieldOne = theCellValue1
            cell.fieldTwo = theCellValue2
            cell.fieldThree = theCellValue3
            return cell
        case .entryTwoFieldsCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FormTwoInputCell", for: indexPath) as! FormTwoInputCell
            cell.delegate = self
            cell.cellL.text = theHeader
            cell.inputLabelOne.text = thefield1
            cell.inputLabelTwo.text = thefield2
            cell.fieldOne = theCellValue1
            cell.fieldTwo = theCellValue2
            cell.ics214Guid = nims.ics214Guid ?? ""
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
            var dateForm:String!
            if((activityDate) != nil) {
                dateForm = dateFormatter.string(from: activityDate)
                cell.inputDate = activityDate
            } else {
                let theDate = Date()
                activityDate = theDate
                cell.inputDate = theDate
                dateForm = dateFormatter.string(from: theDate)
            }
            cell.inputTextFieldOne.text = dateForm
            cell.inputTextFieldTwo.text = ""
            return cell
        case .formTwoInputWTV:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FormTwoInputCellwTextView", for: indexPath) as! FormTwoInputCellwTextView
//           MARK: -THE ACTIVITIES CELL
            cell.delegate = self
            cell.cellL.text = theHeader
            if thefield1 == "Day/Time" {
                cell.inputLabelOne.text = thefield1
                cell.inputLabelTwo.text = thefield2
            } else {
                cell.inputLabelOne.text = ""
                cell.inputLabelTwo.text = ""
            }
            cell.fieldOne = theCellValue1
            cell.fieldTwo = theCellValue2
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
            var dateForm:String!
            if((activityDate) != nil) {
                dateForm = dateFormatter.string(from: activityDate)
                cell.inputDate = activityDate
            } else {
                let theDate = Date()
                activityDate = theDate
                cell.inputDate = activityDate
                dateForm = dateFormatter.string(from: theDate)
            }
            if thefield1 != "Day/Time" {
                cell.inputTextFieldOne.text = thefield1
            } else {
                cell.inputTextFieldOne.text = dateForm
            }
            if thefield2 != "Notable Activities" {
                cell.inputTwoTV.text = thefield2
            } else {
                cell.inputTwoTV.text = ""
            }
            return cell
        case .completedThreeFieldCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CompletedThreeFieldCell", for: indexPath) as! CompletedThreeFieldCell
            cell.delegate = self
            cell.inputTestFieldOne.text = thefield1
            cell.inputTextFieldTwo.text = thefield2
            cell.inputTextFieldThree.text = thefield3
            cell.indexPath.row = indexPath.row
            return cell
        case .completedTwoFieldCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CompletedTwoFieldCell", for: indexPath) as! CompletedTwoFieldCell
            cell.inputTextFieldOne.text = thefield1
            cell.inputTextFieldTwo.text = thefield2
            cell.inputDate = aDateType
            return cell
        case .completedTwoInputWTV:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CompletedTwoFieldCellwTextV", for: indexPath) as! CompletedTwoFieldCellwTextV
            cell.inputTextFieldOne.text = thefield1
            cell.inputTwoTV.text = thefield2
            cell.inputDate = aDateType
            return cell
        case .pickerDateCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FormDatePickerCell", for: indexPath) as! FormDatePickerCell
            cell.delegate = self
            cell.type = dateType
            cell.activity = ""
            return cell
        case .pickerDateTwoCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FormDatePickerCell", for: indexPath) as! FormDatePickerCell
            cell.delegate = self
            cell.type = false
            cell.activity = "Activity"
            return cell
        case .pickerDateThreeCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FormDatePickerCell", for: indexPath) as! FormDatePickerCell
            cell.delegate = self
            cell.type = false
            cell.activity = "Signature"
            return cell
        case .doubleTextFieldCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DoubleTextFieldCell", for: indexPath) as! DoubleTextFieldCell
            
            cell.cellLabel.text = theHeader
            cell.inputLabelOne.text = thefield1
            cell.inputLabelTwo.text = thefield2
            cell.inputLabelThree.text = thefield3
            cell.inputLabelFour.text = thefield4
            cell.dateFrom = fromDate
            
            
            if((fromDate) != nil) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
                let dateFrom = dateFormatter.string(from: cell.dateFrom)
                cell.inputTextFieldFour.text = dateFrom
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            return cell
        }
    }
    
}
