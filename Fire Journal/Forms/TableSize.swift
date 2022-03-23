//
//  TableSize.swift
//  dashboard
//
//  Created by DuRand Jones on 9/6/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit
import Foundation

class TableSize {
    var shift: MenuItems!
    
    init(myShift: MenuItems) {
        shift = myShift
    }
    
    func cellSizesForModal(myShift: MenuItems,indexPath: IndexPath,showMap: Bool, showPicker: Bool, updateTapped: Bool )->CGFloat {
        shift = myShift
        let row = indexPath.row
        switch row {
        case 0:
            return 44
        case 1:
            switch myShift {
            case .incidents:
                return 150
            case .journal:
                return 80
            case  .personal:
                return 145
            case .nfirsBasic1Search:
                return 100
            case .startShift:
                return 100
            case .endShift:
                return 100
            case .updateShift:
                return 100
            case .forms:
                if Device.IS_IPHONE {
                    return 175
                } else {
                return 140
                }
            default:
                return 100
            }
        case 2:
            switch myShift {
            case .forms:
                if Device.IS_IPHONE {
                    return 400
                } else {
                    return 275
                }
            case .incidentSearch:
                return 84
            case .journal,.personal:
                return 30
            default:
                return 44
            }
        case 3:
            switch myShift {
            case .incidents:
                return 65
            case .incidentSearch:
                return 75
            case .alarmSearch:
                return 75
            case .ics214Search:
                return 75
            case .journal, .personal:
                return 85
            case .nfirsBasic1Search:
                return 80
            case .forms:
                if Device.IS_IPHONE {
                    return 400
                } else {
                    return 275
                }
            case .startShift,.updateShift, .endShift:
                return 80
            default:
                return 44
            }
        case 4:
            switch myShift {
            case .incidents:
                return 80
            case .incidentSearch:
                return 85
            case .alarmSearch:
                return 75
            case .ics214Search:
                return 75
            case .journal:
                return 84
            case .personal:
                return 80
            case .nfirsBasic1Search:
                if(showPicker) {
                    return  132
                } else {
                    return 0
                }
            case .forms:
                return 184
            case .startShift,.updateShift,.endShift:
                if(showPicker) {
                    return  132
                } else {
                    return 0
                }
            default:
                return 44
            }
        case 5:
            switch myShift {
            case .incidents:
                if(showPicker) {
                    return  215
                } else {
                    return 0
                }
            case .incidentSearch:
                if(showPicker) {
                    return  132
                } else {
                    return 0
                }
            case .ics214Search:
                return 75
            case .alarmSearch:
                return 80
            case .journal:
                return 80
            case .personal:
                if(showPicker) {
                    return 132
                } else {
                    return 0
                }
            case .nfirsBasic1Search:
                return 84
            case .startShift, .endShift:
                return 85
            case .updateShift:
                return 110
            default:
                return 44
            }
        case 6:
            switch myShift {
            case .incidents:
                return 84
            case .incidentSearch:
                return 200
            case .journal:
                if(showPicker) {
                    return 132
                } else {
                    return 0
                }
            case .personal:
                return 250
            case .ics214Search:
                return 80
            case .alarmSearch:
                if(showPicker) {
                    return 132
                } else {
                    return 0
                }
            case .nfirsBasic1Search:
                return 200
            case .startShift, .endShift:
                return 110
            case .updateShift:
                return 85
            default:
                return 44
            }
        case 7:
            switch myShift {
            case .incidents:
                return 200
            case .incidentSearch:
                if(showMap) {
                    return 500
                } else {
                    return 0
                }
            case .ics214Search:
                if(showPicker) {
                    return 132
                } else {
                    return 0
                }
            case .alarmSearch:
                return 200
            case .journal:
                return 110
            case .personal:
                return 85
            case .nfirsBasic1Search:
                if(showMap) {
                    return 500
                } else {
                    return 0
                }
            case .startShift:
                return 85
            case .updateShift:
                return 85
            case .endShift:
                if updateTapped {
                    return 85
                } else {
                    return 0
                }
            default:
                return 44
            }
        case 8:
            switch myShift {
            case .incidents:
                if(showMap) {
                    return 500
                } else {
                    return 0
                }
            case .incidentSearch:
                return 140
            case .ics214Search:
                return 80
            case .alarmSearch:
                if(showMap) {
                    return 500
                } else {
                    return 0
                }
            case .journal, .personal:
                return 85
            case .nfirsBasic1Search:
                return 81
            case .startShift:
                return 85
            case .endShift:
                if updateTapped {
                    return 85
                } else {
                    return 0
                }
            default:
                return 44
            }
        case 9:
            switch myShift {
            case .incidents:
                return 184
            case .incidentSearch:
                return 81
            case .ics214Search:
                if(showPicker) {
                    return 132
                } else {
                    return 0
                }
            case .journal:
                return 65
            case .nfirsBasic1Search:
                return 81
            case .startShift:
                return 85
            default:
                return 44
            }
        case 10:
            switch myShift {
            case .incidents:
                return 81
            case .incidentSearch:
                return 81
            case .journal:
                return 81
            case .nfirsBasic1Search:
                return 81
            case .startShift:
                return 85
            default:
                return 44
            }
        case 11:
            switch myShift {
            case .incidents:
                return 81
            case .incidentSearch:
                return 81
            case .journal:
                return 81
            case .nfirsBasic1Search:
                return 81
            case .startShift:
                return 85
            default:
                return 44
            }
        case 12:
            switch myShift {
            case .incidents:
                return 81
            case .incidentSearch:
                return 81
            case .journal:
                return 81
            case .nfirsBasic1Search:
                return 140
            case .startShift:
                return 140
            default:
                return 44
            }
        case 13:
            switch myShift {
            case .incidents:
                return 81
            case .incidentSearch:
                return 81
            case .nfirsBasic1Search:
                return 81
            case .startShift:
                return 140
            default:
                return 44
            }
        default:
            return 44
        }
    }
}
