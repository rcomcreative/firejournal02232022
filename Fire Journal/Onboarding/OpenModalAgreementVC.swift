//
//  OpenModalAgreementVC.swift
//  dashboard
//
//  Created by DuRand Jones on 10/10/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit
import Foundation

protocol OpenModalAgreementVCDelegate: AnyObject {
    func theAgreementAgreedTo( yesNo: Bool )
}

class OpenModalAgreementVC: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var backgroundIV: UIImageView!
    @IBOutlet weak var logoHolderIV: UIImageView!
    @IBOutlet weak var agreeB: UIButton!
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var agreementTV: UITextView!
    
    let userDefaults = UserDefaults.standard
    
    weak var delegate:OpenModalAgreementVCDelegate? = nil
    
    let agreementText:String = "The terms and conditions that follow set forth a legal agreement (“Agreement”) between you (either an individual or an entity), the end user, and PureCommand, a Nevada corporation with its principal place of business at PureCommand, LLC Customer Service Section 3960 Howard Hughes Parkway Suite 500 Las Vegas, NV 89169, relating to the computer software known as Fire Journal® as well as any other intellectual property (or software from the line of emergency services data management products in all countries) if applicable (the \"Software\"). The term \"Software\" includes and these terms and conditions also apply to (i) any updates or upgrades to the Software that you may receive from time to time under a subscription service or other support arrangement, (ii) any add-in modules to the PureCommand software you may order and install from time to time, and (iii) software from third parties that may be incorporated into any PureCommand software.  Because this software license is visible after you install the software, please note the following: If you do not agree to these terms and conditions, promptly delete the software from your device and do not use it. Use of the software constitutes acceptable of these terms and conditions.\n\rThis is a license agreement and not an agreement for sale.\n\r1.A.   Grant of License.  PureCommand, LLC grants to you a nonexclusive, nontransferable license to use the Software and the printed and/or electronic user documentation (the \"Documentation\") accompanying the Software in accordance with this Agreement. If you have paid the license fee for a single-user license, this Agreement permits you to install and use one (1) copy of the Software on any single computer/device at any time (i.e., if you change computers/devices, you must de-install the Software from the old computer or device before installing it on the new computer/device) in the country in which you have your principal place of business. This license may not be transferred to another country.  If you have a network license version of the Software (an “SNL”), then at any time you may have as many copies of the Software in use in the country in which it is licensed as you have licenses.  The Software is \"in use\" on a computer/device when it is loaded into the temporary memory (i.e. RAM) or when a user is logged in.  If the number of computers/devices on which the Software is installed or the potential number of users of the Software exceeds the number of licenses you have purchased, then you must have an SNL version of the Software installed to assure that the number of concurrent users of the Software does not exceed the number of licenses purchased.  License suites consisting of bundles of separate modules (such as Command Journal Professional) cannot float separately from each other.  At the time of registration, you must inform us of the maximum number of potential users of the licenses you purchase.  We recommend you also inform us of the names of all potential users so that we can notify them of upcoming updates and other pertinent information.  If the Software is permanently installed on the hard disk or other storage device of a computer/device (other than a network server) and one person uses that computer more than 80% of the time it is in use, then that person may also use the Software on a portable or home computer or tablet (such as the iPad®) while the original copy is not in use.  (Due to export compliance issues, however, any person in the Asia-Pacific Region is restricted to using the Software on only one [1] computer.)  You will keep accurate and up-to-date records of the numbers and locations of all copies of the Software; will supervise and control the use of the Software in accordance with the terms of this Agreement; and will provide copies of such records to PureCommand, LLC upon reasonable request.\n\rSecurity Mechanisms.  PureCommand and its affiliated companies take all legal steps to eliminate piracy of their software products. In this context, the Software may include a security mechanism that can detect the installation or use of illegal copies of the Software, and collect and transmit data about those illegal copies. Data collected will not include any customer data created with the Software. By using the Software, you consent to such detection and collection of data, as well as its transmission and use if an illegal copy is detected. PureCommand also reserves the right to use a hardware lock device, license administration software, and/or a license authorization key to control access to the Software.  You may not take any steps to avoid or defeat the purpose of any such measures.\n\rInternet Tools and Services.  From time to time, a license of or basic subscription service for Software may include integration with and access to certain Internet tools and services developed by PureCommand, LLC. A base level of usage may be available at no extra charge for each license with additional usage available at an additional charge.  Please see a description of any Internet tools with the Software or on our website at www.purecommand.com for additional details.  Your use of Internet tools and services is also subject to the Terms of Use applicable to such tools and services.\n\rOwnership of the Software/Restrictions on Copying.  PureCommand, LLC or its licensors own and will retain all copyright, trademark, trade secret and other proprietary rights in and to the Software and the Documentation.  THE SOFTWARE AND THE DOCUMENTATION ARE PROTECTED BY COPYRIGHT LAWS AND OTHER INTELLECTUAL PROPERTY LAWS.  Each PureCommand licensor is a third-party beneficiary of this Agreement.  You obtain only such rights as are specifically provided in this Agreement.  You may copy the Software into any machine-readable form for back-up purposes and within the license restrictions noted herein.  You may not remove from the Software or Documentation any copyright or other proprietary rights notice or any disclaimer, and you shall reproduce on all copies of the Software made in accordance with this Agreement, all such notices and disclaimers.\n\rOther Restrictions on Use.  This Agreement is your proof of license to exercise the rights granted herein and must be retained by you.  Other than as permitted under the license grant herein, you may not use any portion of the Software separately from or independently of the Software (for example, the SQL software can only be used with the rest of the Enterprise PureCommand ICS software) and other than for your normal business purposes and you may not provide access to or use of the Software to any third party; consequently you may not sell, license, sublicense, transfer, assign, lease or rent (including via a timeshare arrangement) the Software or the license granted by this Agreement. You may not install or use the Software over the Internet, including, without limitation, use in connection with a Web hosting or similar service, or make the Software available to third parties via the Internet on your computer system or otherwise. You may not modify or make works derivative of the Software or make compilations or collective works that include the Software, and you may not analyze for purposes competitive to PureCommand, LLC, reverse-engineer, decompile, disassemble or otherwise attempt to discover the source code of the Software, except as permitted under applicable law, as it contains trade secrets (such as the Software’s structure, organization and code) of PureCommand, LLC and its licensors.\n\rSubscription Service.  If you purchase subscription services for the Software you have licensed hereunder by paying the fee therefor, PureCommand will provide you for such copy: 24 hour by 7 day/week on-line web access to \"down-load\" the latest updates to the Software; all major upgrades for the Software released during the subscription period; and email support services. From time to time, PureCommand may re-distribute software components as part of an update to the Software. You are eligible for such components and warrant that you will install them only if you possess a validly licensed copy of the PureCommand products to which they relate. The term of this service runs for one (1) year. It may be renewed from year to year thereafter by paying the appropriate renewal fee. Software that is delivered as an upgrade or update to a previous version of the licensed Software must replace the previous version – no additional license is granted; you may install only such number of updates as equal the number of subscription service fees for which you have paid.\n\rResponsibility for Selection and Use of Software.  You are responsible for the supervision, management and control of the use of the Software, and output of the Software, including, but not limited to:  (1) selection of the Software to achieve your intended results; (2) determining the appropriate uses of the Software and the output of the Software in your business; (3) establishing adequate independent procedures for testing the accuracy of the Software and any output; and (4) establishing adequate backup to prevent the loss of data in the event of a Software malfunction.  The Software is a tool that is intended to be used only by trained professionals.  It is not to be a substitute for professional judgment or independent testing of physical prototypes for product stress, safety and utility; you are solely responsible for any results obtained from using the Software.  Neither the Software nor any of its components are intended for use in the design or operation of nuclear facilities, life support systems, aircraft or other activities in which the failure of the Software or such components, or both, could lead to death, personal injury, or severe physical or environmental damage.\n\rLimited Warranty, Exceptions & Disclaimers\n\ra. Limited Warranty.  PURECOMMAND, LLC warrants that the Software will be free of defects in materials and will perform substantially in accordance with the Documentation for a period of ninety (90) days from the date of receipt by you.  PureCommand also warrants that any services it provides from time to time will be performed in a workmanlike manner in accordance with reasonable commercial practice.  PureCommand does not warrant that the Software or service will meet your requirements or that the operation of the Software will be uninterrupted or error free or that any internet tool or service will be completely secure.  PureCommand\'s entire liability and your sole remedy under this warranty shall be to use reasonable efforts to repair or replace the nonconforming media or Software or re-perform the service.  If such effort fails, PureCommand or PureCommand's distributor or reseller shall (i) refund the price you paid for the Software upon return of the nonconforming Software and a copy of your receipt or the price you paid for the service, as appropriate, or (ii) provide such other remedy as may be required by law.  Any replacement Software will be warranted for the remainder of the original warranty period or thirty (30) days from the date of receipt by you, whichever is longer.\n\rb. Exceptions.  PureCommand\'s limited warranty is void if breach of the warranty has resulted from (i) accident, corruption, misuse or neglect of the Software; (ii) acts or omissions by someone other than PureCommand; (iii) combination of the Software with products, material or software not provided by PureCommand or not intended for combination with the Software; or (iv) failure by you to incorporate and use all updates to the Software available from PureCommand.\n\r. Limitations on Warranties.  The express warranty set forth herein is the only warranty given by PureCommand with respect to the Software and Documentation furnished hereunder and any service supplied from time to time; to the maximum extent permitted by applicable law, PureCommand and its licensors, including without limitation Apple, Inc., make no other warranties, express, implied or arising by custom or trade usage, and specifically disclaim the warranties of merchantability, fitness for a particular purpose and non-infringement. In no event may you bring any claim, action or proceeding arising out of the warranty set forth herein more than one year after the date on which the breach of warranty occurred.\n\rd. Limitations on Liability.  You recognize that the price paid for the license rights herein may be substantially disproportionate to the value of the products to be designed, stored, managed or distributed in conjunction with the Software.  For the express purpose of limiting the liability of PureCommand and its licensors to an extent which is reasonably proportionate to the commercial value of this transaction, you agree to the following limitations on PureCommand and its licensors’ liability.  Except as required under local law, the liability of PureCommand and its licensors, whether in contract, tort (including negligence) or otherwise, arising out of or in connection with the Software or Documentation furnished hereunder and any service supplied from time to time shall not exceed the license fee you paid for the Software or any fee you paid for the service.  In no event shall PureCommand or its licensors be liable for direct, special, indirect, incidental, punitive or consequential damages (including, without limitation, damages resulting from loss of use, loss of data, loss of profits, loss of goodwill or loss of business) arising out of or in connection with the use of or inability to use the Software or Documentation furnished hereunder and any service supplied from time to time, even if PureCommand or its licensors have been advised of the possibility of such damages.  However, certain of the above limitations may not apply in some jurisdictions.\n\rCompliance with Laws and Indemnity.  You agree to comply with all local laws and regulations regarding the download, installation and/or use of the Software, the Documentation or both.  You agree to hold harmless and indemnify PureCommand, LLC and its subsidiaries, affiliates, officers and employees from and against any and all claims, suits or actions arising from or in any way related to your use of the Software and/or Documentation or your violation of this Agreement.\n\rGeneral Provisions.    This Agreement is the complete and exclusive statement of your agreement with PureCommand relating to the Software and subscription service and supersedes any other agreement, oral or written, or any other communications between you and PureCommand relating to the Software and subscription service; provided, however, that this Agreement shall not supersede the terms of any signed agreement between you and PureCommand relating to the Software and subscription service. This Agreement shall be governed by and construed and enforced in accordance with the substantive laws of the State of Nevada without regard to the United Nations Convention on Contracts for the International Sale of Goods and will be deemed a contract under seal. The English language version of this Agreement shall be the authorized text for all purposes, despite translations or interpretations of this Agreement into other languages.  If for any reason a court of competent jurisdiction finds any provision of this Agreement, or a portion thereof, to be unenforceable, that provision shall be enforced to the maximum extent permissible and the remainder of this Agreement shall remain in full force and effect.\n\rU.S. Government Restricted Rights. The Software is a “commercial item” as that term is defined at 48  C.F.R. 2.101 (OCT 1995), consisting of “commercial computer software” and “commercial software documentation” as such terms are used in 48 C.F.R. 12.212 (SEPT 1995) and is provided to the U.S. Government (a) for acquisition by or on behalf of civilian agencies, consistent with the policy set forth in 48 C.F.R. 12.212; or (b) for acquisition by or on behalf of units of the department of Defense, consistent with the policies set forth in 48 C.F.R. 227.7202-1 (JUN 1995) and 227.7202-4 (JUN 1995).\n\rIn the event that you receive a request from any agency of the U.S. government to provide Software with rights beyond those set forth above, you will notify PureCommand of the scope of the request and PureCommand will have five (5) business days to, in its sole discretion, accept or reject such request. For such contact purposes, you may reach PureCommand at: PureCommand, LLC Customer Service Section 3960 Howard Hughes Parkway Suite 500 Las Vegas, NV 89169"
    
    
    
    func roundViews() {
        self.view.layer.cornerRadius = 20
        self.view.clipsToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roundViews()
        agreementTV.text = agreementText
    }

    @IBAction func agreementBTapped(_ sender: Any) {
        let alertMessage:String = "Do you agree with the Terms of Use for Fire Journal?"
        let title:String = "Terms of Use"
        let alert = UIAlertController.init(title: title, message: alertMessage, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "I Agree", style: .default, handler: {_ in
            self.termsAgreedUpon(self)
        })
        alert.addAction(okAction)
        let notOkAction = UIAlertAction.init(title: "I Dissagree", style: .cancel, handler: {_ in
            print("I disagree")
            DispatchQueue.main.async {
                self.userDefaults.set(false, forKey: FJkUserAgreementAgreed)
            }
            self.dismiss(animated: true, completion: nil)
            self.delegate?.theAgreementAgreedTo(yesNo: false)
        })
        alert.addAction(notOkAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func termsAgreedUpon(_ send: Any) {
        DispatchQueue.main.async {
            self.userDefaults.set(true, forKey: FJkUserAgreementAgreed)
        }
        self.dismiss(animated: true, completion: nil)
        delegate?.theAgreementAgreedTo(yesNo: true)
    }
}
