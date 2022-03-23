//
//  Sections.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/18/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation

enum Section: CaseIterable {
    case main
}

enum Sections:String {
    case Header
    case Campaign
    case HomeAddress
    case ServicesProvided
    case Signatures
    case SignaturesTextArea
    case DatePicker
    case InitialAssessmentUponVisit
    case PartnerReporting
    case RegionDesignatedReportingFields
    case InfomrationForFuture
    case AdministrativeSection
    case LocationCell
    case CampaignCell
    case NumNewSA
    case NumBellShaker
    case NumBatteriesReplaced
    case CreateFEP
    case ReviewChecklist
    case LocalHazard
    case DescHazard
    case ContactInfo
    case ResidentCellNum
    case ResidentEmail
    case ResidentOtherPhone
    case IANumPeople
    case IA17Under
    case IA65Over
    case IADisability
    case IAVets
    case IAPrexistingSA
    case IAWorkingSA
    case IANotes
    case NationalPartner
    case LocalPartner
    case Option1
    case Option2
    case AdminName
    case AdminDate
    case SignatureCell
    case Segment
    case MasterCampaign
}


enum TheViews: String {
    case station = "station"
    case staffing = "staffing"
    case apparatus = "apparatus"
    case journal = "journal"
    case incident = "incident"
    case settings = "settings"
    case ics214 = "ics214"
    case crrForm = "crrForm"
    case nfirsB1 = "nfirsB1"
    case whatsNew = "whatsNew"
    case info = "info"
    case store = "store"
    case shift = "shift"
    case onboard = "onboard"
    case tags = "tags"
}
