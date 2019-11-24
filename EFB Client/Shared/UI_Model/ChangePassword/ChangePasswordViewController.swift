//
//  ChangePasswordViewController.swift
//  EFB Client
//
//  Created by Mr.Zee on 10/16/19.
//  Copyright © 2019 MehrPardaz. All rights reserved.
//

import UIKit
import TransitionButton

class ChangePasswordViewController: UIViewController {
    
    @IBOutlet weak var mMainview: UIView!
    @IBOutlet weak var mNewPasswordTextField: UITextField!
    @IBOutlet weak var mReNewPasswordTextField: UITextField!
    @IBOutlet weak var mCancelButton: UIButton!
    @IBOutlet weak var mAlertLabel: UILabel!
    @IBOutlet weak var mOldPasswordTextField: UITextField!
    @IBOutlet weak var mAcceptButton: TransitionButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self._Initialize()
    }
    
    @IBAction func _AcceptButtonTapped(_ sender: Any) {
        self.mAlertLabel.isHidden = mNewPasswordTextField.text == mReNewPasswordTextField.text && !((mOldPasswordTextField.text ?? "").isEmpty)
        if mNewPasswordTextField.text == mReNewPasswordTextField.text && !((mNewPasswordTextField.text ?? "").isEmpty) && !((mOldPasswordTextField.text ?? "").isEmpty){
            mAcceptButton.startAnimation()
            HttpClient.http()._Post(relativeUrl: Api_Names.change_password, body: Change_Password_Body(oldPassword: mOldPasswordTextField.text!, newPassword: mNewPasswordTextField.text!), callback: {(s,m,r:Notification_Model?) in
                if s{
                    App_Constants.UI.Make_Toast(with: App_Constants.Instance.Text(.password_changed_s), in: 3)
                    self.mAcceptButton.stopAnimation()
                    self.dismiss(animated: true, completion: nil)
                }else{
                    App_Constants.UI.Make_Alert("", App_Constants.Instance.Text(.try_again))
                    self.mAcceptButton.stopAnimation(animationStyle: .shake, revertAfterDelay: 0, completion: nil)
                }
            })
        }
    }
    
    @IBAction func _CancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension ChangePasswordViewController{
    
    private func _Initialize(){
        self.mMainview.cornerRadius = 10
        self.mCancelButton.cornerRadius = 10
        self.mCancelButton.border(1, self.mAcceptButton.backgroundColor ?? App_Constants.Instance.Color(.light))
    }
    
}
