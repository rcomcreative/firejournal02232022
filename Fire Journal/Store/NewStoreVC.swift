//
//  NewStoreVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 9/19/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

private let fjSecret = "64246b70667e411db594ee2802e24ba1"
private let notificationKey = "FJkUNABLE_TOGETPricing"

import UIKit
import StoreKit

protocol NewStoreVCDelegate: AnyObject {
    func closeTheNewStore()
    func quarterlyTappedNewStore()
    func annualTappedNewStore()
    func loginTappedNewStore()
    func restoreTappedNewStore()
    func newSubscriptionPurchased()
    func closeTheStore()
}

class NewStoreVC: UIViewController {
    
    //    MARK: -OBJECTS-
    @IBOutlet weak var quarterlyB: UIButton!
    @IBOutlet weak var loginB: UIButton!
    @IBOutlet weak var annualB: UIButton!
    @IBOutlet weak var restoreB: UIButton!
    //    MARK: -PROPERTIES-
    weak var delegate: NewStoreVCDelegate? = nil
    var compact:SizeTrait! = nil
    let nc = NotificationCenter.default
    let defaults = UserDefaults.standard
    let subscribed = UserDefaults.standard.bool(forKey: "fireJournal_connect_group")
    let SUBSCRIPTION_PRODUCT_ID = "firejournal_subscription_to_connect_1"
    let MONTHLY_SUBSCRIPTION_PRODUCT_ID = "com.purecommand.FireJournal.sub.monthlysubscription"
    let QUARTERLY_SUBSCRIPTION_PRODUCT_ID = "com.purecommand.FireJournal.sub.quarterlysubscription"
    let YEARLY_SUBSCRIPTION_PRODUCT_ID = "com.purecommand.FireJournal.sub.yearlysubscription"
    var productID = ""
    var fjUserGuid = ""
    var fjUserEmail = ""
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
    var annualPriceStr = ""
    var quarterlyPriceStr = ""
    var semiannualPriceStr = ""
    var monthlyPriceStr = ""
    var autoRenewableSubscription = UserDefaults.standard.bool(forKey: "autoRenewableSubscriptionMade")
    var suscribe = UserDefaults.standard.integer(forKey: "subscriptionBought")
    var titleName: String = ""
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    var controllerName:String = ""
    var myShift:MenuItems! = nil
    var alertUp: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Store"
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        
//        var monthly = ""
//        monthly = defaults.string(forKey: FJkSUBSCRIPTION1) ?? ""
//        var quarterly = ""
//        quarterly = defaults.string(forKey: FJkSUBSCRIPTION2) ?? ""
//        var annually = ""
//        annually = defaults.string(forKey: FJkSUBSCRIPTION3) ?? ""
        
        SKPaymentQueue.default().add(self)
        
