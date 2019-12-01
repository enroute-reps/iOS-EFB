//
//  SupportViewController.swift
//  EFB Client
//
//  Created by Mr.Zee on 11/3/19.
//  Copyright © 2019 MehrPardaz. All rights reserved.
//

import UIKit
import MessageUI
import TransitionButton

public enum MailType:String{
    case support = "Support"
    case feedback = "Feedback"
}

class SupportViewController: UIViewController {
    
    @IBOutlet weak var mNavigationView: UIView!
    @IBOutlet weak var mTitle: UILabel!
    @IBOutlet weak var mSubjectTextField: UITextField!
    @IBOutlet weak var mTextView: UITextView!
    @IBOutlet weak var mSendButton: TransitionButton!
    
    
    private var _Type: MailType = .support
    
    
    
    convenience init(type: MailType){
        self.init()
        self._Type = type
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self._Initialize()
    }

    @IBAction func _BackButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func _CloseButtonTapped(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func _SendButtonTapped(_ sender: Any) {
        guard (mTitle.text?.count ?? 0)  > 3 else{
            App_Constants.UI.Make_Alert("", "*Subject must be 3 character at least.")
            return
        }
        guard (mTextView.text?.count ?? 0) > 5 else{
            App_Constants.UI.Make_Alert("", "*Text must be 5 character at least.")
            return
        }
        self.mSendButton.startAnimation()
        HttpClient.http()._Post(relativeUrl: Api_Names.feedback, body: Feedback_Body(title: "\(self._Type.rawValue)-\(self.mSubjectTextField.text ?? "")", text: self.mTextView.text ?? ""), callback: {(s,m,r:String?) in
            if s{
                App_Constants.UI.Make_Toast(with: App_Constants.Instance.Text(.message_sent) + (self._Type == .feedback ? App_Constants.Instance.Text(.feedback) : ""))
                self.navigationController?.popViewController(animated: true)
                self.mSendButton.stopAnimation(animationStyle: .normal, revertAfterDelay: 0, completion: nil)
            }else{
                App_Constants.UI.Make_Alert("", App_Constants.Instance.Text(.message_not_sent))
                self.mSendButton.stopAnimation(animationStyle: .shake, revertAfterDelay: 0, completion: nil)
            }
        })
        
    }
}

extension SupportViewController{
    
    private func _Initialize(){
        self.mTitle.text = self._Type.rawValue
        self.mSubjectTextField.cornerRadius = 10
        self.mSubjectTextField.border(1, App_Constants.Instance.Color(.light))
        self.mTextView.cornerRadius = 10
        self.mTextView.border(1, App_Constants.Instance.Color(.light))
        self.mSendButton.border(1, App_Constants.Instance.Color(.light))
    }
    
}

extension SupportViewController:MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
