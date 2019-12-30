

import UIKit
import TransitionButton
import RxSwift

class LoginViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var mCopyRightLabel: UILabel!
    @IBOutlet weak var mLoginButton: TransitionButton!
    @IBOutlet weak var mEmailView: UIView!
    @IBOutlet weak var mEmailTextField: UITextField!
    @IBOutlet weak var mRetypeEmailTextField: UITextField!
    @IBOutlet weak var mVerifyEmailButton: TransitionButton!
    
    private var disposeBag:DisposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self._Initialize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @IBAction func getAccess(_ sender: UIButton) {
        
        self.mLoginButton.startAnimation()
        self.view.endEditing(true)
        HttpClient.default._PostHeader(relativeUrl: Api_Names.login, body: LoginBody(username:usernameField.text ?? "",password: passwordField.text ?? ""), callback: {(s,m,r) in
            if s{
                App_Constants.Instance.SettingsSave(.Token, r!)
                Sync.shared.syncUser()
            }else{
                self.mLoginButton.stopAnimation(animationStyle: .shake, revertAfterDelay: 0, completion: nil)
                App_Constants.UI.Make_Toast(with: App_Constants.Instance.Text(.no_connection))
            }
        })
    }
    
    @IBAction func _VerifyEmailButtonTapped(_ sender: Any) {
        guard mEmailTextField.text == mRetypeEmailTextField.text && !((mEmailTextField.text ?? "").isEmpty) && (mEmailTextField.text ?? "").isEmail else{
            App_Constants.UI.Make_Alert("", App_Constants.Instance.Text(.email_not_valid))
            return
        }
        self.mVerifyEmailButton.startAnimation()
        self.view.endEditing(true)
        //verify email ???
        HttpClient.http()._Post(relativeUrl: Api_Names.email_verify, body: Email_Body(email: mEmailTextField.text ?? ""), callback: {(s,m,r:Edit?) in
            if s{
                self.mEmailTextField.text = ""
                self.mRetypeEmailTextField.text = ""
                self.mVerifyEmailButton.stopAnimation(animationStyle: .normal, revertAfterDelay: 0, completion: nil)
                App_Constants.UI.Make_Toast(with: "Verification email was sent to you.", in: 4, in: .top)
                App_Constants.UI.changeRootController("main")
            }else{
                self.mVerifyEmailButton.stopAnimation(animationStyle: .shake, revertAfterDelay: 0, completion: nil)
                App_Constants.UI.Make_Alert("", m)
            }
        })
        
    }
    
override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
}

}

extension LoginViewController{
    
    private func _Initialize(){
        loginView.cornerRadius = 10
        loginView.border(2, App_Constants.Instance.Color(.dark).withAlphaComponent(0.12))
        mEmailView.cornerRadius = 10
        mEmailView.border(2, App_Constants.Instance.Color(.dark).withAlphaComponent(0.12))
        self.mCopyRightLabel.text = "Version \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)"
        self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(_EndEditing(_:))))
        mEmailTextField.delegate = self
        mRetypeEmailTextField.delegate = self
        usernameField.delegate = self
        passwordField.delegate = self
        Sync.shared.sync_finished.accept(false)
        Sync.shared.sync_finished.asObservable().subscribe(onNext: {[weak self] s in
            guard let weak = self else {return}
            if s{
                weak.usernameField.text = ""
                weak.passwordField.text = ""
                weak.mLoginButton.stopAnimation(animationStyle: .normal, revertAfterDelay: 0, completion: nil)
            }
        }).disposed(by: disposeBag)
        
        Sync.shared.user.asObservable().subscribe(onNext: {[weak self] user in
            guard let weak = self else {return}
            if let user = user{
                if user.user_status ?? 0 == Constants.kEmailNotVerified{
                    weak._BeginVerifyEmail()
                }else{
                    App_Constants.UI.changeRootController("main")
                }
            }
        }).disposed(by: disposeBag)
    }
    
    private func _BeginVerifyEmail(){
        self.mLoginButton.stopAnimation(animationStyle: .normal, revertAfterDelay: 0, completion: nil)
        UIView.transition(with: mEmailView, duration: 0.7, options: .transitionFlipFromBottom, animations: {
            self.mEmailView.isHidden = false
            self.loginView.isHidden = true
        }, completion: nil)
    }
    
    @objc private func _EndEditing(_ sender: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
}

extension LoginViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == mEmailTextField{
            textField.resignFirstResponder()
            mRetypeEmailTextField.becomeFirstResponder()
        }else if textField == mRetypeEmailTextField{
            textField.resignFirstResponder()
        }else if textField == usernameField{
            textField.resignFirstResponder()
            passwordField.becomeFirstResponder()
        }else if textField == passwordField{
            passwordField.resignFirstResponder()
        }
        
        return true
    }
}
