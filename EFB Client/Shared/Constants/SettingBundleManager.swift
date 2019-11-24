//
//  SettingBundleManager.swift
//  EFB Client
//
//  Created by Mr.Zee on 11/10/19.
//  Copyright © 2019 MehrPardaz. All rights reserved.
//

import Foundation
import UIKit

enum SettingsBundleKeys: String{
    case auto_lock
    case version_app
}

class SettingBundleManager:NSObject{
    
    public static let shared = SettingBundleManager()
    
    public func settingInit(){
        UIApplication.shared.isIdleTimerDisabled = !checkAutoLock()
        checkVersion()
    }
    
    public func checkVersion(){
        App_Constants.Instance.SettingsSave(.version_app, (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String))
    }
    
    public func checkAutoLock()-> Bool{
        return App_Constants.Instance.SettingsLoad(.auto_lock) as? Bool ?? false
    }
    
    
    //MARK: - Listener
    public func listenToUserDefaults(){
        NotificationCenter.default.addObserver(self, selector: #selector(userDefaultChanged(_:)), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    @objc private func userDefaultChanged(_ sender: Notification){
        UIApplication.shared.isIdleTimerDisabled = !checkAutoLock()
    }
    
    public func removeSettingObserver(){
        NotificationCenter.default.removeObserver(self, name: UserDefaults.didChangeNotification, object: nil)
    }
    
}
