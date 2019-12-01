//
//  Sync.swift
//  EFB Client
//
//  Created by Mohammadreza Mostafavi on 10/9/18.
//  Copyright © 2018 MehrPardaz. All rights reserved.
//

import Foundation
import Alamofire
import Firebase


class Sync {
    
    private static var kToken = "Token"
    private static var kAuthorization = "Authorization"
    
    static func syncUser(_ completed: @escaping(Bool,String?)->Void){
        NotificationCenter.default.post(name: App_Constants.Instance.Notification_Name(.syncing), object: nil)
        syncUserInfo(completed: {
            syncNotifications(completed: {
                syncMessages(completed:{
                    syncManualsList(completed: {
                        syncOrganizationInfo({s,m in
                            if s{
                                syncSeenedNotifications({s,m in
                                    if s{
                                        syncBadgeIcon()
                                        NotificationCenter.default.post(name: App_Constants.Instance.Notification_Name(.sync_all), object: nil)
                                        NotificationCenter.default.post(name: App_Constants.Instance.Notification_Name(.sync_finished), object: nil)
                                        completed(true,nil)
                                    }else{
                                        NotificationCenter.default.post(name: App_Constants.Instance.Notification_Name(.sync_finished), object: nil)
                                        completed(false,m)
                                    }
                                })
                            }else{
                                NotificationCenter.default.post(name: App_Constants.Instance.Notification_Name(.sync_finished), object: nil)
                                completed(false,m)
                            }
                        })
                    }, errorHandle: {m in completed(false,m)})}, errorHandle: {m in completed(false,m)})
            }, errorHandle: {m in completed(false,m)})
        }, errorHandle: {m in completed(false,m)})
    }
    
    static func syncNotifications(completed: @escaping ()->Void, errorHandle: @escaping (String)->Void) {
        HttpClient.http()._GetArray(relativeUrl: Api_Names.notifications, callback: {(s,m,r:[Notification_Model]?) in
            if s{
                App_Constants.Instance.SaveArrayToCore(r!, .notification)
                completed()
            }else{
                errorHandle(m)
            }
        })
    }
    
    static func syncSeenedNotifications(_ callback: @escaping (Bool,String?)->Void){
        HttpClient.http()._GetArray(relativeUrl: Api_Names.seened_notifications, callback: {(s,m,r:[Log]?) in
            if s{
                App_Constants.Instance.SaveArrayToCore(r ?? [], .log_notification)
            }
            callback(s,m)
        })
    }
    
    static func syncMessages(completed: @escaping ()->Void, errorHandle: @escaping (String)->Void) {
        HttpClient.http()._GetArray(relativeUrl: Api_Names.messages, callback: {(s,m,r:[Message]?) in
            if s{
                App_Constants.Instance.SaveArrayToCore(r!, .message)
                completed()
            }else{
                errorHandle(m)
            }
        })
    }
    
    static func syncUserInfo(completed: @escaping ()->Void, errorHandle: @escaping (String)->Void) {
        HttpClient.http()._GetArray(relativeUrl: Api_Names.info, callback: {(s,m,r:[EFBUser]?) in
            if s{
                App_Constants.Instance.SaveUser((r?.first) ?? EFBUser())
                completed()
            }else{
                errorHandle(m)
            }
        })
    }
    
    static func syncBadgeIcon(){
        autoreleasepool{
            var count = 0
            let messages: [Message] = App_Constants.Instance.LoadAllFormCore(.message) ?? []
            let notifications: [Notification_Model] = App_Constants.Instance.LoadAllFormCore(.notification) ?? []
            let seenedNotifications:[Log] = App_Constants.Instance.LoadAllFormCore(.log_notification) ?? []
            for msg in messages{
                if (msg.message_read_date_time ?? "").isEmpty{
                    count += 1
                }
            }
            for notif in notifications{
                if !seenedNotifications.contains(where: {$0.log_type_id == notif.notification_id}){
                    count += 1
                }
            }
            
            UIApplication.shared.applicationIconBadgeNumber = count
        }
    }
    

    static func downloadFile(manual: Manual, progress: @escaping (Progress)->Void, completed: @escaping ()->Void, errorHandle: @escaping ()->Void) {
        autoreleasepool{
            let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileURL = DocumentDirURL.appendingPathComponent(Constants.kManualDirectory).appendingPathComponent("\(manual.manual_version ?? "")_\(manual.manual_title ?? "")_\(manual.upload_date ?? "")_\(manual.manual_description ?? "")")
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                return (fileURL, [.removePreviousFile])
            }
            HttpClient.http()._Download(relativeUrl: Api_Names.download_manual + (manual.manual_file_name ?? ""), to: destination, process: {prog in
                progress(prog)
            },callback: {s,m in
                if s{
                    completed()
                }else{
                    errorHandle()
                }
            })
        }
    }
    
    static func syncManualsList(completed: @escaping ()->Void, errorHandle: @escaping (String)->Void) {
        HttpClient.http()._GetArray(relativeUrl: Api_Names.manuals, callback: {(s,m,r:[Manual]?) in
            if s{
                App_Constants.Instance.SaveArrayToCore(r ?? [], .manual)
                completed()
            }else{
                errorHandle(m)
            }
        })
    }
    
    static func Log_Event(event: Log_Event, type: Log_Event_Type, id: String? = "",_ callback: @escaping (Bool,String)->Void){
        HttpClient.http()._Post(relativeUrl: Api_Names.log, body: Log_Events(event: event.rawValue, description: Log_Desc_Body(device: "iOS App", type: type.rawValue, id: id)), callback: {(r,m,s:String?) in
            callback(r,m)
        })
    }
    
    static func syncOrganizationInfo(_ callback: @escaping (Bool,String?)->Void){
        HttpClient.http()._GetArray(relativeUrl: Api_Names.organization, callback: {(s,m,r:[Organization]?) in
            if s{
                App_Constants.Instance.SaveToCore(r?.first ?? Organization(), .organization)
                callback(true,nil)
            }else{
                callback(false,m)
            }
        })
    }
    
    static func syncFCMToken(){
        InstanceID.instanceID().instanceID(handler: {token,err in
            App_Constants.Instance.SettingsSave(.FCMToken, token?.token ?? "")
            // should sync with server
            HttpClient.http()._Post(relativeUrl: Api_Names.fcmToken, body: FCMToken_Body(token: token?.token ?? ""), callback: {(s,m,r:String?) in
                
            })
        })
    }
    
    static func Logout(_ callback: @escaping (Bool)->Void){
        HttpClient.http()._Get(relativeUrl: Api_Names.logout, callback: {(s,m,r:String?) in
            callback(s)
        })
    }
    
    static func LastLegalNotes(_ callback: @escaping (Bool,String,Legal?)->Void){
        HttpClient.http(false,port: kPort4000)._GetDefault(relativeUrl: Api_Names.legal, callback: {(s,m,r:Legal?) in
            callback(s,m,r)
        })
    }
    
    static func getServiceUrl() ->String {
        return Api_Names.main
    }
    
    static func getUserId() ->String {
        return "\(App_Constants.Instance.LoadUser()?.user_id ?? 0)"
    }
    
}
