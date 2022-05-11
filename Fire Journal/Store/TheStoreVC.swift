//
//  TheStoreVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 5/5/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//


private let fjSecret = "64246b70667e411db594ee2802e24ba1"
private let notificationKey = "FJkUNABLE_TOGETPricing"

import UIKit
import StoreKit
import CoreData

protocol TheStoreVCDelegate: AnyObject {
    func theStoreSubscriptionPurchased()
}

public enum TheStoreButtonTypes: Int {
    case quarterly
    case annual
    case login
    case restore
}

class TheStoreVC: UIViewController {
    
    weak var delegate: TheStoreVCDelegate? = nil
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let device = (UIApplication.shared.delegate as? AppDelegate)?.device
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var theUser: FireJournalUser!
    var userObjectID: NSManagedObjectID!
    
    var storeTableView: UITableView!
    
    var compact:SizeTrait! = nil
    let nc = NotificationCenter.default
    let defaults = UserDefaults.standard
    let subscribed = UserDefaults.standard.bool(forKey: "fireJournal_connect_group")
    let SUBSCRIPTION_PRODUCT_ID = "firejournal_subscription_to_connect_1"
    let MONTHLY_SUBSCRIPTION_PRODUCT_ID = "com.purecommand.FireJournal.sub.monthlysubscription"
    let QUARTERLY_SUBSCRIPTION_PRODUCT_ID = "com.purecommand.FireJournal.sub.quarterlysubscription"
    let YEARLY_SUBSCRIPTION_PRODUCT_ID = "com.purecommand.FireJournal.sub.yearlysubscription"
    
    var productsRequest = SKProductsRequest()
    var fjProducts = [SKProduct]()
    var fjSubscriptionAnnual = [SKProduct]()
    var fjSubscriptionQuarterly = [SKProduct]()
    var fjSubscriptionMonthly = [SKProduct]()
    var payment:SKPayment! = nil
    var fjSKProduct:SKProduct! = nil
    var fjMonthSKProduct:SKProduct! = nil
    var fjQuarterlySKProduct:SKProduct! = nil
    var fjAnnualSKProduct:SKProduct! = nil
    
    var titleName: String = ""
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    var controllerName:String = ""
    var myShift:MenuItems! = nil
    var alertUp: Bool = false
    
    let membershipText2: String = InfoBodyText.theStoreMembershipText2.rawValue
    var membershipText2Height: CGFloat = 0.0
    let membershipText3: String = InfoBodyText.theStoreMembershipText3.rawValue
    var membershipText3Height: CGFloat = 0.0
    let membershipText4: String = InfoBodyText.theStoreMembershipText4.rawValue
    var membershipText4Height: CGFloat = 0.0
    
    var annualPriceStr = ""
    var quarterlyPriceStr = ""
    var semiannualPriceStr = ""
    var monthlyPriceStr = ""
    var autoRenewableSubscription = UserDefaults.standard.bool(forKey: "autoRenewableSubscriptionMade")
    var suscribe = UserDefaults.standard.integer(forKey: "subscriptionBought")
    var fjUserGuid = ""
    var fjUserEmail = ""
    var productID = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Store"
        vcLaunch.splitVC = self.splitViewController
        if userObjectID != nil {
            theUser = context.object(with: userObjectID) as? FireJournalUser
            vcLaunch.userID = theUser.objectID
        }
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        
        SKPaymentQueue.default().add(self)
        
        fjProducts = SubscriptionsService.shared.fjProducts
        fjMonthSKProduct = fjProducts[0]
        fjQuarterlySKProduct = fjProducts[1]
        fjAnnualSKProduct = fjProducts[2]
        fjUserGuid = SubscriptionsService.shared.fjUserGuid
        fjUserEmail = SubscriptionsService.shared.fjUserEmail
        
        membershipText2Height = configureLabelHeight(text: membershipText2)
        membershipText3Height = configureLabelHeight(text: membershipText3)
        membershipText4Height = configureLabelHeight(text: membershipText4)
        
