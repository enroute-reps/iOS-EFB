//
//  DashboardViewController.swift
//  EFB Client
//
//  Created by Mr.Zee on 10/14/19.
//  Copyright © 2019 MehrPardaz. All rights reserved.
//

import UIKit
import SDWebImage
import Combine
import Alamofire

class DashboardViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var mNavigationView: UIView!
    @IBOutlet weak var mUserImageView: UIView!
    @IBOutlet weak var mAirlineImageView: UIView!
    @IBOutlet weak var mUsernameLabel: UILabel!
    @IBOutlet weak var mAirlineLabel: UILabel!
    @IBOutlet weak var mUserRoleLabel: UILabel!
    @IBOutlet weak var mProfileView: UIView!
    @IBOutlet weak var mMessagesView: UIView!
    @IBOutlet weak var mNotificationsView: UIView!
    @IBOutlet weak var mMessagesMainView: UIView!
    @IBOutlet weak var mNotificationsMainView: UIView!
    @IBOutlet weak var mInfoButton: UIButton!
    @IBOutlet weak var mSyncButton: UIButton!
    @IBOutlet weak var mLogoutButton: UIButton!
    @IBOutlet weak var mUserImage: UIImageView!
    @IBOutlet weak var mAirlineImage: UIImageView!
    @IBOutlet weak var mProfileButton: UIButton!
    @IBOutlet weak var mMessageBackButton: UIButton!
    @IBOutlet weak var mNotificationsBackButton: UIButton!
    @IBOutlet weak var mExpireAlertLabel: UILabel!
    @IBOutlet weak var mEmailVerificationView: UIView!
    
    private var _Message:UINavigationController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "messages") as! UINavigationController
    private var _Notification:UINavigationController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "messages") as! UINavigationController
    private var _User:EFBUser?
    private var _Org:Organization?
    private let kMain = "Main"
    private let kSplash = "login"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self._Initialize()
        //fcm token
        Sync.syncFCMToken()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self._Notifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self._RemoveNotificationObservers()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.mUserImageView.round = true
        self.mUserImage.round = true
        self.mAirlineImageView.round = true
        self.mAirlineImage.round = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.mUserImageView.round = true
        self.mUserImage.round = true
        self.mAirlineImageView.round = true
        self.mAirlineImage.round = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ProfileViewController{
            if #available(iOS 13.0, *){
                dest.modalPresentationStyle = .automatic
            }else{
                dest.modalPresentationStyle = .overFullScreen
            }
        }
        
        if let dest = segue.destination as? HelpViewController{
            if #available(iOS 13.0, *){
                dest.modalPresentationStyle = .automatic
            }else{
                dest.modalPresentationStyle = .overFullScreen
            }
        }
    }
    
    @IBAction func _InfoButtonTapped(_ sender: Any) {
        App_Constants.UI.performSegue(self, .help)
    }
    
    @IBAction func _SyncButtonTapped(_ sender: Any) {
        App_Constants.UI._Rotate(self.mSyncButton)
        self.mSyncButton.isUserInteractionEnabled = false
        Sync.syncUser({ r,m  in
            if r{
                self._Initialize()
            }else{
                App_Constants.UI.Make_Alert("", m ?? "")
            }
            App_Constants.UI._StopRotate(self.mSyncButton)
            self.mSyncButton.isUserInteractionEnabled = true
        })
    }
    
    @IBAction func _LogoutButtonTapped(_ sender: Any) {
        autoreleasepool{[weak self] in
            guard let weak = self else{return}
            let alert1 = PopupViewController.init(title: App_Constants.Instance.Text(.logout), message: App_Constants.Instance.Text(.logout_message), leftButtonTitle: App_Constants.Instance.Text(.no), rightButtonTitle: App_Constants.Instance.Text(.yes), leftButtonFunc: { button,button2,controller in
                controller?.dismiss(animated: true, completion: nil)
            }, rightButtonFunc: {button,button2,controller in
                button.startAnimation()
                button2.isHidden = true
                weak._Logout({s in
                    UIView.animate(withDuration: 0.3, animations: {
                        button2.isHidden = false
                    })
                    if s{
                        button.stopAnimation(animationStyle: .normal, revertAfterDelay: 0, completion: {
                            controller?.dismiss(animated: true, completion: nil)
                            App_Constants.Instance.RemoveAllRecords()
                            autoreleasepool{
                                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
                                let storyboard = UIStoryboard.init(name: weak.kMain, bundle: nil)
                                let vc = storyboard.instantiateViewController(withIdentifier: weak.kSplash) as! UINavigationController
                                appDelegate.window?.rootViewController = vc
                                appDelegate.window?.makeKeyAndVisible()
                                
                            }
                        })
                    }else{
                        button.stopAnimation(animationStyle: .shake, revertAfterDelay: 0, completion: nil)
                        App_Constants.UI.Make_Alert("", App_Constants.Instance.Text(.logout_failed))
                    }
                })
            })
            alert1.modalPresentationStyle = .overCurrentContext
            weak.present(alert1, animated: true, completion: nil)
        }
    }
    
    @IBAction func _ProfileButtonTapped(_ sender: Any) {
        App_Constants.UI.performSegue(self, .profile)
    }
    
    @IBAction func _MessagesBackButtonTapped(_ sender: Any) {
        self.mMessageBackButton.isHidden = true
        self._Message.popViewController(animated: true)
    }
    
    @IBAction func _NotificationsBackButtonTapped(_ sender: Any) {
        self.mNotificationsBackButton.isHidden = true
        self._Notification.popViewController(animated: true)
    }
    
    deinit{
        _RemoveNotificationObservers()
    }
    
}

