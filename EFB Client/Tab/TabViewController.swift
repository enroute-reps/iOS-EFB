

import UIKit

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
    private let kIsHidden = "isHidden"
    
    
    
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
        self.mTabbar.delegate = self
        App_Constants.UI.AddChildView(mother: self, self.mMainView, self._Dashboard!)
        NotificationCenter.default.removeObserver(self, name: App_Constants.Instance.Notification_Name(.tabbar_height), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_TabBarNotification(_:)), name: App_Constants.Instance.Notification_Name(.tabbar_height), object: nil)
        NotificationCenter.default.removeObserver(self, name: App_Constants.Instance.Notification_Name(.hide_statusBar), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_StatusBarNotification(_:)), name: App_Constants.Instance.Notification_Name(.hide_statusBar), object: nil)
        NotificationCenter.default.removeObserver(self, name: App_Constants.Instance.Notification_Name(.notification_recieved), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_NotificationRecieved), name: App_Constants.Instance.Notification_Name(.notification_recieved), object: nil)
        NotificationCenter.default.removeObserver(self, name: App_Constants.Instance.Notification_Name(.logout), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_NotificationLogout(_:)), name: App_Constants.Instance.Notification_Name(.logout), object: nil)
    }
    
    @objc private func _TabBarNotification(_ notification: NSNotification){
        if let isHidden = notification.userInfo?[kIsHidden] as? Bool{
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                self.mTabbarHeight.constant = isHidden ? 0 : 55
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @objc private func _StatusBarNotification(_ notification: Notification){
        if let isHidden = notification.userInfo?[kIsHidden] as? Bool{
            self.statusBarIsHidden = isHidden
            UIView.animate(withDuration: 0.5, animations: {
                self.setNeedsStatusBarAppearanceUpdate()
            })
        }
    }
    
    @objc private func _NotificationRecieved(_ notification: NSNotification){
        if let str = NotificationManager.data[kMessageId] as? String, let _ = Int(str){
            mTabbar.gotoIndex(0)
        }else if let str = NotificationManager.data[kNotificationId] as? String, let _ = Int(str){
            mTabbar.gotoIndex(0)
        }
    }
    
    @objc private func _NotificationLogout(_ notification: NSNotification){
        self.navigationController?.popToRootViewController(animated: true)
        NotificationCenter.default.removeObserver(self._Dashboard!)
        NotificationCenter.default.removeObserver(self._Library!)
        NotificationCenter.default.removeObserver(self)
        App_Constants.Instance.RemoveAllRecords()
    }
    
}

extension TabViewController: EFBBarDelegate{
    func TabBar(_ index: Int) {
        switch index{
        case 0:
            App_Constants.UI.RemoveChildView([self._Library!])
            App_Constants.UI.AddChildView(mother: self, self.mMainView, self._Dashboard!)
        case 1:
            App_Constants.UI.RemoveChildView([self._Dashboard!])
            App_Constants.UI.AddChildView(mother: self, self.mMainView, self._Library!)
        case 2:
            App_Constants.UI.RemoveChildView([])
        default:
            break
        }
    }
}
