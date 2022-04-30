//
//  SettingsInfoVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/29/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation

protocol SettingsInfoVCDelegate: AnyObject {
    func settingsInfoReturnToSettings()
}

class SettingsInfoVC: UIViewController {
    
    weak var delegate: SettingsInfoVCDelegate? = nil
    let nc = NotificationCenter.default
    var titleName: String = ""
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    var compact:SizeTrait = .regular
    var collapsed:Bool = false
    
    var settingsType: FJSettings!
    var subject: String = ""
    var bodyText: String = ""
    
    let theBackgroundView = UIView()
    let theHeaderView = UIView()
    let headerL = UILabel()
    let descriptionTV = UITextView()


    override func viewDidLoad() {
        super.viewDidLoad()
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        configureNavigationHeader()
        configureText()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureText()
        configureObjects()
        configureNSLayouts()
    }
    

}

extension SettingsInfoVC {
    
    func configureText() {
        switch settingsType {
        case .cloud:
            subject = "Membership"
            bodyText = cloudText()
        case .terms:
            subject = "Terms and Conditions"
            bodyText = termsOfService()
        case .privacy:
            subject = "User Privacy"
            bodyText = privacyText()
        default: break
        }
    }
    
    func configureObjects() {
        
        theBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        theHeaderView.translatesAutoresizingMaskIntoConstraints = false
        headerL.translatesAutoresizingMaskIntoConstraints = false
        descriptionTV.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(theBackgroundView)
        self.view.addSubview(theHeaderView)
        self.view.addSubview(headerL)
        self.view.addSubview(descriptionTV)
        
        theHeaderView.backgroundColor = UIColor(named: "FJBlueColor")
        
        headerL.textAlignment = .left
        headerL.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        headerL.textColor = .white
        headerL.adjustsFontForContentSizeCategory = false
        headerL.lineBreakMode = NSLineBreakMode.byWordWrapping
        headerL.numberOfLines = 0
        headerL.text = subject
        
        descriptionTV.textAlignment = .left
        descriptionTV.font = .systemFont(ofSize: 16)
        descriptionTV.textColor = .label
        descriptionTV.adjustsFontForContentSizeCategory = true
        descriptionTV.layer.borderColor = UIColor(named: "FJBlueColor" )?.cgColor
        descriptionTV.layer.borderWidth = 0.5
        descriptionTV.layer.cornerRadius = 8
        descriptionTV.isUserInteractionEnabled = true
        descriptionTV.isScrollEnabled = true
        descriptionTV.text = bodyText
        
    }
    
    func configureNSLayouts() {
        NSLayoutConstraint.activate([
            
            theBackgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            theBackgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            theBackgroundView.topAnchor.constraint(equalTo: self.view.topAnchor),
            theBackgroundView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            theHeaderView.leadingAnchor.constraint(equalTo: theBackgroundView.leadingAnchor),
            theHeaderView.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor),
            theHeaderView.topAnchor.constraint(equalTo: theBackgroundView.topAnchor),
            theHeaderView.heightAnchor.constraint(equalToConstant: 100),
            
            headerL.leadingAnchor.constraint(equalTo: theHeaderView.leadingAnchor, constant: 25),
            headerL.trailingAnchor.constraint(equalTo: theHeaderView.trailingAnchor, constant: -36),
            headerL.heightAnchor.constraint(equalToConstant: 50),
            headerL.centerYAnchor.constraint(equalTo: theHeaderView.centerYAnchor),
            
            descriptionTV.leadingAnchor.constraint(equalTo: headerL.leadingAnchor),
            descriptionTV.trailingAnchor.constraint(equalTo: headerL.trailingAnchor),
            descriptionTV.topAnchor.constraint(equalTo: theHeaderView.bottomAnchor, constant: 15),
            descriptionTV.bottomAnchor.constraint(equalTo: theBackgroundView.bottomAnchor, constant: -40),
            
            ])
    }
    
    func configureNavigationHeader() {
//        if Device.IS_IPHONE {
            let listButton = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(goBackToSettings(_:)))
            navigationItem.leftBarButtonItem = listButton
            navigationItem.setLeftBarButtonItems([listButton], animated: true)
            navigationItem.leftItemsSupplementBackButton = false
            let regularBarButtonTextAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 150))
            ]
            listButton.setTitleTextAttributes(regularBarButtonTextAttributes, for: .normal)
            listButton.setTitleTextAttributes(regularBarButtonTextAttributes, for: .highlighted)
