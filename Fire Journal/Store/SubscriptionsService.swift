//
//  Subscriptions.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/26/17.
//  Copyright © 2017 PureCommandLLC. All rights reserved.
//

private let fjInAppSecret = "64246b70667e411db594ee2802e24ba1"
private let notificationKey = "kTHEREISA_SUBSCRIPTION"
private let notificationKeyTwo = "FJkWeAreAlreadySubscribed"
private let notificationKeyUserOperation = "FJkONEUSER_SUBSCRIPTIONOPERATION"

import Foundation
import StoreKit
import CoreData

@objc class SubscriptionsService: NSObject,SKProductsRequestDelegate {
    
    static let sessionIdSetNotification = Notification.Name("SubscriptionServiceSessionIdSetNotification")
    static let optionsLoadedNotification = Notification.Name("SubscriptionServiceOptionsLoadedNotification")
    static let restoreSuccessfulNotification = Notification.Name("SubscriptionServiceRestoreSuccessfulNotification")
    static let purchaseSuccessfulNotification = Notification.Name("SubscriptionServiceRestoreSuccessfulNotification")
    // Variables
    let MONTHLY_SUBSCRIPTION_PRODUCT_ID = "com.purecommand.FireJournal.sub.monthlysubscription"
    let QUARTERLY_SUBSCRIPTION_PRODUCT_ID = "com.purecommand.FireJournal.sub.quarterlysubscription"
    let YEARLY_SUBSCRIPTION_PRODUCT_ID = "com.purecommand.FireJournal.sub.yearlysubscription"
    let APPLE_SANDBOX_URL = "https://sandbox.itunes.apple.com/verifyReceipt"
    let APPLE_ITUNESTORE_RECEIPT_URL = "https://buy.itunes.apple.com/verifyReceipt"
    let FIRECLOUD_URL = "https://www.firejournalcloud.com/receipt/index.php"
    //    let FIRECLOUD_URL =  "https://dev.firejournalconnect.com/receipt/index.php"
    
    let defaults = UserDefaults.standard
    
    static let shared = SubscriptionsService()
    
    var subscribed:Bool = false
    var fjUserGuid = ""
    var fjUserEmail = ""
    var theUserName = ""
    var productID = ""
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
    var suscribe = UserDefaults.standard.integer(forKey: "fireJournal_connect_group")
    var productIdentifiers:NSSet
    
    var fetched = [FireJournalUser]()
    var context: NSManagedObjectContext!
    var theUser: FireJournalUser!
    let userDefaults = UserDefaults.standard
    var subscriptionBought: Bool = false
    var subscriptionIsLocallyCached: Bool = false
    
    //    MARK: -BACKGROUNDTASK-
    var bgTask : UIBackgroundTaskIdentifier = .invalid
    var bkgrndTask: BkgrndTask?
    var thereIsBackgroundTask: Bool = false
    
    lazy var userProvider: FireJournalUserProvider = {
        let provider = FireJournalUserProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var userContext: NSManagedObjectContext!
    
    private var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.formatterBehavior = .behavior10_4
        return formatter
    }()
    
    private override init() {
        productIdentifiers = NSSet(objects:
                                    MONTHLY_SUBSCRIPTION_PRODUCT_ID,
                                   QUARTERLY_SUBSCRIPTION_PRODUCT_ID,
                                   YEARLY_SUBSCRIPTION_PRODUCT_ID
        )
        super.init()
        print("SubscriptionsService init")
    }
    
