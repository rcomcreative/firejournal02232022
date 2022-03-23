//
//  StoreTVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/18/17.
//  Copyright © 2017 PureCommandLLC. All rights reserved.
//

//private let fjSecret = "64246b70667e411db594ee2802e24ba1"
//private let notificationKey = "FJkUNABLE_TOGETPricing"

import UIKit
import StoreKit

@objc protocol TheStoreDelegate: AnyObject {
    @objc optional func newSubscriptionPurchased()
    @objc optional func closeTheStore()
}

class StoreTVC: UITableViewController,SKProductsRequestDelegate,SKPaymentTransactionObserver {
    
    
//    let subscriptionsService = SubscriptionsService.shared
    /* Views */
    @IBOutlet weak var quarterlySubButton: UIButton!
    
    @IBOutlet weak var monthlySubButton: UIButton!
    @IBOutlet weak var semiannualSubButton: UIButton!
    @IBOutlet weak var annualSubButton: UIButton!
    @IBOutlet weak var monthlySubscriptionCostLabel: UILabel!
    @IBOutlet weak var quarterlySubscriptionCostLabel: UILabel!
    @IBOutlet weak var seminannualSubscriptionCostLabel: UILabel!
    @IBOutlet weak var annualSubscrptionCostLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var subscriptionPurchaseLabel: UILabel!
    @IBOutlet weak var subscriptionPurchasedLabel: UILabel!
    
    
    @IBOutlet weak var connectSecondaryTV: UITextView!
    @IBOutlet weak var connectionDescriptionTV: UITextView!
    
    @IBOutlet weak var subscriptionButton: UIButton!
    
    @IBOutlet weak var restoreSubscriptionButton: UIButton!
    
    @IBOutlet weak var monthlySubB: UIButton!
    
    @IBOutlet weak var quarterlySubB: UIButton!
    @IBOutlet weak var yearlySubB: UIButton!
    @IBOutlet weak var quarterlySubL: UILabel!
    
    @IBOutlet weak var yearlySubL: UILabel!
    
    @IBOutlet weak var subscriberLoginB: UIButton!
    
    @IBOutlet weak var monthlySubL: UILabel!
    
    let defaults = UserDefaults.standard
    let subscribed = UserDefaults.standard.bool(forKey: "fireJournal_connect_group")
    
    /* Variables */
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
    var annualPriceStr = ""
    var quarterlyPriceStr = ""
    var semiannualPriceStr = ""
    var monthlyPriceStr = ""
    var autoRenewableSubscription = UserDefaults.standard.bool(forKey: "autoRenewableSubscriptionMade")
    var suscribe = UserDefaults.standard.integer(forKey: "subscriptionBought")
    
    weak var delegate: TheStoreDelegate? = nil
    
    var titleName: String = ""
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    var controllerName:String = ""
    var myShift:MenuItems! = nil
    let userDefaults = UserDefaults.standard
    
    private var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.formatterBehavior = .behavior10_4
        
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = titleName
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        // Check your In-App Purchases
        print("SUBSCRIPTION PURCHASE MADE: \(autoRenewableSubscription)")
        print("SUSCRIPTION: \(suscribe)")
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.title = "Purchase Your Fire Journal Cloud Subscription"
        
        
//        var monthly = ""
//        monthly = defaults.string(forKey: FJkSUBSCRIPTION1) ?? ""
        var quarterly = ""
        quarterly = defaults.string(forKey: FJkSUBSCRIPTION2) ?? ""
        var annually = ""
        annually = defaults.string(forKey: FJkSUBSCRIPTION3) ?? ""
        
//        if monthly != "" {
//            monthlySubL.text = monthly
//        }
        if quarterly != "" {
            quarterlySubL.text = quarterly
        }
        if annually != "" {
            yearlySubL.text = annually
        }
        