//        }
        
        
        if (Device.IS_IPHONE){
            self.navigationController?.navigationBar.barTintColor = UIColor(named: "FJBlueColor")
            self.navigationController?.navigationBar.isTranslucent = false
        } else {
            let navigationBarAppearace = UINavigationBar.appearance()
            navigationBarAppearace.tintColor = UIColor.black
            navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        }
    }
    
    @objc func updateTheData(_ sender: Any) {
        if collapsed {
            delegate?.settingsInfoReturnToSettings()
        } else {
        DispatchQueue.main.async {
            self.nc.post(name:Notification.Name(rawValue:FJkSETTINGS_FROM_MASTER),
                         object: nil,
                         userInfo: ["sizeTrait":self.compact])
        }
        }
    }
    
    @objc func goBackToSettings(_ sender: Any) {
        if collapsed {
            delegate?.settingsInfoReturnToSettings()
        } else {
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:FJkSETTINGS_FROM_MASTER),
                             object: nil,
                             userInfo: ["sizeTrait":self.compact])
            }
        }
    }
    
    func termsOfService()->String {
        let terms:String = "The terms and conditions that follow set forth a legal agreement (“Agreement”) between you (either an individual or an entity), the end user, and PureCommand, a Nevada corporation with its principal place of business at PureCommand, LLC Customer Service Section 3960 Howard Hughes Parkway Suite 500 Las Vegas, NV 89169, relating to the computer software known as Fire Journal® as well as any other intellectual property (or software from the line of emergency services data management products in all countries) if applicable (the \"Software\"). The term \"Software\" includes and these terms and conditions also apply to (i) any updates or upgrades to the Software that you may receive from time to time under a subscription service or other support arrangement, (ii) any add-in modules to the PureCommand software you may order and install from time to time, and (iii) software from third parties that may be incorporated into any PureCommand software.  Because this software license is visible after you install the software, please note the following: If you do not agree to these terms and conditions, promptly delete the software from your device and do not use it. Use of the software constitutes acceptable of these terms and conditions.\n\rThis is a license agreement and not an agreement for sale.\n\r1.A.   Grant of License.  PureCommand, LLC grants to you a nonexclusive, nontransferable license to use the Software and the printed and/or electronic user documentation (the \"Documentation\") accompanying the Software in accordance with this Agreement. If you have paid the license fee for a single-user license, this Agreement permits you to install and use one (1) copy of the Software on any single computer/device at any time (i.e., if you change computers/devices, you must de-install the Software from the old computer or device before installing it on the new computer/device) in the country in which you have your principal place of business. This license may not be transferred to another country.  If you have a network license version of the Software (an “SNL”), then at any time you may have as many copies of the Software in use in the country in which it is licensed as you have licenses.  The Software is \"in use\" on a computer/device when it is loaded into the temporary memory (i.e. RAM) or when a user is logged in.  If the number of computers/devices on which the Software is installed or the potential number of users of the Software exceeds the number of licenses you have purchased, then you must have an SNL version of the Software installed to assure that the number of concurrent users of the Software does not exceed the number of licenses purchased.  License suites consisting of bundles of separate modules (such as Command Journal Professional) cannot float separately from each other.  At the time of registration, you must inform us of the maximum number of potential users of the licenses you purchase.  We recommend you also inform us of the names of all potential users so that we can notify them of upcoming updates and other pertinent information.  If the Software is permanently installed on the hard disk or other storage device of a computer/device (other than a network server) and one person uses that computer more than 80% of the time it is in use, then that person may also use the Software on a portable or home computer or tablet (such as the iPad®) while the original copy is not in use.  (Due to export compliance issues, however, any person in the Asia-Pacific Region is restricted to using the Software on only one [1] computer.)  You will keep accurate and up-to-date records of the numbers and locations of all copies of the Software; will supervise and control the use of the Software in accordance with the terms of this Agreement; and will provide copies of such records to PureCommand, LLC upon reasonable request.\n\rSecurity Mechanisms.  PureCommand and its affiliated companies take all legal steps to eliminate piracy of their software products. In this context, the Software may include a security mechanism that can detect the installation or use of illegal copies of the Software, and collect and transmit data about those illegal copies. Data collected will not include any customer data created with the Software. By using the Software, you consent to such detection and collection of data, as well as its transmission and use if an illegal copy is detected. PureCommand also reserves the right to use a hardware lock device, license administration software, and/or a license authorization key to control access to the Software.  You may not take any steps to avoid or defeat the purpose of any such measures.\n\rInternet Tools and Services.  From time to time, a license of or basic subscription service for Software may include integration with and access to certain Internet tools and services developed by PureCommand, LLC. A base level of usage may be available at no extra charge for each license with additional usage available at an additional charge.  Please see a description of any Internet tools with the Software or on our website at www.purecommand.com for additional details.  Your use of Internet tools and services is also subject to the Terms of Use applicable to such tools and services.\n\rOwnership of the Software/Restrictions on Copying.  PureCommand, LLC or its licensors own and will retain all copyright, trademark, trade secret and other proprietary rights in and to the Software and the Documentation.  THE SOFTWARE AND THE DOCUMENTATION ARE PROTECTED BY COPYRIGHT LAWS AND OTHER INTELLECTUAL PROPERTY LAWS.  Each PureCommand licensor is a third-party beneficiary of this Agreement.  You obtain only such rights as are specifically provided in this Agreement.  You may copy the Software into any machine-readable form for back-up purposes and within the license restrictions noted herein.  You may not remove from the Software or Documentation any copyright or other proprietary rights notice or any disclaimer, and you shall reproduce on all copies of the Software made in accordance with this Agreement, all such notices and disclaimers.\n\rOther Restrictions on Use.  This Agreement is your proof of license to exercise the rights granted herein and must be retained by you.  Other than as permitted under the license grant herein, you may not use any portion of the Software separately from or independently of the Software (for example, the SQL software can only be used with the rest of the Enterprise PureCommand ICS software) and other than for your normal business purposes and you may not provide access to or use of the Software to any third party; consequently you may not sell, license, sublicense, transfer, assign, lease or rent (including via a timeshare arrangement) the Software or the license granted by this Agreement. You may not install or use the Software over the Internet, including, without limitation, use in connection with a Web hosting or similar service, or make the Software available to third parties via the Internet on your computer system or otherwise. You may not modify or make works derivative of the Software or make compilations or collective works that include the Software, and you may not analyze for purposes competitive to PureCommand, LLC, reverse-engineer, decompile, disassemble or otherwise attempt to discover the source code of the Software, except as permitted under applicable law, as it contains trade secrets (such as the Software’s structure, organization and code) of PureCommand, LLC and its licensors.\n\rSubscription Service.  If you purchase subscription services for the Software you have licensed hereunder by paying the fee therefor, PureCommand will provide you for such copy: 24 hour by 7 day/week on-line web access to \"down-load\" the latest updates to the Software; all major upgrades for the Software released during the subscription period; and email support services. From time to time, PureCommand may re-distribute software components as part of an update to the Software. You are eligible for such components and warrant that you will install them only if you possess a validly licensed copy of the PureCommand products to which they relate. The term of this service runs for one (1) year. It may be renewed from year to year thereafter by paying the appropriate renewal fee. Software that is delivered as an upgrade or update to a previous version of the licensed Software must replace the previous version – no additional license is granted; you may install only such number of updates as equal the number of subscription service fees for which you have paid.\n\rResponsibility for Selection and Use of Software.  You are responsible for the supervision, management and control of the use of the Software, and output of the Software, including, but not limited to:  (1) selection of the Software to achieve your intended results; (2) determining the appropriate uses of the Software and the output of the Software in your business; (3) establishing adequate independent procedures for testing the accuracy of the Software and any output; and (4) establishing adequate backup to prevent the loss of data in the event of a Software malfunction.  The Software is a tool that is intended to be used only by trained professionals.  It is not to be a substitute for professional judgment or independent testing of physical prototypes for product stress, safety and utility; you are solely responsible for any results obtained from using the Software.  Neither the Software nor any of its components are intended for use in the design or operation of nuclear facilities, life support systems, aircraft or other activities in which the failure of the Software or such components, or both, could lead to death, personal injury, or severe physical or environmental damage.\n\rLimited Warranty, Exceptions & Disclaimers\n\ra. Limited Warranty.  PURECOMMAND, LLC warrants that the Software will be free of defects in materials and will perform substantially in accordance with the Documentation for a period of ninety (90) days from the date of receipt by you.  PureCommand also warrants that any services it provides from time to time will be performed in a workmanlike manner in accordance with reasonable commercial practice.  PureCommand does not warrant that the Software or service will meet your requirements or that the operation of the Software will be uninterrupted or error free or that any internet tool or service will be completely secure.  PureCommand\'s entire liability and your sole remedy under this warranty shall be to use reasonable efforts to repair or replace the nonconforming media or Software or re-perform the service.  If such effort fails, PureCommand or PureCommand's distributor or reseller shall (i) refund the price you paid for the Software upon return of the nonconforming Software and a copy of your receipt or the price you paid for the service, as appropriate, or (ii) provide such other remedy as may be required by law.  Any replacement Software will be warranted for the remainder of the original warranty period or thirty (30) days from the date of receipt by you, whichever is longer.\n\rb. Exceptions.  PureCommand\'s limited warranty is void if breach of the warranty has resulted from (i) accident, corruption, misuse or neglect of the Software; (ii) acts or omissions by someone other than PureCommand; (iii) combination of the Software with products, material or software not provided by PureCommand or not intended for combination with the Software; or (iv) failure by you to incorporate and use all updates to the Software available from PureCommand.\n\rc. Limitations on Warranties.  The express warranty set forth herein is the only warranty given by PureCommand with respect to the Software and Documentation furnished hereunder and any service supplied from time to time; to the maximum extent permitted by applicable law, PureCommand and its licensors, including without limitation Apple, Inc., make no other warranties, express, implied or arising by custom or trade usage, and specifically disclaim the warranties of merchantability, fitness for a particular purpose and non-infringement. In no event may you bring any claim, action or proceeding arising out of the warranty set forth herein more than one year after the date on which the breach of warranty occurred.\n\r. Limitations on Liability.  You recognize that the price paid for the license rights herein may be substantially disproportionate to the value of the products to be designed, stored, managed or distributed in conjunction with the Software.  For the express purpose of limiting the liability of PureCommand and its licensors to an extent which is reasonably proportionate to the commercial value of this transaction, you agree to the following limitations on PureCommand and its licensors’ liability.  Except as required under local law, the liability of PureCommand and its licensors, whether in contract, tort (including negligence) or otherwise, arising out of or in connection with the Software or Documentation furnished hereunder and any service supplied from time to time shall not exceed the license fee you paid for the Software or any fee you paid for the service.  In no event shall PureCommand or its licensors be liable for direct, special, indirect, incidental, punitive or consequential damages (including, without limitation, damages resulting from loss of use, loss of data, loss of profits, loss of goodwill or loss of business) arising out of or in connection with the use of or inability to use the Software or Documentation furnished hereunder and any service supplied from time to time, even if PureCommand or its licensors have been advised of the possibility of such damages.  However, certain of the above limitations may not apply in some jurisdictions.\n\rCompliance with Laws and Indemnity.  You agree to comply with all local laws and regulations regarding the download, installation and/or use of the Software, the Documentation or both.  You agree to hold harmless and indemnify PureCommand, LLC and its subsidiaries, affiliates, officers and employees from and against any and all claims, suits or actions arising from or in any way related to your use of the Software and/or Documentation or your violation of this Agreement.\n\rGeneral Provisions.    This Agreement is the complete and exclusive statement of your agreement with PureCommand relating to the Software and subscription service and supersedes any other agreement, oral or written, or any other communications between you and PureCommand relating to the Software and subscription service; provided, however, that this Agreement shall not supersede the terms of any signed agreement between you and PureCommand relating to the Software and subscription service. This Agreement shall be governed by and construed and enforced in accordance with the substantive laws of the State of Nevada without regard to the United Nations Convention on Contracts for the International Sale of Goods and will be deemed a contract under seal. The English language version of this Agreement shall be the authorized text for all purposes, despite translations or interpretations of this Agreement into other languages.  If for any reason a court of competent jurisdiction finds any provision of this Agreement, or a portion thereof, to be unenforceable, that provision shall be enforced to the maximum extent permissible and the remainder of this Agreement shall remain in full force and effect.\n\rU.S. Government Restricted Rights. The Software is a “commercial item” as that term is defined at 48  C.F.R. 2.101 (OCT 1995), consisting of “commercial computer software” and “commercial software documentation” as such terms are used in 48 C.F.R. 12.212 (SEPT 1995) and is provided to the U.S. Government (a) for acquisition by or on behalf of civilian agencies, consistent with the policy set forth in 48 C.F.R. 12.212; or (b) for acquisition by or on behalf of units of the department of Defense, consistent with the policies set forth in 48 C.F.R. 227.7202-1 (JUN 1995) and 227.7202-4 (JUN 1995).\n\rIn the event that you receive a request from any agency of the U.S. government to provide Software with rights beyond those set forth above, you will notify PureCommand of the scope of the request and PureCommand will have five (5) business days to, in its sole discretion, accept or reject such request. For such contact purposes, you may reach PureCommand at: PureCommand, LLC Customer Service Section 3960 Howard Hughes Parkway Suite 500 Las Vegas, NV 89169\n\nUpdated December 4, 2018\n\n\n\n\n\n\n\n\n\n\n\n"
        return terms
    }
    
    func cloudText() -> String {
        let cloud = """
        Advanced Reporting and Career Tracking

        As a firefighter, you understand the importance of keeping track of important milestones in your life and career. Being a “member” of your department is something to be proud of - to know that you’re serving your community to the best of your ability.

        Fire Journal Membership brings a never before seen level of accountability and service history to firefighters everywhere. Once you become a member, the capabilities of Fire Journal (the iOS app) are extended, and you’ll gain important insight about your firefighting career.

        Fire Journal Members adds reporting and analysis to your career - how much are you working? What are the important fires or rescues you’ve participated in? How has your career evolved over time? If you’re working on promoting, track some or all of your study sessions, partners, and test results. There’s really no limit to the ways Fire Journal Membership can benefit you and your firefighting career.

        CAPABILITIES:
        Fire Journal Membership builds on the functions found in the free downoadable app. Some of the immediate benefits include:

        Automatic backup of your journal, projects, incidents, and form data
        Automatic sync between your iOS devices (for example, an iPhone and an iPad) - Fire Journal is a “universal app”
        Secure access to a private cloud environment, configured specifically for you (access the cloud from your iOS device, or from a Mac or PC computer)
        Track and review trends and reports related to journal entries and incidents
        Evaluate history of calls for service, types of incidents, and what took place from arrival to clearing the scene
        Review your journal and incident history via a map, highlighting key incidents and related activities while on scene
        Share form data from ICS-214 and other forms in Government approved formats (as PDF files)
        Utilize Journal and Incident calendaring
        Utilize search functions to find what you need, when you need it
        24/7 access to your own Fire Journal customer support portal

        As new capabilities are introduced to Fire Journal Membership, you’ll gain acces without having to change the status or longevity of your membership.

        Best of all, Fire Journal Membership is extremely affordable, and can be purchased as either a recurring monthly subscription, or as a single payment annual subscription (best savings). Every membership starts off with 60 days of FREE access to Fire Journal Cloud. If you decide its not for you, follow Apple’s guidelines and cancel your subscription. It’s that easy.

        INVESTMENT:
        With either plan, you get the first 60 days of Fire Journal Membership for free. During that time period, if you decide it’s not for you, simply cancel, no questions asked.

        SILVER PLAN: $7.99 per month, paid each month - no contract required

        GOLD PLAN: $3.33 per month, paid as a single annual payment

        The total annual subscription fee (GOLD PLAN) is $39.99. Try Fire Journal Membership for 60 days for FREE, then continue with either plan above. You may upgrade a SILVER PLAN to a GOLD PLAN at any time.

        NOTE: If you update your devices, you may re-connect your Fire Journal Membership using the “Restore Purchase” button.

        IMPORTANT MEMBERSHIP/SUBSCRIPTION INFORMATION:
        Fire Journal Membership is a recurring subscription. If you decide to purchase a membership subscription, you’ll receive an initial FREE 60 DAY TRIAL. Once the free trial  period concludes, your subscription will automatically engage and payment will be charged to the credit card that is part of your “dot Mac” or “iCloud” membership. You may disable “Auto renewal” at any time by going to “Settings” in the iOS app once you have completed downloading and installing the Fire Journal app into your smartphone device.

        For additional information, please see our terms of use via our website:
        http://purecommand.com/terms/

        You may also review our Private Policy by visiting our website:
        http://purecommand.com/privacy/

        To learn more about PureCommand and our support for the fire service, visit our website:
        httpw://www.purecommand.com

        Thank you for becoming part of the Fire Journal family.
        """
        return cloud
    }
    
    func privacyText()->String {
        let privacy = "PRIVACY POLICY\n\nPureCommand, LLC. (“PureCommand,” or “we”) wants you to feel secure relative to how we work with you, as you use either our web-based or iOS-based software. We want you to be familiar with the type of information we collect from you, and how we use it. \n\nRead through this document, which we’re calling our “Privacy Policy,” and gain a better understanding about the information we collect relative to your use of our apps and services. \n\nThe “Services” include our “Fire Journal Cloud” web application, the “Fire Journal” iOS universal application, any other mobile support apps, our website (www.purecommand.com), our customer service portal, and any related services or digital tools connected with the above. Fire Journal is our primary mobile (iOS) application, or “app.” Our services include our web-based Fire Journal Cloud app, our CRM support portal, any videos we present via social media or YouTube™, as well as live training presentations.  \n\nBy using the Services, you agree that you are accepting the practices that we have outlined in this Policy, and that you consent to having your data transferred to and processed in the United States, where our facilities are located. This Privacy Policy describes the information we collect through the Services, how we may use that information, and with whom we may share it. \n\nThis Privacy Policy is organized according to the sections below:\n\nInformation We Obtain \nHow We Use the Information We Obtain \nSharing of Information \nGeneral \n\nINFORMATION WE GATHER \n\nThere are three ways in which we may obtain personally identifying information from you: you may submit it; we collect it automatically through our online Services; or we collect it automatically via our Mobile Apps. Different types of information may be collected through each channel, and you should understand both how we do this and what types of information we collect on each channel. \n\nInformation You Submit You may choose to provide us with personal information through the Services, such as through forms, account portals, interfaces, and interactions with other customer support portals and channels:\n\nContact information, such as your name and email address.\nOther information about yourself, such as your age, gender, location, date of birth, language preference or interests.\nYour photograph.\n\nInformation related or connected to an account with a third-party service that you use to sign up or log in to the Services, or when you associate that account with the Services. For instance, when you associate your Facebook account with our Services, we may receive your public profile (name, profile picture, age range, gender, language, country and other public information), your friend list, your contacts, and your email address. If you sign up, log in with, or connect the Services with accounts you may have with other third-party services, such as Twitter, Instagram, or Tumblr, we may obtain similar information from those platforms.\n\nYou may also submit original content to us, which is covered under licenses set forth in our Terms of Service, describing other rights that you grant to us and other users.\n\nInformation We Collect by Automated Means Through the Services\n\nWe also may collect certain information from you by automated means, using technologies such as cookies, Web server logs, Web beacons and JavaScript.\n\nCookies are files that websites send to your computer or other Internet-connected device to uniquely identify your browser or to store information or settings on your device. Our site may use HTTP cookies, HTML5 cookies and other types of local storage (such as browser-based or plugin-based local storage). Your browser may tell you how to be notified when you receive certain types of cookies and how to restrict or disable certain cookies. Please note, however, that without cookies you may not be able to use all of the features of the Services or other websites and online services.\n\nIn conjunction with the gathering of information through cookies, our Web servers may log information such as your device type, operating system type, browser type, domain, and other system settings, as well as the language your system uses and the country and time zone where your device is located. The Web server logs also may record information such as the address of the Web page that referred you to our Site and the IP address of the device you use to connect to the Services. They also may log information about your interaction with this Site, such as which pages you visit. To control which Web servers collect information by automated means, we may place tags on our Web pages called “Web beacons,” which are small files that link Web pages to particular Web servers and their cookies. We also may send instructions to your device using JavaScript or other computer languages to gather the sorts of information described above and other details your interactions with the Site.\n\nWe may use third-party Web analytics services in connection with providing the Services, including but not limited to Google Analytics, Mixpanel, Flurry, and Intercom. These service providers use the technology described above to help us analyze how our users use the Site. The information collected by the technology (including your IP address) will be disclosed to or collected directly by these services providers, who use the information to evaluate your use of the Site. To learn about opting out of Google Analytics, https://tools.google.com/dlpage/gaoptout. To learn about opting out of Mixpanel, https://mixpanel.com/privacy/. To learn about opting out of Flurry, https://developer.yahoo.com/flurry/end-user-opt-out/. To learn about opting out of Intercom, https://docs.intercom.com/pricing-privacy-and-terms/updating-your-privacy-policy. \n\nOn certain occasions, you may encounter a technical problem that could require troubleshooting by our customer support staff. If this should become necessary, you may be asked to share with us information about your use of Fire Journal that is more detailed than the information we collect by automated means. For example we may ask you to provide specific documents and files associated with the Services or with the Fire Journal app. Some of these files may contain personally identifying information. If you provide such additional information, it will only be used in connection with our efforts to diagnose and solve your technical problem, and to improve the Services and Fire Journal, and will be treated in accordance with this Privacy Policy.\n\nHOW WE USE THE INFORMATION WE OBTAIN\n\nWe may use the information we obtain through the Services to provide the Services and fulfill the immediate purpose for which it was requested, as well as for other purposes. These purposes may include:\n\nProviding, administering and communicating with you about products, services, events and promotions (including by sending you newsletters and other marketing communications).\nPerforming diagnostics and analysis to evaluate how our Services operate, and how people are using them.\nProcessing, evaluating and responding to your requests, inquiries and applications.\nManaging our customer information databases.\nAdministering contests, sweepstakes, and surveys.\nCustomizing your experience with the Services.\nOperating, evaluating, and improving our business (including developing new products and services; managing our communications; performing market research, data analytics, and data appends; determining and managing the effectiveness of our advertising and marketing; analyzing our products and Services; and performing accounting, auditing, billing, reconciliation, and collection activities).\nProtecting against and preventing fraud, unauthorized transactions, security issues, claims and other liabilities, and managing risk exposure and quality.\nComplying with and enforcing applicable legal requirements, industry standards and our policies and terms, such as our Terms of Service.\nProviding customer support and diagnostic assistance, for instance, by reviewing information collected from the Services and from the Pencil stylus or other hardware and tools you use.\nSometimes, we may combine certain parts of this information. For instance, when we provide you with customer support or other assistance, we may combine your account information and other personal information you’ve provided to us with information about your usage of the Services or Fire Journal.\n\nSHARING OF INFORMATION\n\nWe may share or allow you to share personal information as part of the Services. For example your user name and other account details may be associated with content and comments you post on or through the Services. We may allow you to post information to your social network account if your settings allow for such sharing. When you do this, Information you submit to a third-party widget or plugin on our Services is collected directly by the provider of that widget or plugin and is not subject to our Privacy Policy.\n\nWe also may disclose information about you: (i) if we are required to do so by law, regulation or legal process, such as a court order or subpoena; (ii) in response to requests by government agencies, such as law enforcement authorities; or (iii) when we believe disclosure is necessary or appropriate to prevent physical, financial or other harm, injury or loss; or (iv) in connection with an investigation of suspected or actual unlawful activity. We also may disclose aggregated or non-identifiable information to third parties in a manner that does not identify particular users.\n\nIf we sell or transfer all or a portion of our business or assets (including in the event of a reorganization, dissolution or liquidation), then the information we have collected from you will likely be part of that transfer, as well.\n\nGENERAL\n    1 Your Choices\nWhere applicable, you may amend your preferences regarding how we communicate with you or cancel your account within your profile settings in the Services. You also may use certain settings in the Fire Journal app to modify certain preferences regarding the sharing functionality of the app. You may unsubscribe from marketing-oriented emails by clicking on the “unsubscribe” link in those emails.\n\n    2 Policy to California Customers\nSubject to certain limitations under California Civil Code § 1798.83, if you are a California resident, you may ask us to provide you with (i) a list of certain categories of personal information that we have disclosed to certain third parties for their direct marketing purposes during the immediately preceding calendar year and (ii) the identity of certain third parties that received personal information from us for their direct marketing purposes during that calendar year. We do not, however, share your personal information with marketers, subject to the above statute.\n    3 Security\nAlthough we may take certain precautions that we believe may help protect against unauthorized access to the Services or related systems, no security is perfect. We make no promises regarding the security, integrity, availability or retention of the information collected or handled by our Services or related systems. For more details, please refer to the “Disclaimers” section of our Terms of Service.\n    4 Accessing or Changing Your Account Information\nIf you need to change or delete any personal information comprising your account (such as your name or email address), you may do so in your account settings in the Services, or you may contact us at support@purecommand.com. Please note that we may retain (and may be required to maintain) certain information for a period of time, for legal, accounting, or anti-fraud purposes.\n    5 Updates to Our Privacy Policy\nThis Privacy Policy may be updated periodically and without prior notice to you to reflect changes in our personal information practices or relevant laws. To inform you of any material changes, we will post the updated Privacy Policy on our Site for a period of time and indicate somewhere in the Privacy Policy when it was updated.\n    6 Users From Outside the United States\nThe Services are provided, supported, and hosted in the United States. Use of the Services is governed by United States law. If you are using the Services from outside of the United States, please be aware that any information we collect under this Policy may be transferred to, stored, and processed in the United States. The data protection and other laws of the United States are not always as comprehensive as those in other countries. By using the Services, you consent to your information being transferred to and processed by our facilities.\n    7 Users Between Thirteen and Eighteen Years of Age Outside the United States\nUsers between Thirteen and Eighteen Years of Age Outside the United States\nIf you are between thirteen and eighteen years of age, and are located outside the United States, applicable law in certain countries may require your parents or guardians to consent with your use of the Services and with the associated processing of personal data. The relevant age limit may vary from country to country. Please check the rules that apply in your country. When in doubt, please do not use the Services or provide us with any information.\n    8 No Third Party Rights\nThis Privacy Policy does not create rights enforceable by third parties.\n    9 How to Contact Us\nIf you have any questions or comments about this Privacy Policy, or if you would like us to update information we have about you or your preferences, please send a detailed message to legal@purecommand.com. Thank you.\n\nEffective Date: April 6, 2018\n\n\n\n\n\n\n\n\n\n"
        return privacy
    }
    
}