    /**
     observer: FJkNORecordCKRGetUserFromCLOUD
     If no CKRecord is found when app opens and runCount is equal to 0
     this gets run
     Checks network, checks for FireJournalUser
     
     @param n nil
     */
    private func getTheUser(entity: String, attribute: String, sortAttribute: String) {
        
        subscriptionBought = userDefaults.bool(forKey: FJkSUBCRIPTIONBought)
        subscriptionIsLocallyCached = userDefaults.bool(forKey: FJkSUBSCRIPTIONIsLocallyCached)
        
        userContext = userProvider.persistentContainer.newBackgroundContext()
        if let users = userProvider.getTheUser(userContext) {
            let user = users.last
            if let objectID = user?.objectID {
                theUser = context.object(with: objectID) as? FireJournalUser
            }
        }
        if theUser != nil {
            if let guid = theUser.userGuid {
                fjUserGuid = guid
            }
            if let email = theUser.emailAddress {
                fjUserEmail = email
            }
            if let userName = theUser.userName {
                theUserName = userName
            }
        }
           
        self.fetchAvailableProducts()
        
        if !subscriptionBought {
            getAppReceipt()
            self.userDefaults.set(subscribed, forKey: FJkSUBCRIPTIONBought)
        }
        
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
        
        if (subscriptionIsLocallyCached) { return }
    }
    
    
    /// MARK: Fetch products if userGuid is provided
    func fetchAvailableProducts() {
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    /// Products Request
    ///
    /// - Parameters:
    ///   - request: SKProductsRequest
    ///   - response: SKProductsResponse
    @objc func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        fjProducts = response.products
        print("here are the products as they come in \(fjProducts)")
        
        if fjProducts.count > 0 {
            
            formatter.locale = fjProducts[0].priceLocale
            
            let monthly = "\(formatter.string(from: fjProducts[0].price)!)"
            let quarterly = "\(formatter.string(from: fjProducts[1].price)!)"
            let yearly = "\(formatter.string(from: fjProducts[2].price)!)"
            
            defaults.set(monthly, forKey: FJkSUBSCRIPTION1)
            defaults.set(quarterly, forKey: FJkSUBSCRIPTION2)
            defaults.set(yearly, forKey: FJkSUBSCRIPTION3)
            defaults.synchronize()
        }
        if thereIsBackgroundTask {
            bkgrndTask?.endBackgroundTask()
            thereIsBackgroundTask = false
        }
        
    }
    
    
    /// SKProductRequest
    ///
    /// - Parameters:
    ///   - request: SKRequest
    ///   - error: failed Request
    @objc func request(_ request: SKRequest, didFailWithError error: Error) {
        if request is SKProductsRequest {
            print("Subscription Options Failed Loading: \(error.localizedDescription)")
            if thereIsBackgroundTask {
                bkgrndTask?.endBackgroundTask()
                thereIsBackgroundTask = false
            }
            // for some clues see here: https://samritchie.net/2015/01/29/the-operation-couldnt-be-completed-sserrordomain-error-100/
        }
    }
    
    // MARK: - VALIDATE RECEIPT
    
    /// MARK: -GET THE RECEIPT
    /// if link fails ask for refresh of receipt
    @objc func getAppReceipt() {
        guard let receiptUrl = Bundle.main.appStoreReceiptURL, let receiptData = try? Data(contentsOf: receiptUrl)
        else {
            print("still no receipt, possible but unlikely to occur since this is the 'success' delegate method")
            let appReceiptRefreshRequest = SKReceiptRefreshRequest(receiptProperties: nil)
            if !thereIsBackgroundTask {
                bkgrndTask?.registerBackgroundTask()
                thereIsBackgroundTask = true
                appReceiptRefreshRequest.delegate = self
                appReceiptRefreshRequest.start()
            } else {
                bkgrndTask?.endBackgroundTask()
                thereIsBackgroundTask = false
            }
            return
        }
        validateAppReceipt(receiptData)
        //        guard let receiptURL = Bundle.main.appStoreReceiptURL else { print("nothing here to see appStoreReceiptURL")
        //            return }
        //        do {
        //            let receipt = try Data(contentsOf: receiptURL)
        //            print("validate")
        //            validateAppReceipt(receipt)
        //        } catch {
        //            print("get the receipt")
        //            let appReceiptRefreshRequest = SKReceiptRefreshRequest(receiptProperties: nil)
        //            if !thereIsBackgroundTask {
        //                bkgrndTask?.registerBackgroundTask()
        //                thereIsBackgroundTask = true
        //                appReceiptRefreshRequest.delegate = self
        //                appReceiptRefreshRequest.start()
        //            } else {
        //                bkgrndTask?.endBackgroundTask()
        //                thereIsBackgroundTask = false
        //            }
        //
        //        }
    }
    
    /// MARK: -REQUEST FINISHED
    ///
    /// - Parameter request: SKRequest
    @objc func requestDidFinish(_ request: SKRequest) {
        guard let receiptUrl = Bundle.main.appStoreReceiptURL, let receiptData = try? Data(contentsOf: receiptUrl)
        else {
            print("still no receipt, possible but unlikely to occur since this is the 'success' delegate method")
            return
        }
        validateAppReceipt(receiptData)
        //        do {
        //            guard let receiptURL = Bundle.main.appStoreReceiptURL else { return }
        //            let receipt = try Data(contentsOf: receiptURL)
        //            validateAppReceipt(receipt)
        //        } catch {
        //            print("still no receipt, possible but unlikely to occur since this is the 'success' delegate method")
        //        }
    }
    
