//
//  IncidentVC+TVCExtensions.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/14/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//


import UIKit
import Foundation
import CoreData
import MapKit
import CoreLocation
import PhotosUI

extension IncidentVC: UITableViewDelegate {
    
    func registerCellsForTable() {
        incidentTableView.register(UINib(nibName: "SubjectLabelTextFieldIndicatorTVCell", bundle: nil), forCellReuseIdentifier: "SubjectLabelTextFieldIndicatorTVCell")
        incidentTableView.register(UINib(nibName: "SubjectLabelTextViewTVCell", bundle: nil), forCellReuseIdentifier: "SubjectLabelTextViewTVCell")
        incidentTableView.register(UINib(nibName: "LabelSingleDateFieldCell", bundle: nil), forCellReuseIdentifier: "LabelSingleDateFieldCell")
        incidentTableView.register(UINib(nibName: "LabelYesNoSwitchCell", bundle: nil), forCellReuseIdentifier: "LabelYesNoSwitchCell")
        incidentTableView.register(UINib(nibName: "SegmentCell", bundle: nil), forCellReuseIdentifier: "SegmentCell")
        incidentTableView.register(UINib(nibName: "NewAddressFieldsButtonsCell", bundle: nil), forCellReuseIdentifier: "NewAddressFieldsButtonsCell")
        incidentTableView.register(UINib(nibName: "LabelTextFieldCell", bundle: nil), forCellReuseIdentifier: "LabelTextFieldCell")
        incidentTableView.register(UINib(nibName: "SubjectLabelTextViewTVCell", bundle: nil), forCellReuseIdentifier: "SubjectLabelTextViewTVCell")
        incidentTableView.register(UINib(nibName: "ModalLableSingleDateFieldCell", bundle: nil), forCellReuseIdentifier: "ModalLableSingleDateFieldCell")
        incidentTableView.register(UINib(nibName: "IncidentSameDateAlarmTVCell", bundle: nil), forCellReuseIdentifier: "IncidentSameDateAlarmTVCell")
        incidentTableView.register(UINib(nibName: "IncidentLabelDateiPhoneTVCell", bundle: nil), forCellReuseIdentifier: "IncidentLabelDateiPhoneTVCell")
        incidentTableView.register(UINib(nibName: "IncidentSameDateiPhoneTVCell", bundle: nil), forCellReuseIdentifier: "IncidentSameDateiPhoneTVCell")
        incidentTableView.register(UINib(nibName: "LabelCell", bundle: nil), forCellReuseIdentifier: "LabelCell")
        incidentTableView.register(RankTVCell.self, forCellReuseIdentifier: "RankTVCell")
        incidentTableView.register(MultipleAddButtonTVCell.self, forCellReuseIdentifier: "MultipleAddButtonTVCell")
        incidentTableView.register(IncidentEditBarTVC.self, forCellReuseIdentifier: "IncidentEditBarTVC")
        incidentTableView.register(IncidentTextViewTVCell.self, forCellReuseIdentifier: "IncidentTextViewTVCell")
        incidentTableView.register(IncidentTagsCViewTVCell.self, forCellReuseIdentifier: "IncidentTagsCViewTVCell")
        incidentTableView.register(CameraTVCell.self, forCellReuseIdentifier: "CameraTVCell")
        incidentTableView.register(IncidentPhotoCollectionCell.self, forCellReuseIdentifier: "IncidentPhotoCollectionCell")
    }
    
}

