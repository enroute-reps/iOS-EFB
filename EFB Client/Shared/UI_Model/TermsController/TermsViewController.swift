//
//  TermsViewController.swift
//  EFB Client
//
//  Created by Mr.Zee on 12/1/19.
//  Copyright © 2019 MehrPardaz. All rights reserved.
//

import UIKit
import Alamofire
import TransitionButton

class TermsViewController: UIViewController {
    
    @IBOutlet weak var mTextView: UITextView!
    @IBOutlet weak var mLeftButton: UIButton!
    @IBOutlet weak var mRightButton: TransitionButton!
    
    
    var fileName:String?
    var date:String?
    var message:String?{
        didSet{
            if mTextView != nil {
                self.mTextView.text = message
            }
        }
    }
    
    convenience init(file: String, date: String){
        self.init()
        self.fileName = file
        self.date = date
        getFile()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self._Init()
    }
    
    @IBAction func _LeftButtonTapped(_ sender: Any) {
        App_Constants.UI.Make_Alert("", "Using application need Agreement")
    }
    
    @IBAction func _RightButtonTapped(_ sender: Any) {
        mRightButton.startAnimation()
        self.mLeftButton.isHidden = true
        self.view.isUserInteractionEnabled = false
        Sync.Log_Event(event: .legal_accepted, type: .legal, id: "\(App_Constants.Instance.LoadUser()?.user_id ?? 0)", {s,m in
            self.view.isUserInteractionEnabled = true
            UIView.animate(withDuration: 0.3, animations: {
                self.mLeftButton.isHidden = false
            })
            self.mRightButton.stopAnimation()
            if s{
                App_Constants.Instance.SettingsSave(.legal_time, self.date ?? "")
                self.dismiss(animated: true, completion: nil)
            }else{
                App_Constants.UI.Make_Alert("", m)
            }
        })
    }
    
}

extension TermsViewController{
    private func _Init(){
        self.mLeftButton.cornerRadius = 10
        self.mLeftButton.border(1, App_Constants.Instance.Color(.light))
        self.mTextView.text = self.message
    }
    
    private func getFile(){
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
        .userDomainMask, true)[0]
        let documentsURL = URL(fileURLWithPath: documentsPath, isDirectory: true)
            let fileURL = documentsURL.appendingPathComponent(self.fileName ?? "")
        return (fileURL, [.removePreviousFile, .createIntermediateDirectories]) }
        
        Alamofire.download(URL(string: String(format: Api_Names.main2, kPort8080) + String(format: Api_Names.legal_content, self.fileName ?? ""))!,method: .get,encoding: JSONEncoding.default,headers: nil,to: destination).validate(statusCode: 200..<300).responseString{response in
            switch response.result{
            case .success:
                do{
                    let data = try Data.init(contentsOf: response.destinationURL!)
                    self.message = String(data: data, encoding: .utf8)
                }catch{
                    self.getFile()
                }
            case .failure:
                self.getFile()
            }
        }
    }
}
