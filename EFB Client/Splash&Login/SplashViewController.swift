//
//  SplashViewController.swift
//  EFB Client
//
//  Created by Mr.Zee on 10/13/19.
//  Copyright © 2019 MehrPardaz. All rights reserved.
//

import UIKit
import SwiftyGif

class SplashViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBOutlet weak var mImage: UIImageView!
    
    private var gifDidEnd = false{
        didSet{
            if syncDidEnd && gifDidEnd{
                self._RemoveImage()
                App_Constants.UI.performSegue(self, canGoDirect ? .direct : .login)
            }else if gifDidEnd && !canGoDirect{
                self._RemoveImage()
                App_Constants.UI.performSegue(self, .login)
            }
        }
    }
    private var syncDidEnd = false{
        didSet{
            if syncDidEnd && gifDidEnd{
                self._RemoveImage()
                App_Constants.UI.performSegue(self, canGoDirect ? .direct : .login)
            }
        }
    }
    private var canGoDirect = false
    private let kIntroGif = "intro.gif"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self._Initialize()
    }
}

extension SplashViewController{
    
    private func _Initialize(){
        self._LoadGif()
        if App_Constants.Instance.Account_Check(){
            self._Sync()
            canGoDirect = true
        }
    }
    
    private func _LoadGif(){
        autoreleasepool{[weak self] in
            guard let weak = self else{return}
            do{
                let gif = try UIImage(gifName: kIntroGif)
                weak.mImage.setGifImage(gif)
                weak.mImage.loopCount = 1
                weak.mImage.delegate = self
            }catch(let err){
                print(err.localizedDescription)
            }
        }
    }
    
    private func _Sync(){
        Sync.syncUser({ completed in
            self.syncDidEnd = true
        })
    }
    
    private func _RemoveImage(){
        SwiftyGifManager.defaultManager.clear()
        self.mImage.delegate = nil
        self.mImage.stopAnimatingGif()
        self.mImage = nil
    }
}

extension SplashViewController:SwiftyGifDelegate{
    func gifDidStop(sender: UIImageView) {
        self.gifDidEnd = true
    }
}