    //MARK: - VALIDATE RECEIPT
    /// validation of receipt parse data returned notify all with notificationKey
    ///
    /// - Parameter receipt: the receipt from requestDidFinish is evaluated and JSOn worked through
    @objc func validateAppReceipt(_ receipt: Data) {
        if !thereIsBackgroundTask {
            bkgrndTask?.registerBackgroundTask()
            thereIsBackgroundTask = true
        }
        
        //        DispatchQueue.main.async {
        /*  Note 1: This is not local validation, the app receipt is sent to the app store for validation as explained here:
         https://developer.apple.com/library/content/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateRemotely.html#//apple_ref/doc/uid/TP40010573-CH104-SW1
         Note 2: Refer to the url above. For good reasons apple recommends receipt validation follow this flow:
         device -> your trusted server -> app store -> your trusted server -> device
         In order to be a working example the validation url in this code simply points to the app store's sandbox servers.
         Depending on how you set up the request on your server you may be able to simply change the
         structure of requestDictionary and the contents of validationURLString.
         */
        //        let body = [
        //            "receipt-data": receipt.base64EncodedString(),
        //            "password": fjInAppSecret
        //        ]
        let body = [
            "receipt": receipt.base64EncodedString(),
            "password": fjInAppSecret,
            "userguid": fjUserGuid,
            "useremail": fjUserEmail
        ]
        
        guard JSONSerialization.isValidJSONObject(body) else {  print("requestDictionary is not valid JSON");  return }
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: body, options: [])
            
            let validationURLString = FIRECLOUD_URL
            guard let validationURL = URL(string: validationURLString) else { print("the validation url could not be created, unlikely error"); return }
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForResource = TimeInterval(180)
            let session = URLSession(configuration: sessionConfig)
            
            var request = URLRequest.init(url: validationURL, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 180)//(url: validationURL)
            request.httpMethod = "POST"
            //            request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            request.httpBody = bodyData
            print("here is the request \(String(describing: request.httpMethod))")
            //                print("hello")
            let task = session.uploadTask(with: request, from: bodyData) { (data, response, error) in
                if let data = data , error == nil {
                    do {
                        
                        let appReceiptJSON = try JSONSerialization.jsonObject(with: data, options: [])  as! [String:Any]
                        print("here is appReceiptJSON \(appReceiptJSON)")
                        let message = (appReceiptJSON["success"] as! Bool);
                        
                        if message {
                            let activeReceiptExpirationDate = (appReceiptJSON["activeReceiptExpirationDate"] as!
                                                                String)
                            let activeReceiptProductIdentifier = (appReceiptJSON["activeReceiptProductIdentifier"] as! String)
                            let activeReceiptTransactionIdentifier = (appReceiptJSON["activeReceiptTransactionIdentifier"] as! String)
                            self.subscribed = true
                            self.defaults.set(self.subscribed, forKey:"subscriptionBought")
                            self.defaults.synchronize()
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: notificationKey), object: nil, userInfo: ["subscription":"1","activeReceiptExpirationDate":activeReceiptExpirationDate,"activeReceiptProductIdentifier":activeReceiptProductIdentifier,"activeReceiptTransactionIdentifier":activeReceiptTransactionIdentifier])
                            }
                            
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: notificationKeyUserOperation), object: nil, userInfo: [:])
                                if self.thereIsBackgroundTask {
                                    self.bkgrndTask?.endBackgroundTask()
                                    self.thereIsBackgroundTask = false
                                }
                                
                            }
                            print("success. here is the json representation of the app receipt: \(appReceiptJSON)")
                        } else {
                            self.subscribed = false
                            self.defaults.set(self.subscribed, forKey:"subscriptionBought")
                            self.defaults.synchronize()
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: notificationKey), object: nil, userInfo: ["subscription":"0"])
                                if self.thereIsBackgroundTask {
                                    self.bkgrndTask?.endBackgroundTask()
                                    self.thereIsBackgroundTask = false
                                }
                            }
                        }
                        
                        
                    } catch let error as NSError {
                        print("SubswcriptionService line 296 Fetch Error: \(error.localizedDescription)")
                        if self.thereIsBackgroundTask {
                            self.bkgrndTask?.endBackgroundTask()
                            self.thereIsBackgroundTask = false
                        }
                    }
                    
                } else {
                    print("the upload task returned an error: \(String(describing: error))")
                    if self.thereIsBackgroundTask {
                        self.bkgrndTask?.endBackgroundTask()
                        self.thereIsBackgroundTask = false
                    }
                }
            }
            task.resume()
        }  catch let error as NSError {
            print("json serialization failed with error: \(error)")
            if self.thereIsBackgroundTask {
                self.bkgrndTask?.endBackgroundTask()
                self.thereIsBackgroundTask = false
            }
        }
    }
}
// MARK: - SKProductsRequestDelegate
