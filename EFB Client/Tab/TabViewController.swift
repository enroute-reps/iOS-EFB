

import UIKit
import RxSwift
import RxCocoa


public var kMessageId = "messageId"
public var kNotificationId = "notificationId"

class TabViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool{
        return self.statusBarIsHidden
    }
    
    
    @IBOutlet weak var mMainView: UIView!
    @IBOutlet weak var mTabbar: EFBTabbar!
    @IBOutlet weak var mTabbarHeight: NSLayoutConstraint!
    
    private var statusBarIsHidden:Bool = false
    private var _User:EFBUser?
    private var _Dashboard:DashboardViewController?
    private var _Library:UINavigationController?
    private var _Weather:WeatherViewController?
    private let kIsHidden = "isHidden"
    private var disposeBag = DisposeBag()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self._Initialize()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
}

extension TabViewController{
    
    private func _Initialize(){
        
        self._User = App_Constants.Instance.LoadUser()
        self._Dashboard = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "dashboard") as? DashboardViewController
        self._Library = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "fileManager") as? UINavigationController
        self._Weather = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "weather") as? WeatherViewController
        self.mTabbar.delegate = self
        App_Constants.UI.AddChildView(mother: self, self.mMainView, self._Dashboard!)
        App_Constants.UI.statusBarIsHidden.asObservable().subscribe(onNext: {[weak self] s in
            guard let weak = self else{return}
            weak.statusBarIsHidden = s
            UIView.animate(withDuration: 0.5, animations: {
                weak.setNeedsStatusBarAppearanceUpdate()
            })
        }).disposed(by: disposeBag)
        
        App_Constants.UI.tabbarIsHidden.asObservable().subscribe(onNext: {[weak self] s in
            guard let weak = self else{return}
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                weak.mTabbarHeight.constant = s ? 0 : 55
                weak.view.layoutIfNeeded()
            }, completion: nil)
        }).disposed(by: disposeBag)
        NotificationCenter.default.removeObserver(self, name: App_Constants.Instance.Notification_Name(.notification_recieved), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_NotificationRecieved), name: App_Constants.Instance.Notification_Name(.notification_recieved), object: nil)
    }
    
    @objc private func _NotificationRecieved(_ notification: NSNotification){
        if let str = NotificationManager.data[kMessageId] as? String, let _ = Int(str){
            mTabbar.gotoIndex(0)
        }else if let str = NotificationManager.data[kNotificationId] as? String, let _ = Int(str){
            mTabbar.gotoIndex(0)
        }
    }
    
}

extension TabViewController: EFBBarDelegate{
    func TabBar(_ index: Int) {
        switch index{
        case 0:
            App_Constants.UI.RemoveChildView([self._Library!, self._Weather!])
            App_Constants.UI.AddChildView(mother: self, self.mMainView, self._Dashboard!)
        case 1:
            App_Constants.UI.RemoveChildView([self._Dashboard!, self._Weather!])
            App_Constants.UI.AddChildView(mother: self, self.mMainView, self._Library!)
        case 2:
            App_Constants.UI.RemoveChildView([self._Dashboard!, self._Library!])
            App_Constants.UI.AddChildView(mother: self, self.mMainView, self._Weather!)
        default:
            break
        }
    }
}
