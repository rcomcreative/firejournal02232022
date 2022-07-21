//
//  SettingsInfoVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/29/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

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
    var userObjectID: NSManagedObjectID!
    var theUser: FireJournalUser!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext


    override func viewDidLoad() {
        super.viewDidLoad()
        vcLaunch.splitVC = self.splitViewController
        if userObjectID != nil {
            vcLaunch.userID = userObjectID
            theUser = context.object(with: userObjectID) as? FireJournalUser
        }
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
            theHeaderView.topAnchor.constraint(equalTo: theBackgroundView.topAnchor, constant: 44),
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
            self.navigationController?.navigationBar.backgroundColor = UIColor.white
            let navigationBarAppearace = UINavigationBar.appearance()
            navigationBarAppearace.tintColor = UIColor.black
        } else {
                self.navigationController?.navigationBar.backgroundColor = UIColor.white
                let navigationBarAppearace = UINavigationBar.appearance()
                navigationBarAppearace.tintColor = UIColor.black
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
                if let id = self.userObjectID {
                    self.nc.post(name:Notification.Name(rawValue: FJkSETTINGS_FROM_MASTER),
                                 object: nil,
                                 userInfo: ["sizeTrait":self.compact, "userObjID": id])
                }
            }
        }
    }
    
    func termsOfService() -> String {
        let terms: String = """
PureCommand Terms of Use

Terms of Use Published June 23, 2022. Effective as of June 23, 2022. These Terms of Use replace and supersede all prior versions.

Welcome to the PureCommand, LLC (www.purecommand.com) website. PureCommand, LLC (“PureCommand”) maintains this site (“Site”) for the purposes of sharing information about our products, related education, and client/publisher communication.

PureCommand reserves the right, at its sole discretion, to change, modify, add or remove portions of these Terms of Use, at any time without prior notification. It is your responsibility to check these Terms of Use periodically for changes. Your continued use of this and any PureCommand Site following the posting of changes will mean that you accept and agree to the changes. As long as you comply with these Terms of Use, PureCommand grants you a personal, non-exclusive, non-transferable, limited privilege to enter and use the Site.

BY USING THE SITE, YOU AGREE TO THESE TERMS OF USE; IF YOU DO NOT AGREE, DO NOT USE THE SITE.

TERMS AND CONDITIONS
Use of Site
The Site is owned and operated by PureCommand and contains material that is derived in whole or in part from material supplied and owned by PureCommand and other sources. Such material is protected by copyright, trademark, and other applicable laws. You may not modify, copy, reproduce, republish, upload, post, transmit, publicly display, prepare derivative works based on, or distribute in any way any material from the Site, including but not limited to text, audio, video, code and software. During your visit, however, you may download material displayed on the Site for non-commercial, personal use only (provided that you also retain all copyright and other proprietary notices contained on the materials). PureCommand neither warrants nor represents that your use of materials displayed on the Site will not infringe rights of third parties not owned by or affiliated with MJ Corp or PureCommand. PureCommand reserves the right to refuse to provide you access to the Site or Service or to allow you to open an Account for any reason.

BY USING THE SERVICE OR OPENING AN ACCOUNT, YOU SIGNIFY YOUR IRREVOCABLE ACCEPTANCE OF THESE TERMS OF SERVICE.

Privacy
Your privacy is very important to us. To better protect your rights we have provided the PureCommand Privacy Policy to explain our privacy practices in detail. You may access the PureCommand Privacy Policy via the PureCommand website.

Security

Some functions of our Service, such as licensing our “cloud based” software requires registration for an Account by selecting a unique username (“User ID”) and password (“PW”), and by providing certain personal information. If you select a User ID that PureCommand, in its sole discretion, finds offensive or inappropriate, PureCommand has the right to suspend or terminate your Account. You agree to (a) keep your password confidential and use only your User ID and password when logging in, (b) ensure that you log out from your account at the end of each session on the Site, and (c) immediately notify PureCommand of any unauthorized use of your User ID and/or password. You are fully responsible for all activities that occur under your User ID and Account even if such activities or uses were not committed by you. PureCommand will not be liable for any loss or damage arising from unauthorized use of your password or your failure to comply with this Section. You agree that PureCommand may for any reason, in its sole discretion and without notice or liability to you or any third party, immediately terminate your Account and your User ID, and remove or discard from the Site any Content associated with your Account and User ID. Grounds for such termination may include, but are not limited to, (i) extended periods of inactivity, (ii) violation of the letter or spirit of these Terms of Service, (iii) fraudulent, harassing or abusive behavior or (iv) behavior that is harmful to other users, third parties, or the business interests of PureCommand. Use of an Account for illegal, fraudulent or abusive purposes may be referred to law enforcement authorities without notice to you. If you file a claim against PureCommand, or a claim which in any way involves PureCommand, then PureCommand may terminate your Account. You may only use the Service and/or open an Account if your applicable jurisdiction allows you to accept these Terms of Service.

Disclaimer
THE SERVICES AND PRODUCTS PROVIDED BY PURECOMMAND ARE MADE AVAILABLE “AS IS” AND WITHOUT ANY WARRANTIES, CLAIMS OR REPRESENTATIONS MADE BY PURECOMMAND OF ANY KIND EITHER EXPRESS, IMPLIED OR STATUTORY WITH RESPECT TO THE SERVICES, INCLUDING WARRANTIES OF QUALITY, PERFORMANCE, NON-INFRINGEMENT, MERCHANTABILITY, OR FITNESS FOR A PARTICULAR PURPOSE, NOR ARE THERE ANY WARRANTIES CREATED BY COURSE OF DEALING, COURSE OF PERFORMANCE OR TRADE USAGE. WITHOUT LIMITING THE FOREGOING, PURECOMMAND DOES NOT WARRANT THAT THE SERVICE, THIS SITE OR THE FUNCTIONS CONTAINED THEREIN WILL BE AVAILABLE, ACCESSIBLE, UNINTERRUPTED, TIMELY, SECURE, ACCURATE, COMPLETE OR ERROR-FREE, THAT DEFECTS, IF ANY, WILL BE CORRECTED, OR THAT THIS SITE AND/OR THE SERVER THAT MAKES SAME AVAILABLE ARE FREE OF VIRUSES, CLOCKS, TIMERS, COUNTERS, WORMS, SOFTWARE LOCKS, DROP DEAD DEVICES, TROJAN-HORSES, ROUTINGS, TRAP DOORS, TIME BOMBS OR ANY OTHER HARMFUL CODES, INSTRUCTIONS, PROGRAMS OR COMPONENTS.

YOU ACKNOWLEDGE THAT THE ENTIRE RISK ARISING OUT OF THE USE OR PERFORMANCE OF EITHER SERVICES OR PRODUCTS REMAINS WITH YOU TO THE MAXIMUM EXTENT PERMITTED BY LAW.

Some jurisdictions do not allow the disclaimer of implied warranties, so the foregoing disclaimer may not apply to you.

Limitation of Liability
Your use of, and browsing in, the site is at your own risk. You assume full responsibility for implementing sufficient procedures and checks to satisfy your requirements for the accuracy and suitability of the site, including the information, and for maintaining any means that you may require for the reconstruction of lost data or subsequent manipulations or analyses of the information provided hereunder. You acknowledge that your use of the site and any information sent or received in connection therewith, may not be secure and may be intercepted by unauthorized parties. You assume responsibility for the entire cost of all necessary maintenance, repair or correction to your computer system or other property. In no event shall PureCommand, subsidiary companies or its affiliates or suppliers be liable for any direct, indirect, punitive, incidental, special, consequential or other damages arising out of or in any way connected with the use of the site or with the delay or inability to use the site, or for any information, software, products and services advertised in or obtained through the site, PureCommand’s removal or deletion of any materials or records submitted or posted on its site, or otherwise arising out of the use of the site, whether based on contract, tort, strict liability or otherwise, even if PureCommand or any of its affiliates or suppliers has been advised of the possibility of damages. This waiver applies, without limitation, to any damages or injury arising from any failure of performance, error, omission, interruption, deletion, defect, delay in operation or transmission, computer virus, file corruption, communication-line failure, network or system outage, or theft, destruction, unauthorized access to, alteration of, or use of any record. You specifically acknowledge and agree that PureCommand, its parent or subsidiary companies, affiliates or suppliers shall not be liable for any defamatory, offensive or illegal conduct of any user of the site.

Links to Third Party Sites
The links provided throughout the Site will let you leave this Site. These links are provided as a courtesy only, and the sites they link to are not under the control of PureCommand in any manner whatsoever. Therefore, PureCommand is in no manner responsible for the contents of any such linked site or any link contained within a linked site, including any changes or updates to such sites. PureCommand is providing these links merely as a convenience, and the inclusion of any link does not in any way imply or express affiliation, endorsement or sponsorship by PureCommand of any linked site and/or any of its content therein.

Use of Site
PureCommand is providing you with a temporary “right of use” license relative to the content, activities, applications, and content contained within the site. This license will terminate as set forth herein or if you fail to comply with any term or condition described herein. In such event, no notice shall be required by PureCommand to effect such termination.You agree not to:
upload, post, email, text, tweet, transmit or otherwise make available any Content that is unlawful, harmful, threatening, abusive, harassing, tortuous, defamatory, vulgar, obscene, libelous, invasive of another’s privacy, hateful, or racially, ethnically or otherwise objectionable;
use the Site to harm minors in any way;
use the Site to impersonate any person or entity, or otherwise misrepresent your affiliation with a person or entity;
forge headers or otherwise manipulate identifiers in order to disguise the origin of any Content transmitted through the Site;
remove any proprietary notices from this Site;
cause, permit or authorize the modification, creation of derivative works, or translation of the Site without the express permission of PureCommand, or the original owner of any content in question;
use the Site for any commercial purpose or the benefit of any third party or any manner not permitted by the licenses granted herein;
use the Site for fraudulent or illegal purposes;
attempt to decompile, reverse engineer, disassemble or hack the Site, or to defeat or overcome any encryption technology or security measures implemented by PureCommand with respect to the Site and/or data transmitted, processed or stored by PureCommand;
harvest or collect any information about or regarding other Account holders, including, but not limited to any personal data or information;
upload, post, email, transmit or otherwise make available any Content that you do not have a right to make available under any law or under contractual or fiduciary relationships (such as inside information, proprietary and confidential information learned or disclosed as part of employment relationships or under nondisclosure agreements);
upload, post, email, transmit or otherwise make available any Content that infringes any patent, trademark, trade secret, copyright or other proprietary rights of any party;
upload, post, email, transmit or otherwise make available any unsolicited or unauthorized advertising, promotional materials, “junk mail,” “spam,” “spoof,” “chain letters,” “pyramid schemes,” or any other form of solicitation;
upload, post, email, transmit or otherwise make available any material that contains software viruses or any other computer code, files or programs designed to interrupt, destroy or limit the functionality of any computer software or hardware or telecommunications equipment;
disrupt the normal flow of dialogue, cause a screen to “scroll” faster than other users of the Site are able to type, or otherwise act in a manner that negatively affects other users’ ability to engage in real time exchanges;
interfere with or disrupt the Site or servers or networks connected to the Site, or disobey any requirements, procedures, policies or regulations of networks connected to the Site;
use the Site to intentionally or unintentionally violate any applicable local, state, national or international law or any regulations having the force of law;
use the Site to provide material support or resources (or to conceal or disguise the nature, location, source, or ownership of material support or resources) to any organization(s) designated by the United States government as a foreign terrorist organization pursuant to section 219 of the Immigration and Nationality Act;
use the Site to “stalk” or otherwise harass another;
and/or use the Site to collect or store personal data about other users in connection with the prohibited conduct and activities set forth herein.
You understand that all Content, whether publicly posted or privately transmitted, are the sole responsibility of the person from whom such Content originated. This means that you, and not PureCommand, are entirely responsible for all Content that you upload, post, email, transmit or otherwise make available through the Site. PureCommand does not control the Content posted on the Site and, as such, does not guarantee the accuracy, integrity or quality of such Content. You understand that by using the Site, you may be exposed to Content that you may consider to be offensive, indecent or objectionable. Under no circumstances will PureCommand be liable in any way for any Content, including, but not limited to, any errors or omissions in any Content, or any loss or damage of any kind incurred as a result of the use of any Content posted, emailed, transmitted or otherwise made available on the Site.

You acknowledge that PureCommand may or may not pre-screen Content, but that PureCommand and its designees shall have the right (but not the obligation) in their sole discretion to pre-screen, refuse, or move any Content that is available on the Site. Without limiting the foregoing, PureCommand and its designees shall have the right to remove any Content that violates this Terms of Service or is otherwise objectionable. You agree that you must evaluate, and bear all risks associated with, the use of any Content, including any reliance on the accuracy, completeness, or usefulness of such Content. In this regard, you acknowledge that you may not rely on any Content created by PureCommand or submitted to PureCommand, including without limitation information in PureCommand Forums and in all other parts of the Site.

You acknowledge, consent and agree that PureCommand may access, preserve and disclose your Account information and Content if required to do so by law or in a good faith belief that such access preservation or disclosure is reasonably necessary to: (a) comply with legal process; (b) enforce this Terms of Service; (c) respond to claims that any Content violates the rights of third parties; (d) respond to your requests for customer service; or (e) protect the rights, property or personal safety of PureCommand, its users and the public.

Merchants
Your correspondence or business dealings with, or participation in promotions of, merchants found on or through the Site, including payment and delivery of related goods or services, and any other terms, conditions, warranties, or representations associated with such dealings, are solely between you and such merchant. PureCommand will NOT be responsible or liable for any loss and/ or damage of any sort incurred as the result of any such dealings or as the result of the presence of such merchants on the Site.

FAQs / Message Boards / Bulletin Boards
The Site may provide you and other users an opportunity to submit, post, display, transmit and/or exchange information, ideas, opinions, photographs, images, video, creative works or other information, messages, transmissions or material to us, the Site or others (“Post” or “Postings”). Postings do not reflect the views of PureCommand; and PureCommand does not have any obligation to monitor, edit, or review any Postings on the Site. PureCommand assumes NO responsibility or liability arising from the content of any such Postings nor for any error, defamation, libel, slander, omission, falsehood, obscenity, pornography, profanity, danger, or inaccuracy contained in any information within such Postings on the Site. You are strictly prohibited from posting or transmitting any unlawful, threatening, libelous, defamatory, obscene, scandalous, inflammatory, pornographic, or profane material that could constitute or encourage conduct that would be considered a criminal offense, give rise to civil liability, or otherwise violate any law. PureCommand will fully cooperate with any law enforcement agencies or a court order requesting or directing PureCommand to disclose the identity of anyone posting any such information or materials.

Your Contributions to the Services or Products
By submitting Content for inclusion in offered Services, or within the Products provided, you represent and warrant that you have all necessary permissions to grant the licenses below to PureCommand. You further acknowledge and agree that you are solely responsible for anything you post or otherwise make available on or through both Services and/or Products, including, without limitation, the accuracy, reliability, nature, rights clearance, compliance with law and legal restrictions associated with any Content contribution. You hereby grant PureCommand and its successors a worldwide, non-exclusive, royalty-free, sublicensable and transferable license to use, copy, distribute, transmit, modify, prepare derivative works of, publicly display, and publicly perform such Content contribution on, through or in connection with the Service in any media formats and through any media channels, including without limitation, for promoting and redistributing part of the Service (and its derivative works). This license granted by you terminates once you or PureCommand removes your contributed Content from the Service. You understand that your contribution may be transmitted over various networks and changed to conform and adapt to technical requirements.

Any material, information or idea you post on or through the Service, or otherwise transmit to PureCommand by any means (each, a “Submission”), is not considered confidential by PureCommand and may be disseminated or used by PureCommand or its affiliates without compensation or liability to you for any purpose whatsoever, including, but not limited to, developing, manufacturing and marketing products. By making a Submission to PureCommand, you acknowledge and agree that PureCommand and/or other third parties may independently develop software, applications, interfaces, products and modifications and enhancements of the same which are identical or similar in function, code or other characteristics to the ideas set out in your Submission. Accordingly, you hereby grant PureCommand and its successors a worldwide, non-exclusive, royalty-free, sublicensable and transferable license to develop the items identified above, and to use, copy, distribute, transmit, modify, prepare derivative works of, publicly display, and publicly perform any Submission on, through or in connection with the Service in any media formats and through any media channels, including without limitation, for promoting and redistributing part of the Service (and its derivative works). This license granted by you will continue for as long as PureCommand determines to use your Submission. This provision does not apply to personal information that is subject to our privacy policy except to the extent that you make such personal information publicly available on or through the Service.

Third Party Contributions to Services and/or Products

Each contributor to our Services and/or Product(s) of data, text, images, sounds, video, software and other Content is solely responsible for the accuracy, reliability, nature, rights clearance, compliance with law and legal restrictions associated with their Content contribution. As such, PureCommand is not responsible to, and shall not, regularly monitor or check for the accuracy, reliability, nature, rights clearance, compliance with law and legal restrictions associated with any contribution of Content. You will not hold PureCommand responsible for any user’s actions or inactions, including things they post or otherwise make available via the Service.

In addition, the Services and/or Products may contain links to third party text and video feeds (and podcasts) (collectively, “third party feeds”), websites and offers, links to download third party software applications. Additionally, third parties may make available, on their own websites, third party feeds, and software applications. These third party links, third party feeds, websites and software applications are not owned or controlled by PureCommand. Rather, they are operated by, and are the property of, the respective third parties, and may be protected by applicable copyright or other intellectual property laws and treaties. PureCommand has not reviewed, and assumes no responsibility for the content, functionality, security, services, privacy policies, or other practices of these third-parties. You are encouraged to read the terms and other policies published by such third parties on their websites or otherwise. By using the Service, you agree that PureCommand shall not be liable in any manner due to your use of, or inability to use, any third-party feed, website or widget. You further acknowledge and agree that PureCommand may disable your use of, or remove, any third party links, third party feeds, or applications on the Service to the extent they violate these Terms of Service.

Violation of Our Terms of Service
If you believe that your work (as included via either Services or Products) has been copied, displayed, or distributed in a way that constitutes copyright infringement, please notify our Copyright Agent (CT Corporation).

A notification of claimed infringement must be a written communication as set forth below, and must include substantially all of the following: (a) a physical or electronic signature of a person authorized to act on behalf of the owner of the copyright interest that is allegedly infringed; (b) a description of such copyrighted work(s) and an identification of what material in such work(s) is claimed to be infringed; (c) a description of the exact name of the infringing work and the location of the infringing work via the Services; (d) information sufficient to permit PureCommand to contact you, such as your physical address, telephone number and email address; (e) a statement by you that you have a good faith belief that the use of the material identified in the manner complained of is not authorized by the copyright owner, its agent, or the law; (f) a statement by you that the information in the notification is accurate and, under penalty of perjury that you are authorized to act on the copyright owner’s behalf.

Your Representations and Warranties
You represent and warrant that:
you possess the legal right and ability to enter into this Terms of Service and to comply with its terms;
you will use the Site for lawful purposes only and in accordance with this Terms of Service and all applicable laws, regulations and policies; and
you will only use the Site on a computer on which such use is authorized by the computer’s owner.
Indemnification
You agree to indemnify, defend and hold PureCommand, its affiliates, and their respective officers, directors, owners, employees, agents, information providers and licensors (collectively the “Indemnified Parties”) harmless from and against any and all claims, liability, losses, actions, suits, costs and expenses (including attorneys’ fees) arising out of or incurred by any breach by you of these Terms and Conditions. PureCommand reserves the right, at its own expense, to assume the exclusive defense and control of any matter otherwise subject to indemnification by you, and in such case, you agree to cooperate with PureCommand’s defense of such claim.

Severability
If any provision of this Terms of Service shall be deemed unlawful, void, or for any reason unenforceable, then that provision shall be deemed severable from these terms and conditions and shall not affect the validity and enforceability of any remaining provisions.

Infringement Policy
PureCommand, pursuant to 17 U.S.C. Section 512 as amended by Title II of the Digital Millennium Copyright Act (the “Act”), reserves the right, but not the obligation, to terminate your license to use the Site if it determines in its sole and absolute discretion that you are involved in infringing activity, including allege acts of first-time or repeat infringement, regardless of whether the material or activity is ultimately determined to be infringing. PureCommand accommodates and does not interfere with standard technical measures used by copyright owners to protect their materials. In addition, pursuant to 17 U.S.C. Section 512 (c), PureCommand has implemented procedures for receiving written notification of claimed infringements and for processing such claims in accordance with the Act. All claims of infringement must be submitted to PureCommand in a written complaint that complies with the requirements below and delivered to our designated agent to receive notification of claimed infringement by mail:

PureCommand, LLC
3960 Howard Hughes Pkway
Suite 500
Las Vegas, NV 89169
702.659.9910

In addition, any written notice regarding any defamatory or infringing activity, whether of a copyright, patent, trademark or other proprietary right must include the following information:

1. A physical or electronic signature of a person authorized to act on behalf of (1) the owner of an exclusive right that is allegedly infringed or (2) the person defamed.
2. Identification
"""
        
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
    
    func privacyText() -> String {
        let privacy = """
PureCommand Privacy Policy

Privacy Policy Published June 23, 2022. Effective as of June 23, 2022. This Privacy Policy replaces and supersedes all prior versions.

PureCommand, LLC. (“PureCommand,” or “we”) wants you to feel secure relative to how we work with you, as you use either our web-based or iOS-based software. We want you to be familiar with the type of information we collect from you, and how we use it.

Read through this document, which we’re calling our “Privacy Policy,” and gain a better understanding about the information we collect relative to your use of our apps and services.

The PureCommand Privacy Policy describes the privacy practices of PureCommand’s apps and websites. If you are a resident of North America, your relationship is with PureCommand, LLC and the laws of California and the United States apply.
 
The “Services” include our “Fire Journal Cloud” web application (a component of membership), the “Fire Journal” iOS and iPadOS application(s), any other mobile support apps, our website (www.purecommand.com), our customer service portal, and any related services or digital tools connected with the above. Fire Journal is our primary mobile (iOS) application, or “app.” Our services include our web-based Cloud app, our CRM support portal, any videos we present via social media or YouTube™, as well as live training presentations.

By using the Services, you agree that you are accepting the practices that we have outlined in this Policy, and that you consent to having your data transferred to and processed in the United States, where our facilities are located. This Privacy Policy describes the information we collect through the Services, how we may use that information, and with whom we may share it. This Privacy Policy is organized according to the sections below:

Information We Obtain
How We Use the Information We Obtain
Sharing of Information
General

INFORMATION WE GATHER
There are three ways in which we may obtain personally identifying information from you: you may submit it; we collect it automatically through our online Services; or we collect it automatically via our Mobile Apps. Different types of information may be collected through each channel, and you should understand both how we do this and what types of information we collect on each channel.

Information You Submit You may choose to provide us with personal information through the Services, such as through forms, account portals, interfaces, and interactions with other customer support portals and channels:
Contact information, such as your name and email address.
Other information about yourself, such as your age, gender, location, date of birth, language preference or interests.
Your photograph.
Information related or connected to an account with a third-party service that you use to sign up or log in to the Services, or when you associate that account with the Services. For instance, when you associate your Facebook or Instagram account with our Services, we may receive your public profile (name, profile picture, age range, gender, language, country and other public information), your friend list, your contacts, and your email address. If you sign up, log in with, or connect the Services with accounts you may have with other third-party services, such as Twitter, Instagram, or Tumblr, we may obtain similar information from those platforms.

You may also submit original content to us, which is covered under licenses set forth in our Terms of Service, describing other rights that you grant to us and other users.

Information We Collect by Automated Means Through the Services
We also may collect certain information from you by automated means, using technologies such as cookies, Web server logs, Web beacons and JavaScript.

Cookies are files that websites send to your computer or other Internet-connected device to uniquely identify your browser or to store information or settings on your device. Our site may use HTTP cookies, HTML5 cookies and other types of local storage (such as browser-based or plugin-based local storage). Your browser may tell you how to be notified when you receive certain types of cookies and how to restrict or disable certain cookies. Please note, however, that without cookies you may not be able to use all of the features of the Services or other websites and online services.

In conjunction with the gathering of information through cookies, our Web servers may log information such as your device type, operating system type, browser type, domain, and other system settings, as well as the language your system uses and the country and time zone where your device is located. The Web server logs also may record information such as the address of the Web page that referred you to our Site and the IP address of the device you use to connect to the Services. They also may log information about your interaction with this Site, such as which pages you visit. To control which Web servers collect information by automated means, we may place tags on our Web pages called “Web beacons,” which are small files that link Web pages to particular Web servers and their cookies. We also may send instructions to your device using JavaScript or other computer languages to gather the sorts of information described above and other details your interactions with the Site.

We may use third-party Web analytics services in connection with providing the Services, including but not limited to Google Analytics, Mixpanel, Flurry, and Intercom. These service providers use the technology described above to help us analyze how our users use the Site. The information collected by the technology (including your IP address) will be disclosed to or collected directly by these services providers, who use the information to evaluate your use of the Site.

To learn about opting out of Google Analytics, https://tools.google.com/dlpage/gaoptout

To learn about opting out of Mixpanel, https://mixpanel.com/privacy/

To learn about opting out of Flurry, https://developer.yahoo.com/flurry/end-user-opt-out/

To learn about opting out of Intercom, https://docs.intercom.com/pricing-privacy-and-terms/updating-your-privacy-policy

On certain occasions, you may encounter a technical problem that could require troubleshooting by our customer support staff. If this should become necessary, you may be asked to share with us information about your use of Fire Journal that is more detailed than the information we collect by automated means. For example we may ask you to provide specific documents and files associated with the Services or with the Fire Journal app. Some of these files may contain personally identifying information. If you provide such additional information, it will only be used in connection with our efforts to diagnose and solve your technical problem, and to improve the Services and Fire Journal, and will be treated in accordance with this Privacy Policy.

HOW WE USE THE INFORMATION WE OBTAIN
We may use the information we obtain through the Services to provide the Services and fulfill the immediate purpose for which it was requested, as well as for other purposes. These purposes may include:

Providing, administering and communicating with you about products, services, events and promotions (including by sending you newsletters and other marketing communications).

Performing diagnostics and analysis to evaluate how our Services operate, and how people are using them.

Processing, evaluating and responding to your requests, inquiries and applications.
Managing our customer information databases.

Administering contests, sweepstakes, and surveys.

Customizing your experience with the Services.

Operating, evaluating, and improving our business (including developing new products and services; managing our communications; performing market research, data analytics, and data appends; determining and managing the effectiveness of our advertising and marketing; analyzing our products and Services; and performing accounting, auditing, billing, reconciliation, and collection activities).

Protecting against and preventing fraud, unauthorized transactions, security issues, claims and other liabilities, and managing risk exposure and quality.

Complying with and enforcing applicable legal requirements, industry standards and our policies and terms, such as our Terms of Service.

Providing customer support and diagnostic assistance, for instance, by reviewing information collected from the Services and from the Pencil stylus or other hardware and tools you use.

Sometimes, we may combine certain parts of this information. For instance, when we provide you with customer support or other assistance, we may combine your account information and other personal information you’ve provided to us with information about your usage of the Services or Fire Journal.

SHARING OF INFORMATION
We may share or allow you to share personal information as part of the Services. For example your user name and other account details may be associated with content and comments you post on or through the Services. We may allow you to post information to your social network account if your settings allow for such sharing. When you do this, Information you submit to a third-party widget or plugin on our Services is collected directly by the provider of that widget or plugin and is not subject to our Privacy Policy.

We also may disclose information about you: (i) if we are required to do so by law, regulation or legal process, such as a court order or subpoena; (ii) in response to requests by government agencies, such as law enforcement authorities; or (iii) when we believe disclosure is necessary or appropriate to prevent physical, financial or other harm, injury or loss; or (iv) in connection with an investigation of suspected or actual unlawful activity. We also may disclose aggregated or non-identifiable information to third parties in a manner that does not identify particular users.

If we sell or transfer all or a portion of our business or assets (including in the event of a reorganization, dissolution or liquidation), then the information we have collected from you will likely be part of that transfer, as well.

GENERAL
Your Choices
Where applicable, you may amend your preferences regarding how we communicate with you or cancel your account within your profile settings in the Services. You also may use certain settings in the FireJournal app to modify certain preferences regarding the sharing functionality of the app. You may unsubscribe from marketing-oriented emails by clicking on the “unsubscribe” link in those emails.

Policy to California Customers
Subject to certain limitations under California Civil Code § 1798.83, if you are a California resident, you may ask us to provide you with (i) a list of certain categories of personal information that we have disclosed to certain third parties for their direct marketing purposes during the immediately preceding calendar year and (ii) the identity of certain third parties that received personal information from us for their direct marketing purposes during that calendar year. We do not, however, share your personal information with marketers, subject to the above statute.

Security
Although we may take certain precautions that we believe may help protect against unauthorized access to the Services or related systems, no security is perfect. We make no promises regarding the security, integrity, availability or retention of the information collected or handled by our Services or related systems. For more details, please refer to the “Disclaimers” section of our Terms of Service.

Accessing or Changing Your Account Information
If you need to change or delete any personal information comprising your account (such as your name or email address), you may do so in your account settings in the Services, or you may contact us at support@purecommand.com. Please note that we may retain (and may be required to maintain) certain information for a period of time, for legal, accounting, or anti-fraud purposes.

Updates to Our Privacy Policy
This Privacy Policy may be updated periodically and without prior notice to you to reflect changes in our personal information practices or relevant laws. To inform you of any material changes, we will post the updated Privacy Policy on our Site for a period of time and indicate somewhere in the Privacy Policy when it was updated.

Users From Outside the United States
The Services are provided, supported, and hosted in the United States. Use of the Services is governed by United States law. If you are using the Services from outside of the United States, please be aware that any information we collect under this Policy may be transferred to, stored, and processed in the United States. The data protection and other laws of the United States are not always as comprehensive as those in other countries. By using the Services, you consent to your information being transferred to and processed by our facilities.

Users Between Thirteen and Eighteen Years of Age Outside the United States
If you are between thirteen and eighteen years of age, and are located outside the United States, applicable law in certain countries may require your parents or guardians to consent with your use of the Services and with the associated processing of personal data. The relevant age limit may vary from country to country. Please check the rules that apply in your country. When in doubt, please do not use the Services or provide us with any information.

No Third Party Rights
This Privacy Policy does not create rights enforceable by third parties.

How to Contact Us
If you have any questions or comments about this Privacy Policy, or if you would like us to update information we have about you or your preferences, please send a detailed message to info@purecommand.com.

You may also reach us via U.S. Mail:

PureCommand, LLC
3960 Howard Hughes Pkway
Suite 550
Las Vegas, NV 89169
"""
        
        return privacy
    }
    
}
