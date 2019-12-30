

import UIKit
import SDWebImage
import Combine
import Alamofire
import RxSwift
import RxCocoa

let kMain = "Main"
let kSplash = "login"

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
    
    private var _User:EFBUser?
    private var _Message:UINavigationController?
    private var _Notification:UINavigationController?
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self._Initialize()
        //fcm token
        Sync.shared.syncFCMToken()
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
        Sync.shared.syncUser()

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
                            controller?.dismiss(animated: true, completion: {
                                App_Constants.Instance.RemoveAllRecords()
                                App_Constants.UI.changeRootController("login")
                            })
                        })
                    }else{
                        button.stopAnimation(animationStyle: .shake, revertAfterDelay: 0, completion: nil)
                        if NetworkReachabilityManager()?.isReachable ?? false{
                            App_Constants.UI.Make_Alert("", App_Constants.Instance.Text(.logout_failed))
                        }else{
                            App_Constants.UI.Make_Alert("", App_Constants.Instance.Text(.no_connection))
                        }
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
        (self._Message?.viewControllers.first as! MessagesViewController)._DidShowMessage.accept(false)
        self._Message?.popViewController(animated: true)
    }
    
    @IBAction func _NotificationsBackButtonTapped(_ sender: Any) {
        (self._Notification?.viewControllers.first as! MessagesViewController)._DidShowNotif.accept(false)
        self._Notification?.popViewController(animated: true)
    }
    
}

extension DashboardViewController{
    
    private func _Initialize(){
        //UI
        Sync.shared.user.asObservable().subscribe(onNext: { [weak self] user in
            guard let weak = self else{return}
            weak._User = user
            weak.mUserImage.sd_setImage(with: URL(string: "\(Api_Names.Main)\(Api_Names.image)\(user?.profile_image ?? "")"), completed: nil)
            weak.mUsernameLabel.text = "\(user?.first_name ?? "") \(user?.last_name ?? "")"
            weak.mUserRoleLabel.text = "\(user?.job_title ?? App_Constants.Instance.Text(.unknown))"
            // Expire Alert
            autoreleasepool{
                let Days30ToInterval:TimeInterval = 2592000
                let interval = (user?.licence?.defaultToDate() ?? Date()).timeIntervalSinceNow
                weak.mExpireAlertLabel.isHidden = ((interval - Days30ToInterval) / (24*60*60) >= 1)
                weak.mExpireAlertLabel.textColor = App_Constants.Instance.Color(.defaultRed)
                weak.mExpireAlertLabel.text = String(format: App_Constants.Instance.Text(.expire_library_message), Int(interval / (24*60*60) + 1))
            }
            //check email verification
            weak.mEmailVerificationView.isHidden = !(user?.user_status == Constants.kEmailNotVerified)
        }).disposed(by: disposeBag)
        Sync.shared.organization.asObservable().subscribe(onNext: {[weak self] org in
            guard let weak = self else{return}
            weak.mAirlineLabel.text = "\(org?.organization_name ?? App_Constants.Instance.Text(.unknown))"
            weak.mAirlineImage.sd_setImage(with: URL(string: "\(Api_Names.Main)\(Api_Names.org_image)\(org?.organization_logo ?? "")"), completed: nil)
        }).disposed(by: disposeBag)
        
        Sync.shared.sync_started.asObservable().subscribe(onNext: {[weak self] s in
            guard let weak = self else{return}
            if s{
                App_Constants.UI._Rotate(weak.mSyncButton)
                UIDevice.current.vibrate()
                weak.mSyncButton.isUserInteractionEnabled = false
            }
        }).disposed(by: disposeBag)
        
        Sync.shared.sync_completed.asObservable().subscribe(onNext: {[weak self] s in
            guard let weak = self else{return}
            if s{
                App_Constants.UI.Make_Toast(on: weak.view, with: App_Constants.Instance.Text(.sync_completed))
            }
        }).disposed(by: disposeBag)
        
        Sync.shared.sync_finished.asObservable().subscribe(onNext: {[weak self] s in
            guard let weak = self else{return}
            if s{
                App_Constants.UI._StopRotate(weak.mSyncButton)
                weak.mSyncButton.isUserInteractionEnabled = true
            }
        }).disposed(by: disposeBag)
        
        self._Message = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "messages") as? UINavigationController
        self._Notification = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "messages") as? UINavigationController
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
        (self._Message?.viewControllers.first as! MessagesViewController)._Type = .message
        (self._Message?.viewControllers.first as! MessagesViewController)._DidShowMessage.asObservable().subscribe(onNext: {[weak self] s in
            guard let weak = self else{return}
            weak.mMessageBackButton.isHidden = !s
        }).disposed(by: disposeBag)
        (self._Notification?.viewControllers.first as! MessagesViewController)._Type = .notification
        (self._Notification?.viewControllers.first as! MessagesViewController)._DidShowNotif.asObservable().subscribe(onNext: {[weak self] s in
            guard let weak = self else{return}
            weak.mNotificationsBackButton.isHidden = !s
        }).disposed(by: disposeBag)
        App_Constants.UI.AddChildView(mother: self, self.mMessagesMainView, _Message!)
        App_Constants.UI.AddChildView(mother: self, self.mNotificationsMainView, _Notification!)
        //Legal Check
        _CheckLegal()
    }
    
    private func _Logout(_ callback: @escaping (Bool)->Void){
        autoreleasepool{
            Sync.shared.Logout({s in
                if s{
                    Sync.shared.Log_Event(event: .logout, type: .logout, id: "\(self._User?.user_id ?? 0)", {s,m in callback(s)})
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                self.present(terms, animated: true, completion: nil)
            })
        }
    }
    
    private func _CheckLegal(){
        self.view.superview?.superview?.isUserInteractionEnabled = false
        Sync.shared.LastLegalNotes({s,m,r in
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