extension DashboardViewController{
    
    private func _Initialize(){
        //UI
        self.mMessagesView.cornerRadius = 5
        self.mNotificationsView.cornerRadius = 5
        self.mMessagesMainView.cornerRadius = 5
        self.mNotificationsMainView.cornerRadius = 5
        self.mEmailVerificationView.cornerRadius = 5
        self.mEmailVerificationView.border(1, .red)
        self.mUserImageView.border()
        self.mUserImageView.round = true
        self.mUserImage.round = true
        self.mAirlineImageView.border()
        self.mAirlineImageView.round = true
        self.mAirlineImage.round = true
        self.mProfileView.cornerRadius = 10
        self.mProfileView.border(1,App_Constants.Instance.Color(.light))
        self._User = App_Constants.Instance.LoadUser()
        self._Org = App_Constants.Instance.LoadFromCore(.organization)
        self.mUserImage.sd_setImage(with: URL(string: "\(Api_Names.Main)\(Api_Names.image)\(self._User?.profile_image ?? "")"), completed: nil)
        self.mAirlineImage.sd_setImage(with: URL(string: "\(Api_Names.Main)\(Api_Names.org_image)\(self._Org?.organization_logo ?? "")"), completed: nil)
        self.mUsernameLabel.text = "\(self._User?.first_name ?? "") \(self._User?.last_name ?? "")"
        self.mAirlineLabel.text = "\(self._Org?.organization_name ?? App_Constants.Instance.Text(.unknown))"
        self.mUserRoleLabel.text = "\(self._User?.job_title ?? App_Constants.Instance.Text(.unknown))"
        (self._Message.viewControllers.first as! MessagesViewController)._Type = .message
        (self._Notification.viewControllers.first as! MessagesViewController)._Type = .notification
        App_Constants.UI.AddChildView(mother: self, self.mMessagesMainView, _Message)
        App_Constants.UI.AddChildView(mother: self, self.mNotificationsMainView, _Notification)
        // Expire Alert
        autoreleasepool{
            let Days30ToInterval:TimeInterval = 2592000
            let interval = (self._User?.licence?.defaultToDate() ?? Date()).timeIntervalSinceNow
            self.mExpireAlertLabel.isHidden = ((interval - Days30ToInterval) / (24*60*60) >= 1)
            self.mExpireAlertLabel.text = String(format: App_Constants.Instance.Text(.expire_library_message), Int(interval / (24*60*60) + 1))
        }
        //check email verification
        self.mEmailVerificationView.isHidden = !(self._User?.user_status == Constants.kEmailNotVerified)
        //Legal Check
        _CheckLegal()
    }
    