        configureTheStoreTableView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if fjProducts.count == 0 {
                   SubscriptionsService.shared.fetchAvailableProducts()
                    fjProducts = SubscriptionsService.shared.fjProducts
                    fjMonthSKProduct = fjProducts[0]
                    fjQuarterlySKProduct = fjProducts[1]
                    fjAnnualSKProduct = fjProducts[2]
        }
        
    }
    
        //    MARK: SIZE TRAIT
        @objc func compactOrRegular(ns: Notification) {
            if let userInfo = ns.userInfo as! [String: Any]?
            {
                compact = userInfo["compact"] as? SizeTrait ?? .regular
                switch compact {
                case .compact:
                    print("compact STORE")
                case .regular:
                    print("regular STORE")
                default: break
                }
            }
            self.viewDidLayoutSubviews()
        }
    
        //    MARK: -NETWORK CONNECTIONS-
        func theNetworkUnavailable(errorString: String)->UIAlertController {
                let title = "Internet Activity"
                let errorString = errorString
                let alert = UIAlertController.init(title: title, message: errorString, preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                    self.alertUp = false
                })
                alert.addAction(okAction)
                return alert
            }
    

}

extension TheStoreVC {
    
    func configureTheStoreTableView() {
        storeTableView = UITableView(frame: .zero)
        registerCellsForTable()
        storeTableView.translatesAutoresizingMaskIntoConstraints = false
        storeTableView.backgroundColor = .systemBackground
        view.addSubview(storeTableView)
        storeTableView.delegate = self
        storeTableView.dataSource = self
        storeTableView.separatorStyle = .none
        
        storeTableView.rowHeight = UITableView.automaticDimension
        storeTableView.estimatedRowHeight = 300
        
        NSLayoutConstraint.activate([
            storeTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            storeTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            storeTableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 15),
            storeTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
        ])
    }
    
}

extension TheStoreVC: UITableViewDelegate {
    
    func registerCellsForTable() {
        storeTableView.register(UINib(nibName: "LabelTextFieldCell", bundle: nil), forCellReuseIdentifier: "LabelTextFieldCell")
        storeTableView.register(UINib(nibName: "LabelCell", bundle: nil), forCellReuseIdentifier: "LabelCell")
        storeTableView.register(TheStoreTitleTVCell.self, forCellReuseIdentifier: "TheStoreTitleTVCell")
        storeTableView.register(TheStoreTextViewTVCell.self, forCellReuseIdentifier: "TheStoreTextViewTVCell")
        storeTableView.register(TheStoreButtonTVCell.self, forCellReuseIdentifier: "TheStoreButtonTVCell")
    }
    
}

extension TheStoreVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch row {
        case 0:
            if Device.IS_IPHONE {
                return 150
            } else {
                return 180
            }
        case 1:
            if Device.IS_IPHONE {
                return 500
            } else {
                return 600
            }
        case 2, 4, 6, 7:
            return 85
        case 3:
            return membershipText2Height
        case 5:
            if Device.IS_IPAD {
                return membershipText3Height + 50
            } else {
                return membershipText3Height
            }
        case 8:
            return membershipText4Height
        default: return 150
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch  row {
        case 0:
            var cell = tableView.dequeueReusableCell(withIdentifier: "TheStoreTitleTVCell", for: indexPath) as! TheStoreTitleTVCell
            cell = configureTheStoreTitleTVCell(cell, index: indexPath)
            return cell
        case 1:
            var cell = tableView.dequeueReusableCell(withIdentifier: "TheStoreTextViewTVCell", for: indexPath) as! TheStoreTextViewTVCell
            cell = configureTheStoreTextViewTVCell(cell, index: indexPath)
            return cell
        case 2, 4, 6, 7:
            var cell = tableView.dequeueReusableCell(withIdentifier: "TheStoreButtonTVCell", for: indexPath) as! TheStoreButtonTVCell
            cell = configureTheStoreButtonTVCell(cell, index: indexPath)
            return cell
        case 3, 5:
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
            cell = configureLabelCell(cell, index: indexPath)
            return cell
        case 8:
            var cell = tableView.dequeueReusableCell(withIdentifier: "TheStoreTextViewTVCell", for: indexPath) as! TheStoreTextViewTVCell
            cell = configureTheStoreTextViewTVCell(cell, index: indexPath)
            return cell
        default:
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
            cell = configureLabelTextFieldCell(cell, index: indexPath)
            return cell
        }
    }
    
    
}