        fjProducts = SubscriptionsService.shared.fjProducts
        fjUserGuid = SubscriptionsService.shared.fjUserGuid
        fjUserEmail = SubscriptionsService.shared.fjUserEmail
        
        
        navigationItem.leftItemsSupplementBackButton = true
        let button3 = self.splitViewController?.displayModeButtonItem
        navigationItem.setLeftBarButtonItems([button3!], animated: true)
        
        if (Device.IS_IPHONE){
            self.navigationController?.navigationBar.backgroundColor = UIColor.white
            let navigationBarAppearace = UINavigationBar.appearance()
            navigationBarAppearace.tintColor = UIColor.black
        } else {
            //            let backgroundImage = UIImage(named: "headerBar2")
            //            self.navigationController?.navigationBar.setBackgroundImage(backgroundImage, for: .default)
            let navigationBarAppearace = UINavigationBar.appearance()
            navigationBarAppearace.tintColor = UIColor.black
            navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        
        
        //        restoreSubscriptionButton.layer.cornerRadius = 12.0
        //        restoreSubscriptionButton.layer.masksToBounds = true
        
//        monthlySubB.layer.cornerRadius = 12.0
//        monthlySubB.layer.masksToBounds = true
//        quarterlySubB.layer.cornerRadius = 12.0
//        quarterlySubB.layer.masksToBounds = true
//        yearlySubB.layer.cornerRadius = 12.0
//        yearlySubB.layer.masksToBounds = true
        
        
        
        
        
        // Show its description
        connectionDescriptionTV.isEditable = false
        connectionDescriptionTV.dataDetectorTypes = UIDataDetectorTypes.all
                
        connectSecondaryTV.isEditable = false
        connectSecondaryTV.dataDetectorTypes = UIDataDetectorTypes.all
        connectSecondaryTV.text = "Your iTunes account will be charged for renewal a the price shown within 24 hours prior to the end of the free trial subscription period.\n\nCancel Anytime\n\nFire Journal Cloud is a recurring subscription. If you decide to purchase a subscription to Fire Journal, you’ll receive an initial FREE 90 DAY TRIAL. Once the free trial period concludes, your subscription will automatically renew and payment will be charged to your iTunes account. Auto-renewal may be disabled at any time by going to your settings in the iTunes store after purchase. For more information, please see our Terms of Use.\nhttp://purecommand.com/terms/ and Privacy Policy\nhttp://purecommand.com/privacy/\n\n"
        
        if(fjProducts.count == 0) {
           SubscriptionsService.shared.fetchAvailableProducts()
            
        } else {
            formatter.locale = fjProducts[0].priceLocale
            
//            monthlySubL.text = "\(formatter.string(from: fjProducts[0].price)!)"
            quarterlySubL.text = "\(formatter.string(from: fjProducts[1].price)!)"
            yearlySubL.text = "\(formatter.string(from: fjProducts[2].price)!)"
//            monthlySubL.setNeedsDisplay()
            quarterlySubL.setNeedsDisplay()
            yearlySubL.setNeedsDisplay()
        }
        
    }
    
    @objc func modalDidFinish(){
        let subscribed = UserDefaults.standard.bool(forKey: "subscriptionBought")
        let type = UserDefaults.standard.string(forKey: "subscription_id")
        print("here is the subscribed \(subscribed) and type \(String(describing: type))")
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - button actions
    
    
    @IBAction func restoreSubscriptionTapped(_ sender: Any) {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
        let appReceiptRefreshRequest = SKReceiptRefreshRequest(receiptProperties: nil)
        appReceiptRefreshRequest.delegate = self
        appReceiptRefreshRequest.start()
    }
    
    @IBAction func annualBTapped(_ sender: Any) {
        defaults.set(false, forKey: "subscriptionBought")
        defaults.synchronize()
        purchaseMyProduct(product: fjProducts[2])
    }
    
    @IBAction func quarterlyBTapped(_ sender: Any) {
        defaults.set(false, forKey: "subscriptionBought")
        defaults.synchronize()
        purchaseMyProduct(product: fjProducts[1])
    }
    
    @IBAction func monthlySTapped(_ sender: Any) {
        defaults.set(false, forKey: "subscriptionBought")
        defaults.synchronize()
        purchaseMyProduct(product: fjProducts[0])
    }
    
    
    
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        autoRenewableSubscription = true
        defaults.set(autoRenewableSubscription,forKey: "autoRenewableSubscriptionMade")
        defaults.set(true, forKey: "subscriptionBought")
        defaults.synchronize()
    }
    