        nc.addObserver(self, selector: #selector(compactOrRegular(ns:)), name:NSNotification.Name(rawValue: FJkCOMPACTORREGULAR), object: nil)
        
        fjProducts = SubscriptionsService.shared.fjProducts
        fjMonthSKProduct = fjProducts[0]
        fjQuarterlySKProduct = fjProducts[1]
        fjAnnualSKProduct = fjProducts[2]
        fjUserGuid = SubscriptionsService.shared.fjUserGuid
        fjUserEmail = SubscriptionsService.shared.fjUserEmail
        
        navigationItem.leftItemsSupplementBackButton = true
//        let button3 = self.splitViewController?.displayModeButtonItem
//        navigationItem.setLeftBarButtonItems([button3!], animated: true)
        
        if (Device.IS_IPHONE){
            self.navigationController?.navigationBar.backgroundColor = UIColor.white
            let navigationBarAppearace = UINavigationBar.appearance()
            navigationBarAppearace.tintColor = UIColor.black
        } else {
            let navigationBarAppearace = UINavigationBar.appearance()
            navigationBarAppearace.tintColor = UIColor.black
            navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
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
    
    override func viewWillLayoutSubviews() {
        if(fjProducts.count == 0) {
                   SubscriptionsService.shared.fetchAvailableProducts()
                    fjProducts = SubscriptionsService.shared.fjProducts
                    fjMonthSKProduct = fjProducts[0]
                    fjQuarterlySKProduct = fjProducts[1]
                    fjAnnualSKProduct = fjProducts[2]
        }
        
    }
    
    //    MARK: BUTTON ACTIONS
    @IBAction func quarterlyBTapped(_ sender: Any) {
        fjSKProduct = nil
        defaults.set(false, forKey: "subscriptionBought")
        purchaseQuarterlyProduct()
    }
    @IBAction func annualBTapped(_ sender: Any) {
         fjSKProduct = nil
           defaults.set(false, forKey: "subscriptionBought")
           purchaseAnnualProduct()
    }
    @IBAction func loginBTapped(_ sender: Any) {
        let available = defaults.bool(forKey: FJkInternetConnectionAvailable)
        if available {
            if alertUp {
                self.dismiss(animated: true, completion: nil)
            }
            let messageString = "You’re about to access Fire Journal Cloud via your web browser. To get back to Fire Journal, tap on the little “return…” icon at the top left of the page."
            let alert = connectToTheCloud(messageString: messageString)
            self.present(alert,animated: true)
        } else {
            if alertUp {
                self.dismiss(animated: true, completion: nil)
            }
            let alert = theNetworkUnavailable(errorString: "This app is not connected to the internet at this time.")
            self.present(alert,animated: true)
        }
    }
    @IBAction func restorBTapped(_ sender: Any) {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
        let appReceiptRefreshRequest = SKReceiptRefreshRequest(receiptProperties: nil)
        appReceiptRefreshRequest.delegate = self
        appReceiptRefreshRequest.start()
    }
    
    
    //    MARK: -FORMATTER
    private var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.formatterBehavior = .behavior10_4
        
        return formatter
    }()
    
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
    
    func connectToTheCloud(messageString: String)->UIAlertController {
           let title:String = "Sync with Fire Journal Cloud"
           let message:String = messageString
          let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
           let okAction = UIAlertAction.init(title: "Proceed", style: .default, handler: {_ in
               self.alertUp = false
               guard let url = URL(string: "https://firejournalcloud.com") else { return }
               UIApplication.shared.open(url)
           })
           let noAction = UIAlertAction.init(title: "Cancel", style: .default, handler: {_ in
               self.alertUp = false
           })
           alert.addAction(okAction)
           alert.addAction(noAction)
           alertUp = true
           return alert
       }
    
    
     func purchaseQuarterlyProduct() {
          let available = defaults.bool(forKey: FJkInternetConnectionAvailable)
         if available {
             if !alertUp {
                 self.dismiss(animated: true, completion: nil)
                 if(self.canMakePurchases()){
                     if fjMonthSKProduct != nil {
                     let pay = SKPayment(product: fjMonthSKProduct)
                     SKPaymentQueue.default().add(pay)
                     SKPaymentQueue.default()
                     productID = fjMonthSKProduct.productIdentifier
                     alertUp = true
                     }
                }
             }
         } else {
             let alert = theNetworkUnavailable(errorString: "This app is not connected to the internet at this time.")
             self.present(alert,animated: true)
         }
     }
     
     func purchaseAnnualProduct() {
         let available = defaults.bool(forKey: FJkInternetConnectionAvailable)
         if available {
             if !alertUp {
                 self.dismiss(animated: true, completion: nil)
                  if(self.canMakePurchases()){
                     if fjAnnualSKProduct != nil {
                             let pay = SKPayment(product: fjAnnualSKProduct)
                             SKPaymentQueue.default().add(pay)
                             SKPaymentQueue.default()
                             productID = fjAnnualSKProduct.productIdentifier
                             alertUp = true
                     }
                 }
             }
         } else {
                    let alert = theNetworkUnavailable(errorString: "This app is not connected to the internet at this time.")
                    self.present(alert,animated: true)
         }
     }
}

extension NewStoreVC: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    // MARK: -SKPRODUCT DELEGATES
    func canMakePurchases() -> Bool { return SKPaymentQueue.canMakePayments()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if (response.products.count > 0) {
            fjProducts = response.products
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions{
            print("HERE IS THE TRANSACTIONS \(transactions)")
            
            if let trans = transaction as? SKPaymentTransaction {
                
                switch trans.transactionState {
                case .purchased:
                    SubscriptionsService.shared.getAppReceipt()
                    if productID == MONTHLY_SUBSCRIPTION_PRODUCT_ID {
                        autoRenewableSubscription = true
                        let defaults = UserDefaults.standard
                        defaults.set(transaction.payment.productIdentifier,forKey: FJkSUBSCRIPTIONProductIdentifier)
                        defaults.set(transaction.payment.applicationUsername,forKey: "FJkSUBSCRIPTIONUserName")
                        defaults.set(transaction.transactionIdentifier as Any,forKey:FJkSUBSCRIPTIONTransactionIdentifier)
                        defaults.set(transaction.transactionDate as Any,forKey: FJkSUBSCRIPTIONPurchaseDate)
                        defaults.set(MONTHLY_SUBSCRIPTION_PRODUCT_ID, forKey:"subscription_id")
                        defaults.set(autoRenewableSubscription,forKey: "autoRenewableSubscriptionMade")
                        defaults.set(false, forKey: "subscriptionBought")
                        defaults.synchronize()
                        SKPaymentQueue.default().finishTransaction((transaction as? SKPaymentTransaction)!)
                    } else if productID == YEARLY_SUBSCRIPTION_PRODUCT_ID {
                        autoRenewableSubscription = true
                        let defaults = UserDefaults.standard
                        defaults.set(transaction.payment.productIdentifier,forKey: FJkSUBSCRIPTIONProductIdentifier)
                        defaults.set(transaction.payment.applicationUsername,forKey: "FJkSUBSCRIPTIONUserName")
                        defaults.set(transaction.transactionIdentifier as Any,forKey:FJkSUBSCRIPTIONTransactionIdentifier)
                        defaults.set(transaction.transactionDate as Any,forKey: FJkSUBSCRIPTIONPurchaseDate)
                        defaults.set(YEARLY_SUBSCRIPTION_PRODUCT_ID, forKey:"subscription_id")
                        defaults.set(autoRenewableSubscription,forKey: "autoRenewableSubscriptionMade")
                        defaults.set(false, forKey: "subscriptionBought")
                        defaults.synchronize()
                        SKPaymentQueue.default().finishTransaction((transaction as? SKPaymentTransaction)!)
                    } else if productID == QUARTERLY_SUBSCRIPTION_PRODUCT_ID {
                        autoRenewableSubscription = true
                        let defaults = UserDefaults.standard
                        defaults.set(transaction.payment.productIdentifier,forKey: FJkSUBSCRIPTIONProductIdentifier)
                        defaults.set(transaction.payment.applicationUsername,forKey: "FJkSUBSCRIPTIONUserName")
                        defaults.set(transaction.transactionIdentifier as Any,forKey:FJkSUBSCRIPTIONTransactionIdentifier)
                        defaults.set(transaction.transactionDate as Any,forKey: FJkSUBSCRIPTIONPurchaseDate)
                        defaults.set(QUARTERLY_SUBSCRIPTION_PRODUCT_ID, forKey:"subscription_id")
                        defaults.set(autoRenewableSubscription,forKey: "autoRenewableSubscriptionMade")
                        defaults.set(false, forKey: "subscriptionBought")
                        defaults.synchronize()
                        SKPaymentQueue.default().finishTransaction((transaction as? SKPaymentTransaction)!)
                    }
                    modalDidFinish()
                    delegate?.newSubscriptionPurchased()
                case .failed:
                    self.dismiss(animated: true, completion: nil)
                    alertUp = false
                    SKPaymentQueue.default().finishTransaction((transaction as? SKPaymentTransaction)!)
                    autoRenewableSubscription = false
                    let defaults = UserDefaults.standard
                    defaults.set(autoRenewableSubscription,forKey: "autoRenewableSubscriptionMade")
                    defaults.set(false, forKey: "subscriptionBought")
                    defaults.synchronize()
                    delegate?.closeTheStore()
                case .restored:
                    SubscriptionsService.shared.getAppReceipt()
                    if productID == MONTHLY_SUBSCRIPTION_PRODUCT_ID {
                        autoRenewableSubscription = true
                        let defaults = UserDefaults.standard
                        defaults.set(transaction.payment.productIdentifier,forKey: FJkSUBSCRIPTIONProductIdentifier)
                        defaults.set(transaction.payment.applicationUsername,forKey: "FJkSUBSCRIPTIONUserName")
                        defaults.set(transaction.transactionIdentifier as Any,forKey:FJkSUBSCRIPTIONTransactionIdentifier)
                        defaults.set(transaction.transactionDate as Any,forKey: FJkSUBSCRIPTIONPurchaseDate)
                        defaults.set(MONTHLY_SUBSCRIPTION_PRODUCT_ID, forKey:"subscription_id")
                        defaults.set(autoRenewableSubscription,forKey: "autoRenewableSubscriptionMade")
                        defaults.set(false, forKey: "subscriptionBought")
                        defaults.synchronize()
                        SKPaymentQueue.default().finishTransaction((transaction as? SKPaymentTransaction)!)
                    } else if productID == YEARLY_SUBSCRIPTION_PRODUCT_ID {
                        autoRenewableSubscription = true
                        let defaults = UserDefaults.standard
                        defaults.set(transaction.payment.productIdentifier,forKey: FJkSUBSCRIPTIONProductIdentifier)
                        defaults.set(transaction.payment.applicationUsername,forKey: "FJkSUBSCRIPTIONUserName")
                        defaults.set(transaction.transactionIdentifier as Any,forKey:FJkSUBSCRIPTIONTransactionIdentifier)
                        defaults.set(transaction.transactionDate as Any,forKey: FJkSUBSCRIPTIONPurchaseDate)
                        defaults.set(YEARLY_SUBSCRIPTION_PRODUCT_ID, forKey:"subscription_id")
                        defaults.set(autoRenewableSubscription,forKey: "autoRenewableSubscriptionMade")
                        defaults.set(false, forKey: "subscriptionBought")
                        defaults.synchronize()
                        SKPaymentQueue.default().finishTransaction((transaction as? SKPaymentTransaction)!)
                    } else if productID == QUARTERLY_SUBSCRIPTION_PRODUCT_ID {
                        autoRenewableSubscription = true
                        let defaults = UserDefaults.standard
                        defaults.set(transaction.payment.productIdentifier,forKey: FJkSUBSCRIPTIONProductIdentifier)
                        defaults.set(transaction.payment.applicationUsername,forKey: "FJkSUBSCRIPTIONUserName")
                        defaults.set(transaction.transactionIdentifier as Any,forKey:FJkSUBSCRIPTIONTransactionIdentifier)
                        defaults.set(transaction.transactionDate as Any,forKey: FJkSUBSCRIPTIONPurchaseDate)
                        defaults.set(QUARTERLY_SUBSCRIPTION_PRODUCT_ID, forKey:"subscription_id")
                        defaults.set(autoRenewableSubscription,forKey: "autoRenewableSubscriptionMade")
                        defaults.set(false, forKey: "subscriptionBought")
                        defaults.synchronize()
                        SKPaymentQueue.default().finishTransaction((transaction as? SKPaymentTransaction)!)
                    }
                    modalDidFinish()
                    delegate?.newSubscriptionPurchased()
                default:
                    self.dismiss(animated: true, completion: nil)
                    alertUp = false
                    
                }
            }
            
        }
    }
    
    func modalDidFinish(){
        let subscribed = UserDefaults.standard.bool(forKey: "subscriptionBought")
        let type = UserDefaults.standard.string(forKey: "subscription_id")
        print("here is the subscribed \(subscribed) and type \(String(describing: type))")
        alertUp = false
        dismiss(animated: true, completion: nil)
    }
}
