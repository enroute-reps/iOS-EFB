//
//  HelpViewController.swift
//  EFB Client
//
//  Created by Mr.Zee on 10/16/19.
//  Copyright © 2019 MehrPardaz. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
 
    @IBOutlet weak var mTable: UITableView!
    @IBOutlet weak var mCloseButton: UIButton!
    @IBOutlet weak var mSupportView: UIView!
    @IBOutlet weak var mFeedbackButton: UIButton!
    @IBOutlet weak var mSupportButton: UIButton!
    
    private var _HelpTitle:[String] = ["Getting Started","Dashboard","My Profile","Library"]
    private var _Getting_Started_Content:Help_Content = Help_Content(title: Help_Sub_Content(title: "Enroute EFB", description: "Enroute EFB is a user-friendly application that provides fully integrated Electronic Flight Bag. Our all-in-one EFB app makes your flying safer and enjoyable by minimizing the number of tabs.\nCompatible only with iPad", image: nil), content: [Help_Sub_Content(title: "Login", description: "Subscription is exclusively backed by company administrative members. Subscribers also need to be identified in username and password (Only given by company administrators). Afterwards users will confirm the subscription via a link in their valid email address. No cancellation of the current subscription is allowed during active subscription period.", image: "Login.png"),Help_Sub_Content(title: "Email Verification", description: "Entering your email address here and verifying it will help you recover your password if you forget your password in the future. Also, important messages related to accounts are sent via email.", image: "Email.png")])
    private var _Dashboard_Content:Help_Content = Help_Content(title: Help_Sub_Content(title: "Dashboard", description: "", image: ""), content: [Help_Sub_Content(title: "Message", description: "Administrative members on the ground can stay in touch with users unilaterally by sending messages on this board.", image: "Message.png"),Help_Sub_Content(title: "Notifications and Updates", description: "Users will be notified about the latest database updates.\nIcon badges on this tab represents the total number of update notifications and received messages.", image: "Notifs.png"),Help_Sub_Content(title: "Synchronization", description: "Enroute EFB users are allowed to synchronize the app manually and automatically. Therefore data transfer will occur within the app frequently. ", image: "Sync.png"),Help_Sub_Content(title: "Logout", description: "If you log out when you do not have internet access, you will not be able to log in until internet access established. So before log out, make sure you have internet connection.", image: "Logout.png")])
    private var _My_Profile_Content = Help_Content(title: Help_Sub_Content(title: "My Profile", description: "", image: nil), content: [Help_Sub_Content(title: "Personal Information", description: "User’s personal information is accurately inserted by company administrators.", image: "Profile.png"),Help_Sub_Content(title: "EFB License Information", description: "Expiration date of EFB license appears here. Each Enroute FFB module independently purchased by the company. ", image: "Licence.png"),Help_Sub_Content(title: "Change Password", description: "Enroute recommends users to change their password after their first login.", image: "Change_Password.png")])
    private var _Library_Content = Help_Content(title: Help_Sub_Content(title: "Library", description: "Users are allowed to access to PDFs such as company manuals, aircraft manuals, safety manuals on high resolution.\nPinch the screen to zoom in and release your fingers to reset the zoom. You can also flick through the pages by scrolling.", image: nil), content: [Help_Sub_Content(title: "Downloads", description: "This feature allows users to download the documentation directly which is permitted to access by company administrators. It is important to make sure you have downloaded whole required flight manuals before every single flight.", image: "Downloads.png"),Help_Sub_Content(title: "Files", description: "Users are able to transfer the downloaded documents from “downloads” tab in order to save and use them in offline mode during the flight.", image: "Files.png")])
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self._Initialize()
    }
    
    @IBAction func _CloseButtonTapped(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func _FeedbackButtonTapped(_ sender: Any) {
        autoreleasepool{[weak self] in
            guard let weak = self else{return}
            let vc = SupportViewController.init(type: .feedback)
            weak.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func _SupportButtonTapped(_ sender: Any) {
        autoreleasepool{ [weak self] in
            guard let weak = self else{return}
            let vc = SupportViewController.init(type: .support)
            weak.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension HelpViewController{
    
    private func _Initialize(){
        self.mFeedbackButton.cornerRadius = 10
        self.mSupportButton.cornerRadius = 10
        self.mFeedbackButton.border(1, .white)
        self.mSupportButton.border(1, .white)
    }
    
}

extension HelpViewController: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _HelpTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: App_Constants.Instance.Cell(.cell)) as! HelpTableViewCell
        cell.mTitle.text = _HelpTitle[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        autoreleasepool{[weak self] in
            guard let weak = self else{return}
            switch indexPath.row{
            case 0:
                let vc = HelpContentViewController.init(content: weak._Getting_Started_Content, title: _HelpTitle[indexPath.row])
                weak.navigationController?.pushViewController(vc, animated: true)
            case 1:
                let vc = HelpContentViewController.init(content: weak._Dashboard_Content, title: _HelpTitle[indexPath.row])
                weak.navigationController?.pushViewController(vc, animated: true)
            case 2:
                let vc = HelpContentViewController.init(content: weak._My_Profile_Content, title: _HelpTitle[indexPath.row])
                weak.navigationController?.pushViewController(vc, animated: true)
            case 3:
                let vc = HelpContentViewController.init(content: weak._Library_Content, title: _HelpTitle[indexPath.row])
                weak.navigationController?.pushViewController(vc, animated: true)
            default:
                break
            }
        }
    }
    
    
}