    // MARK: - PURCHASE FUNCTIONS
    func canMakePurchases() -> Bool { return SKPaymentQueue.canMakePayments() }
    func purchaseMyProduct(product: SKProduct) {
        if(self.canMakePurchases()){
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            SKPaymentQueue.default()
            
            print("PRODUCT TO PURCHASE: \(product.productIdentifier)")
            productID = product.productIdentifier
        } else {
            
        }
        
        
    }
    // MARK: - Delegate handling purchase
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions{
            print("HERE IS THE TRANSACTIONS \(transactions)")
            if let trans = transaction as? SKPaymentTransaction {
                print("here is the transaction state \(trans)")
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
                    delegate?.newSubscriptionPurchased!()
                    break
                case .failed:
                    SKPaymentQueue.default().finishTransaction((transaction as? SKPaymentTransaction)!)
                    autoRenewableSubscription = false
                    let defaults = UserDefaults.standard
                    defaults.set(autoRenewableSubscription,forKey: "autoRenewableSubscriptionMade")
                    defaults.set(false, forKey: "subscriptionBought")
                    defaults.synchronize()
                    delegate?.closeTheStore!()
                    break
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
                    delegate?.newSubscriptionPurchased!()
                    break
                default: break
                    
                }
            }
            
        }
        
    }
    
    // MARK: - REQUEST FJ PRODUCTS
    func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        if (response.products.count > 0) {
            fjProducts = response.products
            
            
            // Get its price from iTunes Connect
            
            formatter.locale = fjProducts[0].priceLocale
            
            
            
            // Show its description
            connectionDescriptionTV.text = fjProducts[3].localizedDescription
            
            
//            monthlySubL.textAlignment = .center
//            monthlySubL.text = "\(formatter.string(from: fjProducts[0].price)!)"
            quarterlySubL.text = "\(formatter.string(from: fjProducts[1].price)!)"
            yearlySubL.text = "\(formatter.string(from: fjProducts[2].price)!)"
//            monthlySubL.setNeedsDisplay()
            quarterlySubL.setNeedsDisplay()
            yearlySubL.setNeedsDisplay()
            
            // ------------------------------------------------
            
        }
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(subscribed) {
            return 3
        } else {
            return 3
        }
        
    }
    
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat{
        switch indexPath.row {
        case 0:
            return 150
        case 1:
//            if(subscribed) {
//                return 700
//            } else {
//                return 700
//            }
            if Device.IS_IPHONE {
                return  800
            } else {
                return 800
            }
        case 2:
            return 345
        default:
            return 44
        }
    }
    
    @IBAction func subscriberLoginBTapped(_ sender: Any) {
        let available = userDefaults.bool(forKey: FJkInternetConnectionAvailable)
        if available {
            print("Cloud")
            guard let url = URL(string: "https://firejournalcloud.com") else { return }
            UIApplication.shared.open(url)
        } else {
            self.dismiss(animated: true, completion: nil)
            let alert = theNetworkUnavailable(errorString: "This app is not connected to the internet at this time.")
            self.present(alert,animated: true)
        }
    }
    
    func theNetworkUnavailable(errorString: String)->UIAlertController {
        let title = "Internet Activity"
        let errorString = errorString
        let alert = UIAlertController.init(title: title, message: errorString, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Thanks", style: .default, handler: {_ in
        })
        alert.addAction(okAction)
        //        self.alertI = 1
        return alert
    }
    
}
