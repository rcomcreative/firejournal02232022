//
//  TheStoreVC+DelegateExtensions.swift
//  Fire Journal
//
//  Created by DuRand Jones on 5/6/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import StoreKit
import CoreData

extension TheStoreVC {
    
        /// find the height for text area using the string associated with input
        /// - Parameter text: text entered in modals for form
        /// - Returns: returns the height for the label cell
    func configureLabelHeight(text: String ) -> CGFloat {
        var theFloat: CGFloat = 0.0
        let frame = self.view.frame
        let width = frame.width - 70
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 44))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = .systemFont(ofSize: 18)
        label.text = text
        label.sizeToFit()
        let labelFrame = label.frame
        theFloat = labelFrame.height
        label.removeFromSuperview()
        if theFloat < 44 {
            theFloat = 88
        }
        return theFloat
    }
    
//    MARK: - CELL CONFIGURATIONS-
    
    func configureLabelCell(_ cell: LabelCell, index: IndexPath) -> LabelCell {
        cell.tag = index.row
        let row = index.row
        cell.tag = row
        cell.modalTitleL.adjustsFontSizeToFitWidth = true
        cell.modalTitleL.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.modalTitleL.numberOfLines = 0
        cell.infoB.isHidden = true
        cell.infoB.alpha = 0.0
        cell.infoB.isEnabled = false
        cell.modalTitleL.font = cell.modalTitleL.font.withSize(16)
        switch row {
        case 3:
            cell.modalTitleL.text = membershipText2
        case 5:
            cell.modalTitleL.text = membershipText3
        default: break
        }
        
        return cell
    }
    
    func configureTheStoreButtonTVCell(_ cell: TheStoreButtonTVCell, index: IndexPath) -> TheStoreButtonTVCell {
        let row = index.row
        cell.tag = row
        cell.delegate = self
        switch row {
        case 2:
            cell.buttonType = TheStoreButtonTypes.quarterly
        case 4:
            cell.buttonType = TheStoreButtonTypes.annual
        case 6:
            cell.buttonType = TheStoreButtonTypes.login
        case 7:
            cell.buttonType = TheStoreButtonTypes.restore
        default: break
        }
        cell.configure()
        return cell
    }
    
    func configureTheStoreTextViewTVCell(_ cell: TheStoreTextViewTVCell, index: IndexPath) -> TheStoreTextViewTVCell {
        cell.tag = index.row
        cell.configure()
        return cell
    }
    
    func configureTheStoreTitleTVCell(_ cell: TheStoreTitleTVCell, index: IndexPath) -> TheStoreTitleTVCell {
        cell.tag = index.row
        cell.configure()
        return cell
    }
    
    func configureLabelTextFieldCell(_ cell: LabelTextFieldCell, index: IndexPath) -> LabelTextFieldCell {
        let row = index.row
        cell.tag = row
        switch row {
        default:
            cell.subjectL.isHidden = true
            cell.subjectL.alpha = 0.0
            cell.descriptionTF.isHidden = true
            cell.descriptionTF.isEnabled = false
            cell.descriptionTF.alpha = 0.0
        }
        return cell
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

extension TheStoreVC: TheStoreButtonTVCellDelegate {
    
    func theStoreButtonTapped(type: TheStoreButtonTypes, price: String) {
        switch type {
        case .quarterly:
            fjSKProduct = nil
            defaults.set(false, forKey: "subscriptionBought")
            purchaseQuarterlyProduct()
        case .annual:
            fjSKProduct = nil
            defaults.set(false, forKey: "subscriptionBought")
            purchaseAnnualProduct()
        case .login:
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
        case .restore:
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().restoreCompletedTransactions()
            let appReceiptRefreshRequest = SKReceiptRefreshRequest(receiptProperties: nil)
            appReceiptRefreshRequest.delegate = self
            appReceiptRefreshRequest.start()
        }
    }
    
    
}



extension TheStoreVC: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
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
                        delegate?.theStoreSubscriptionPurchased()
                    case .failed:
                        self.dismiss(animated: true, completion: nil)
                        alertUp = false
                        SKPaymentQueue.default().finishTransaction((transaction as? SKPaymentTransaction)!)
                        autoRenewableSubscription = false
                        let defaults = UserDefaults.standard
                        defaults.set(autoRenewableSubscription,forKey: "autoRenewableSubscriptionMade")
                        defaults.set(false, forKey: "subscriptionBought")
                        defaults.synchronize()
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
                        delegate?.theStoreSubscriptionPurchased()
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
