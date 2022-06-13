//
//  LoadPlists.swift
//  dashboard
//
//  Created by DuRand Jones on 10/2/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class LoadPlists: NSObject {
    let context: NSManagedObjectContext
    let pendingOperations = PendingOperations()
    var thread:Thread!
    let nc = NotificationCenter.default
    
    init(_ context: NSManagedObjectContext) {
        self.context = context
        super.init()
        thread = Thread(target:self, selector:#selector(runTheOperations), object:nil)
        nc.addObserver(self, selector:#selector(nextPlisyCalled(notification:)), name:NSNotification.Name(rawValue: FJkPLISTSCALLED), object: nil)
    }
    
    deinit {
        nc.removeObserver(NSNotification.Name(rawValue: FJkPLISTSCALLED))
        print("LoadPlists deinited")
    }
    
    @objc func nextPlisyCalled(notification:Notification) -> Void {
        if  let userInfo = notification.userInfo {
            let plistsToLoad = userInfo["plist"] as? PlistsToLoad
            pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
            switch plistsToLoad {
            case .fjkPLISTNFIRSIncidentLoader?:
                print("PLISTNFIRSIncidentLoader is finished")
                let nfirsLocationOperation = NFIRSLocationLoader.init(context)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(nfirsLocationOperation)
            case .fJkPLISTNFIRSLocationLoader?:
                print("fJkPLISTNFIRSLocationLoader is completed")
                let userLocalIncidentTypeLoader = UserLocalIncidentTypeLoader.init(context)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(userLocalIncidentTypeLoader)
            case .fjkPLISTUserLocalIncidentTypeLoader?:
                let nfirsStreetPrefixLoader = NFIRSStreetPrefixLoader.init(context)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(nfirsStreetPrefixLoader)
            case .fjkPLISTNFIRSStreetPrefixLoader?:
                let nfirsStreetTypeLoader = NFIRSStreetTypeLoader.init(context)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(nfirsStreetTypeLoader)
            case .fjkPLISTNFIRSStreetTypeLoader?:
                let actionsTaklenLoader = ActionTakenLoader.init(context)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(actionsTaklenLoader)
            case .fjkPLISTActionTakenLoader?:
                let aidGivenOperation = AidGivenLoader.init(context)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(aidGivenOperation)
            case .fjkPLISTAidGivenLoader?:
                let battalionOperation = BattalionLoader.init(context)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(battalionOperation)
            case .fjkPLISTBattalionLoader?:
                let buildingTypesOperation = BuildingTypeLoader.init(context)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(buildingTypesOperation)
            case .fjkPLISTBuildingTypeLoader?:
                let completedModulesOperation = CompletedModulesLoader.init(context)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(completedModulesOperation)
            case .fjkPLISTCompletedModulesLoader?:
                let councilWardOperation = CouncilWardLoader.init(context)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(councilWardOperation)
            case .fjkPLISTCouncilWardLoader?:
                let divisionsOperation = DivisionsLoader.init(context)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(divisionsOperation)
            case .fjkPLISTaDivisionsLoader?:
                let fireDistrictsOperation = FireDistrictsLoader.init(context)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(fireDistrictsOperation)
            case .fjkPLISTFireDistrictsLoader?:
                let hazardousMaterialsOperation = HazardousMaterialsLoader.init(context)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(hazardousMaterialsOperation)
            case .fjkPLISTHazardousMaterialsLoader?:
                let userInstallerOperation = InstallersLoader.init(context)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(userInstallerOperation)
            case .fjkPLISTInstallersLoader?:
                let nfirsMixedUsePropertiesOperation = NFIRSMixedUsePropertiesLoader.init(context)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(nfirsMixedUsePropertiesOperation)
            case .fjkPLISTNFIRSMixedUsePropertiesLoader?:
                let nfirsFormOperation = NFIRSFormLoader.init(context)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(nfirsFormOperation)
            case .fjkPLISTNFIRSFormLoader?:
                let nfirsFormsTOCOperation = NFIRSFormTOCLoader.init(context)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(nfirsFormsTOCOperation)
            case .fjkPLISTNFIRSFormTOCLoader?:
                let platoonOperation = PlatoonLoader.init(context)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(platoonOperation)
            case .fjkPLISTPlatoonLoader?:
                let propertyUseOperation = PropertyUseLoader.init(context)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(propertyUseOperation)
            case .fjkPLISTPropertyUseLoader?:
                let radioChannelsOperation = RadioChannelsLoader.init(context)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(radioChannelsOperation)
            case .fjkPLISTRadioChannelsLoader?:
                let rankOperation = RankLoader.init(context)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(rankOperation)
            case .fjkPLISTRankLoader?:
                let requiredModulesOperation = RequiredModulesLoader.init(context)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(requiredModulesOperation)
            case .fjkPLISTRequiredModulesLoader?:
                let userResourcesOperation = UserResourcesLoader.init(context)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(userResourcesOperation)
            case .fjkPLISTUserResourcesLoader?:
                let userStatesOperation = UserStateLoader.init(context)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(userStatesOperation)
            case .fjkPLISTUserStateLoader?:
                let userTagsOperation = UserTagsLoader.init(context)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(userTagsOperation)
            case .fjkPLISTUserTagsLoader?:
                let userApparatusOperation = UserApparatusLoader.init(context)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(userApparatusOperation)
            case .fjkPLISTUserApparatusLoader?:
                let userAssignmentOperation = UserAssignementLoader.init(context)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(userAssignmentOperation)
            case .fjkPLISTUserAssignementLoader?:
                let userSpecialitiesOperation = UserSpecialitiesLoader.init(context)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(userSpecialitiesOperation)
            case .fjlPLISTUserSpecialitiesLoader?:
                let userFDIDOperation = UserFDIDLoader.init(context)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(userFDIDOperation)
            case .fjkPLISTUserFDIDLoader?:
                print("all finished loading the plists")
                DispatchQueue.main.async {
                    self.nc.post(name:Notification.Name(rawValue:FJkLOADUSERITMESCALLED),
                            object: nil,
                            userInfo: ["ckRecordType":CKRecordsToLoad.fJkCKRIncident])
                }
                nc.removeObserver(self, name: NSNotification.Name(rawValue: FJkPLISTSCALLED), object: nil)
            default:
                print("nothing here")
            }
            pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
        }
    }
    
    @objc func runTheOperations() {
        let testThread:Bool = thread.isMainThread
        print("here is testThread \(testThread) and \(Thread.current)")
        pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
        let nfirsOperation = NFIRSIncidentLoader.init(context)
        pendingOperations.nfirsIncidentTypeQueue.addOperation(nfirsOperation)
        pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
    }
}
