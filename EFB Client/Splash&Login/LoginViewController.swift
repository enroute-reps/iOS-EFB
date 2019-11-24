//
//  ViewController.swift
//  EFB Client
//
//  Created by Mohammadreza Mostafavi on 9/8/18.
//  Copyright © 2018 MehrPardaz. All rights reserved.
//

import UIKit
import TransitionButton

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
                Sync.syncUser({success in
                    if success{
                        if App_Constants.Instance.LoadUser()?.user_status == Constants.kEmailNotVerified{
                            self._BeginVerifyEmail()
                        }else{
                          App_Constants.UI.performSegue(self, .login)
                        }

                    }else{
                        App_Constants.UI.Make_Toast(with: App_Constants.Instance.Text(.no_connection))
                    }
                    DispatchQueue.main.async{
                        self.mLoginButton.stopAnimation(animationStyle: .normal, revertAfterDelay: 0, completion: nil)
                    }
                })
            }else{
                self.mLoginButton.stopAnimation(animationStyle: .shake, revertAfterDelay: 0, completion: nil)
                App_Constants.UI.Make_Toast(with: App_Constants.Instance.Text(.no_connection))
            }
        })
    }
    
    @IBAction func _VerifyEmailButtonTapped(_ sender: Any) {
        guard mEmailTextField.text == mRetypeEmailTextField.text && !((mEmailTextField.text ?? "").isEmpty) && (mEmailTextField.text ?? "").isEmail else{return}
        self.mVerifyEmailButton.startAnimation()
        self.view.endEditing(true)
        //verify email ???
        App_Constants.UI.performSegue(self, .login)
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
    }
    
    private func _BeginVerifyEmail(){
        self.mLoginButton.stopAnimation(animationStyle: .normal, revertAfterDelay: 0, completion: nil)
        UIView.transition(with: mEmailView, duration: 0.7, options: .transitionFlipFromBottom, animations: {
            self.mEmailView.isHidden = false
            self.loginView.isHidden = true
        }, completion: nil)
    }
    
}