    private func _Notifications(){
        self._RemoveNotificationObservers()
        NotificationCenter.default.addObserver(forName: App_Constants.Instance.Notification_Name(.msg_seen), object: nil, queue: nil, using: {nf in
            self.mMessageBackButton.isHidden = false
        })
        NotificationCenter.default.addObserver(forName: App_Constants.Instance.Notification_Name(.notif_seen), object: nil, queue: nil, using: {nf in
            self.mNotificationsBackButton.isHidden = false
        })
        NotificationCenter.default.addObserver(forName: App_Constants.Instance.Notification_Name(.syncing), object: nil, queue: nil, using: {notification in
            DispatchQueue.main.async{
                App_Constants.UI._Rotate(self.mSyncButton)
                UIDevice.current.vibrate()
                self.mSyncButton.isUserInteractionEnabled = false
            }
        })
        NotificationCenter.default.addObserver(forName: App_Constants.Instance.Notification_Name(.sync_finished), object: nil, queue: nil, using: {notification in
            DispatchQueue.main.async{
                App_Constants.UI._StopRotate(self.mSyncButton)
                App_Constants.UI.Make_Toast(with: App_Constants.Instance.Text(.sync_completed))
                self.mSyncButton.isUserInteractionEnabled = true
                self._Initialize()
            }
        })
    }
    
    private func _RemoveNotificationObservers(){
        NotificationCenter.default.removeObserver(self, name: App_Constants.Instance.Notification_Name(.msg_seen), object: nil)
        NotificationCenter.default.removeObserver(self, name: App_Constants.Instance.Notification_Name(.notif_seen), object: nil)
        NotificationCenter.default.removeObserver(self, name: App_Constants.Instance.Notification_Name(.syncing), object: nil)
        NotificationCenter.default.removeObserver(self, name: App_Constants.Instance.Notification_Name(.sync_finished), object: nil)
    }
    
    private func _Logout(_ callback: @escaping (Bool)->Void){
        autoreleasepool{
            Sync.Logout({s in
                if s{
                    Sync.Log_Event(event: .logout, type: .logout, id: "\(self._User?.user_id ?? 0)", {s,m in callback(s)})
                }else{
                    callback(false)
                    App_Constants.UI.Make_Alert("", App_Constants.Instance.Text(.logout_failed))
                }
            })
            
        }
    }
    
    private func _PresentTerms(file:String, date: String){
        if !(self.presentedViewController?.isKind(of: TermsViewController.self) ?? false){
            let terms = TermsViewController.init(file: file, date: date)
            terms.modalPresentationStyle = .formSheet
            terms.modalTransitionStyle = .coverVertical
            self.present(terms, animated: true, completion: nil)
        }
    }
    
    private func _CheckLegal(){
        self.view.superview?.superview?.isUserInteractionEnabled = false
        Sync.LastLegalNotes({s,m,r in
            if s{
                self.view.superview?.superview?.isUserInteractionEnabled = true
                guard let lastUpdate = App_Constants.Instance.SettingsLoad(.legal_time) as? String else{
                    self._PresentTerms(file: r?.licenceAgreement ?? "", date: r?.lastUpdate ?? "")
                    return
                }
                if lastUpdate != (r?.lastUpdate){
                    self._PresentTerms(file: r?.licenceAgreement ?? "", date: r?.lastUpdate ?? "")
                }
            }else{
                if let _ = App_Constants.Instance.SettingsLoad(.legal_time) as? String{
                    self.view.superview?.superview?.isUserInteractionEnabled = true
                }else{
                    App_Constants.UI.Make_Alert("Terms & Conditions", "You must agree to Enroute EFB's Terms and Conditions in order to activate this application.\n \(App_Constants.Instance.Text(.no_connection))", {self._CheckLegal()})
                }
            }
        })
    }
    
}