extension IncidentVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 32
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch row {
        case 0:
            return 165
        case 1:
            return 65
        case 2:
            if Device.IS_IPHONE {
                return 390
            } else {
                return  310
            }
        case 3:
            return 84
        case 4:
            return 85
        case 5:
            if nfirsIncidentType {
                return theNFIRSIncidentTypeHeight
            } else {
                return 0
            }
        case 6:
            return 85
        case 7:
            if theLocalIncidentType {
                return 88
            } else {
            return 0
            }
        case 8:
            return 85
        case 9:
            if theIncidentNotesAvailable {
                return theIncidentNotesHeight
            } else {
                return 0
            }
        case 10:
            if Device.IS_IPHONE {
                return 130
            } else {
                return 60
            }
        case 11:
            return 85
        case 12:
            if theAlarmNotesAvailable {
                return theAlarmNotesHeight
            } else {
                return 0
            }
        case 13:
            if Device.IS_IPHONE {
                return 165
            } else {
                return 130
            }
        case 14:
            return 85
        case 15:
            if theArrivalNotesAvailable {
                return theArrivalNotesHeight
            } else {
                return 0
            }
        case 16:
            if Device.IS_IPHONE {
                return 165
            } else {
                return 130
            }
        case 17:
            return 85
        case 18:
            if theControlledNotesAvailable {
                return theControlledNotesHeight
            } else {
                return 0
            }
        case 19:
            if Device.IS_IPHONE {
                return 165
            } else {
                return 130
            }
        case 20:
            return 85
        case 21:
            if theLastUnitDateAvailable {
                return theLastUnitNotesHeight
            } else {
                return 0
            }
        case 22:
            return 85
        case 23:
            if theAction1Available {
                return theAction1Height
            } else {
                return 0
            }
        case 24:
            return 85
        case 25:
            if theAction2Available {
                return theAction2Height
            } else {
                return 0
            }
        case 26:
            return 85
        case 27:
            if theAction3Available {
                return theAction3Height
            } else {
                return 0
            }
        case 28:
            return 65
        case 29:
            return 85
        case 30:
            if photosAvailable {
                return 85
            } else {
                return 0
            }
        case 31:
            return 85
        case 32:
            if theTagsAvailable {
                return theTagsHeight
            } else {
                return 0
            }
        case 33:
            return 150
        default:
            return 150
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch  row {
        case 0:
            var cell = tableView.dequeueReusableCell(withIdentifier: "IncidentEditBarTVC", for: indexPath) as! IncidentEditBarTVC
            cell = configureIncidentEditBarTVC(cell, index: indexPath)
            cell.configureEditButton()
            return cell
        case 1:
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelYesNoSwitchCell", for: indexPath) as! LabelYesNoSwitchCell
            cell = configureLabelYesNoSwitchCell(cell, index: indexPath)
            return cell
        case 2:
            var cell = tableView.dequeueReusableCell(withIdentifier: "NewAddressFieldsButtonsCell", for: indexPath) as! NewAddressFieldsButtonsCell
            let tag = indexPath.row
            cell = configureNewAddressFieldsButtonsCell( cell , at: indexPath , tag: tag)
            cell.configureNewMapButton(type: IncidentTypes.allIncidents)
            cell.configureNewLocationButton(type: IncidentTypes.allIncidents)
            return cell
        case 3:
            var cell = tableView.dequeueReusableCell(withIdentifier: "SegmentCell", for: indexPath) as! SegmentCell
            cell = configureSegmentCell(cell, index: indexPath)
            return cell
        case 4:
            var cell = tableView.dequeueReusableCell(withIdentifier: "MultipleAddButtonTVCell", for: indexPath) as! MultipleAddButtonTVCell
            cell = configureMultipleAddButtonTVCell(cell, index: indexPath)
            cell.configureTheButton()
            return cell
        case 5:
            if nfirsIncidentType {
                var cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
                cell = configureLabelCell(cell, index: indexPath)
                return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                    return cell
                }
        case 6:
            var cell = tableView.dequeueReusableCell(withIdentifier: "MultipleAddButtonTVCell", for: indexPath) as! MultipleAddButtonTVCell
            cell = configureMultipleAddButtonTVCell(cell, index: indexPath)
            cell.configureTheButton()
            return cell
        case 7:
            if theLocalIncidentType {
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
            cell = configureLabelCell(cell, index: indexPath)
            return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                return cell
            }
        case 8:
            var cell = tableView.dequeueReusableCell(withIdentifier: "MultipleAddButtonTVCell", for: indexPath) as! MultipleAddButtonTVCell
            cell = configureMultipleAddButtonTVCell(cell, index: indexPath)
            cell.configureTheButton()
            return cell
        case 9:
            if theIncidentNotesAvailable {
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
            cell = configureLabelCell(cell, index: indexPath)
            return cell
            } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                    return cell
            }
        case 10:
            if Device.IS_IPHONE {
                var cell = tableView.dequeueReusableCell(withIdentifier: "IncidentLabelDateiPhoneTVCell", for: indexPath) as! IncidentLabelDateiPhoneTVCell
                cell = configureIncidentLabelDateiPhoneTVCell(cell, index: indexPath)
                return cell
            } else {
                    var cell = tableView.dequeueReusableCell(withIdentifier: "ModalLableSingleDateFieldCell", for: indexPath) as! ModalLableSingleDateFieldCell
                    let tag = indexPath.row
                    cell = configureModalLableSingleDateFieldCell( cell , index: indexPath , tag: tag)
                    cell.configureDatePickersHoldingV()
                    return cell
            }
        case 11:
            var cell = tableView.dequeueReusableCell(withIdentifier: "MultipleAddButtonTVCell", for: indexPath) as! MultipleAddButtonTVCell
            cell = configureMultipleAddButtonTVCell(cell, index: indexPath)
            cell.configureTheButton()
            return cell
        case 12:
            if theAlarmNotesAvailable {
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
            cell = configureLabelCell(cell, index: indexPath)
            return cell
            } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                    return cell
            }
        case 13:
            if Device.IS_IPHONE {
                var cell = tableView.dequeueReusableCell(withIdentifier: "IncidentSameDateiPhoneTVCell", for: indexPath) as! IncidentSameDateiPhoneTVCell
                cell = configureIncidentSameDateiPhoneTVCell(cell, index: indexPath)
                return cell
            } else {
                    var cell = tableView.dequeueReusableCell(withIdentifier: "IncidentSameDateAlarmTVCell", for: indexPath) as! IncidentSameDateAlarmTVCell
                    cell = configureIncidentSameDateAlarmTVCell( cell , index: indexPath)
                    cell.configureDatePickersHoldingV()
                    return cell
            }
        case 14:
            var cell = tableView.dequeueReusableCell(withIdentifier: "MultipleAddButtonTVCell", for: indexPath) as! MultipleAddButtonTVCell
            cell = configureMultipleAddButtonTVCell(cell, index: indexPath)
            cell.configureTheButton()
            return cell
        case 15:
            if theArrivalNotesAvailable {
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
            cell = configureLabelCell(cell, index: indexPath)
            return cell
            } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                    return cell
            }
        case 16:
            if Device.IS_IPHONE {
                var cell = tableView.dequeueReusableCell(withIdentifier: "IncidentSameDateiPhoneTVCell", for: indexPath) as! IncidentSameDateiPhoneTVCell
                cell = configureIncidentSameDateiPhoneTVCell(cell, index: indexPath)
                return cell
            } else {
                    var cell = tableView.dequeueReusableCell(withIdentifier: "IncidentSameDateAlarmTVCell", for: indexPath) as! IncidentSameDateAlarmTVCell
                    cell = configureIncidentSameDateAlarmTVCell( cell , index: indexPath)
                    cell.configureDatePickersHoldingV()
                    return cell
            }
        case 17:
            var cell = tableView.dequeueReusableCell(withIdentifier: "MultipleAddButtonTVCell", for: indexPath) as! MultipleAddButtonTVCell
            cell = configureMultipleAddButtonTVCell(cell, index: indexPath)
            cell.configureTheButton()
            return cell
        case 18:
            if theControlledNotesAvailable {
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
            cell = configureLabelCell(cell, index: indexPath)
            return cell
            } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                    return cell
            }
        case 19:
            if Device.IS_IPHONE {
                var cell = tableView.dequeueReusableCell(withIdentifier: "IncidentSameDateiPhoneTVCell", for: indexPath) as! IncidentSameDateiPhoneTVCell
                cell = configureIncidentSameDateiPhoneTVCell(cell, index: indexPath)
                return cell
            } else {
                    var cell = tableView.dequeueReusableCell(withIdentifier: "IncidentSameDateAlarmTVCell", for: indexPath) as! IncidentSameDateAlarmTVCell
                    cell = configureIncidentSameDateAlarmTVCell( cell , index: indexPath)
                    cell.configureDatePickersHoldingV()
                    return cell
            }
        case 20:
            var cell = tableView.dequeueReusableCell(withIdentifier: "MultipleAddButtonTVCell", for: indexPath) as! MultipleAddButtonTVCell
            cell = configureMultipleAddButtonTVCell(cell, index: indexPath)
            cell.configureTheButton()
            return cell
        case 21:
            if theLastUnitDateAvailable {
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
            cell = configureLabelCell(cell, index: indexPath)
            return cell
            } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                    return cell
            }
        case 22:
            var cell = tableView.dequeueReusableCell(withIdentifier: "MultipleAddButtonTVCell", for: indexPath) as! MultipleAddButtonTVCell
            cell = configureMultipleAddButtonTVCell(cell, index: indexPath)
            cell.configureTheButton()
            return cell
        case 23:
            if theAction1Available {
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
            cell = configureLabelCell(cell, index: indexPath)
            return cell
            } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                    return cell
            }
        case 24:
            var cell = tableView.dequeueReusableCell(withIdentifier: "MultipleAddButtonTVCell", for: indexPath) as! MultipleAddButtonTVCell
            cell = configureMultipleAddButtonTVCell(cell, index: indexPath)
            cell.configureTheButton()
            return cell
        case 25:
            if theAction2Available {
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
            cell = configureLabelCell(cell, index: indexPath)
            return cell
            } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                    return cell
            }
        case 26:
            var cell = tableView.dequeueReusableCell(withIdentifier: "MultipleAddButtonTVCell", for: indexPath) as! MultipleAddButtonTVCell
            cell = configureMultipleAddButtonTVCell(cell, index: indexPath)
            cell.configureTheButton()
            return cell
        case 27:
            if theAction3Available {
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
            cell = configureLabelCell(cell, index: indexPath)
            return cell
            } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                    return cell
            }
        case 28:
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelYesNoSwitchCell", for: indexPath) as! LabelYesNoSwitchCell
            cell = configureLabelYesNoSwitchCell(cell, index: indexPath)
            return cell
        case 29:
                var cell = tableView.dequeueReusableCell(withIdentifier: "CameraTVCell", for: indexPath) as! CameraTVCell
                cell = configureCameraTVCell(cell, index: indexPath)
                cell.configureTheButton()
                return cell
        case 30:
            if photosAvailable {
                var cell = tableView.dequeueReusableCell(withIdentifier: "IncidentPhotoCollectionCell", for: indexPath) as! IncidentPhotoCollectionCell
                cell = configureIncidentPhotoCollectionCell(cell, index: indexPath)
                cell.configure(index: indexPath)
                cell.delegate = self
                cell.bringSubviewToFront(cell.photoCollectionView)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                return cell
            }
        case 31:
            var cell = tableView.dequeueReusableCell(withIdentifier: "MultipleAddButtonTVCell", for: indexPath) as! MultipleAddButtonTVCell
            cell = configureMultipleAddButtonTVCell(cell, index: indexPath)
            cell.configureTheButton()
            return cell
        case 32:
            var cell = tableView.dequeueReusableCell(withIdentifier: "IncidentTagsCViewTVCell", for: indexPath) as! IncidentTagsCViewTVCell
            cell = configureIncidentTagsCViewTVCell(cell, index: indexPath)
            cell.configure(theIncident: theIncident)
            return cell
        case 33:
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
            cell = configureLabelCell(cell, index: indexPath)
            return cell
        default:
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
            cell = configureLabelTextFieldCell(cell, index: indexPath)
            return cell
        }
    }
    
}
