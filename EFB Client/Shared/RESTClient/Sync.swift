

import Foundation
import Alamofire
import Firebase
import SWXMLHash
import RxSwift
import RxCocoa


class Sync {
    
    public static var shared = Sync()
    public var user:BehaviorRelay<EFBUser?> = BehaviorRelay(value: App_Constants.Instance.LoadUser())
    public var notifications:BehaviorRelay<[Notification_Model]?> = BehaviorRelay(value: App_Constants.Instance.LoadAllFormCore(.notification))
    public var messages:BehaviorRelay<[Message]?> = BehaviorRelay(value: App_Constants.Instance.LoadAllFormCore(.message))
    public var organization:BehaviorRelay<Organization?> = BehaviorRelay(value: App_Constants.Instance.LoadFromCore(.organization))
    public var synced_notifications:BehaviorRelay<[Log]?> = BehaviorRelay(value: App_Constants.Instance.LoadAllFormCore(.log_notification))
    public var manuals:BehaviorRelay<[Manual]?> = BehaviorRelay(value: App_Constants.Instance.LoadAllFormCore(.manual))
    private var disposeBag = DisposeBag()
    // state 1: no change , state 2: completed and true , state 3: completed and false
    private var user_synced:Int = 1{
        didSet{
            sync_completed.accept(check_sync_completed())
            sync_finished.accept(check_sync_finished())
        }
    }
    private var notification_synced:Int = 1{
        didSet{
            self.syncBadgeIcon()
            sync_completed.accept(check_sync_completed())
            sync_finished.accept(check_sync_finished())
        }
    }
    private var manuals_synced:Int = 1{
        didSet{
            sync_completed.accept(check_sync_completed())
            sync_finished.accept(check_sync_finished())
        }
    }
    private var messages_synced:Int = 1{
        didSet{
            self.syncBadgeIcon()
            sync_completed.accept(check_sync_completed())
            sync_finished.accept(check_sync_finished())
        }
    }
    private var org_synced:Int = 1{
        didSet{
            sync_completed.accept(check_sync_completed())
            sync_finished.accept(check_sync_finished())
        }
    }
    private var synced_notifications_synced:Int = 1{
        didSet{
            self.syncBadgeIcon()
            sync_completed.accept(check_sync_completed())
            sync_finished.accept(check_sync_finished())
        }
    }
    public var sync_started:BehaviorRelay<Bool> = BehaviorRelay(value: false)
    public var sync_completed:BehaviorRelay<Bool> = BehaviorRelay(value: false)
    public var sync_finished:BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    private func check_sync_completed()->Bool{
        return notification_synced == 2 && manuals_synced == 2 && messages_synced == 2 && org_synced == 2 && synced_notifications_synced == 2 && user_synced == 2
    }
    
    private func check_sync_finished()->Bool{
        return notification_synced >= 2 && manuals_synced >= 2 && messages_synced >= 2 && org_synced >= 2 && synced_notifications_synced >= 2 && user_synced >= 2
    }
    
    func syncUser(){
        if !(NetworkReachabilityManager()?.isReachable ?? false){
            return
        }
        sync_started.accept(true)
        sync_completed.accept(false)
        sync_finished.accept(false)
        user_synced = 1
        notification_synced = 1
        messages_synced = 1
        manuals_synced = 1
        org_synced = 1
        synced_notifications_synced = 1
        self.syncUserInfo()
        self.syncSeenedNotifications()
        self.syncMessages()
        self.syncManualsList()
        self.syncOrganizationInfo()
        self.syncNotifications()
            
    }
    
    func syncNotifications() {
        HttpClient.http()._GetArray(relativeUrl: Api_Names.notifications, callback: {(s,m,r:[Notification_Model]?) in
            self.notification_synced = s ? 2 : 3
            if s{
                self.notifications.accept(r)
                App_Constants.Instance.SaveArrayToCore(r!, .notification)
            }else{
                App_Constants.UI.Make_Alert("", "Notifications could not load. please check your connection.")
            }
        })
    }
    
    func syncSeenedNotifications(){
        HttpClient.http()._GetArray(relativeUrl: Api_Names.seened_notifications, callback: {(s,m,r:[Log]?) in
            self.synced_notifications_synced = s ? 2 : 3
            if s{
                self.synced_notifications.accept(r)
                App_Constants.Instance.SaveArrayToCore(r ?? [], .log_notification)
            }else{
                App_Constants.UI.Make_Alert("", "Notifications could not load. please check your connection.")
            }
            
        })
    }
    
    func syncMessages() {
        HttpClient.http()._GetArray(relativeUrl: Api_Names.messages, callback: {(s,m,r:[Message]?) in
            self.messages_synced = s ? 2 : 3
            if s{
                self.messages.accept(r)
                App_Constants.Instance.SaveArrayToCore(r!, .message)
            }else{
                App_Constants.UI.Make_Alert("", "Messages could not load. please check your connection.")
            }
        })
    }
    
    func syncUserInfo() {
        HttpClient.http()._GetArray(relativeUrl: Api_Names.info, callback: {(s,m,r:[EFBUser]?) in
            self.user_synced = s ? 2 : 3
            if s{
                App_Constants.Instance.SaveUser((r?.first) ?? EFBUser())
                self.user.accept(r?.first)
                if let id = App_Constants.Instance.SettingsLoad(.UserId) as? Int{
                    if id != r?.first?.user_id{
                        FilesManager.default.clearAll(Constants.kManualDirectory)
                        App_Constants.Instance.SettingsSave(.UserId, r?.first?.user_id ?? 0)
                    }
                }else{
                    FilesManager.default.clearAll(Constants.kManualDirectory)
                    App_Constants.Instance.SettingsSave(.UserId, r?.first?.user_id ?? 0)
                }
            }else{
                App_Constants.UI.Make_Alert("", "User could not load. please check your connection.")
            }
        })
    }
    
    func syncBadgeIcon(){
        autoreleasepool{
            var count = 0
            for msg in self.messages.value ?? []{
                if (msg.message_read_date_time ?? "").isEmpty{
                    count += 1
                }
            }
            for notif in self.notifications.value ?? []{
                if !(self.synced_notifications.value ?? []).contains(where: {$0.log_type_id == notif.notification_id}){
                    count += 1
                }
            }
            UIApplication.shared.applicationIconBadgeNumber = count
        }
    }
    
    func syncManualsList() {
        HttpClient.http()._GetArray(relativeUrl: Api_Names.manuals, callback: {(s,m,r:[Manual]?) in
            self.manuals_synced = s ? 2 : 3
            if s{
                App_Constants.Instance.SaveArrayToCore(r ?? [], .manual)
                self.manuals.accept(r)
            }else{
                App_Constants.UI.Make_Alert("", "Manuals could not load. please check your connection.")
            }
        })
    }
    
    func Log_Event(event: Log_Event, type: Log_Event_Type, id: String? = "",_ callback: @escaping (Bool,String)->Void){
        HttpClient.http()._Post(relativeUrl: Api_Names.log, body: Log_Events(event: event.rawValue, description: Log_Desc_Body(device: "iOS App", type: type.rawValue, id: id)), callback: {(r,m,s:String?) in
            callback(r,m)
        })
    }
    
    func syncOrganizationInfo(){
        HttpClient.http()._GetArray(relativeUrl: Api_Names.organization, callback: {(s,m,r:[Organization]?) in
            self.org_synced = s ? 2 : 3
            if s{
                App_Constants.Instance.SaveToCore(r?.first ?? Organization(), .organization)
                self.organization.accept(r?.first)
            }else{
                App_Constants.UI.Make_Alert("", "Organization could not load. please check your connection.")
            }
        })
    }
    
    func syncFCMToken(){
        InstanceID.instanceID().instanceID(handler: {token,err in
            App_Constants.Instance.SettingsSave(.FCMToken, token?.token ?? "")
            HttpClient.http()._Post(relativeUrl: Api_Names.fcmToken, body: FCMToken_Body(token: token?.token ?? ""), callback: {(s,m,r:String?) in
                
            })
        })
    }
    
    func Logout(_ callback: @escaping (Bool)->Void){
        HttpClient.http()._Get(relativeUrl: Api_Names.logout, callback: {(s,m,r:String?) in
            if s{
                App_Constants.Instance.RemoveAllRecords()
                self.user.accept(nil)
                self.manuals.accept(nil)
                self.notifications.accept(nil)
                self.synced_notifications.accept(nil)
                self.messages.accept(nil)
                self.organization.accept(nil)
            }
            callback(s)
        })
    }
    
    func LastLegalNotes(_ callback: @escaping (Bool,String,Legal?)->Void){
        HttpClient.http(false,port: kPort4000)._GetDefault(relativeUrl: Api_Names.legal, callback: {(s,m,r:Legal?) in
            callback(s,m,r)
        })
    }
    
    func getWeather(_ dataSource: String = "metars", _ requestType: String = "retrieve", _ format: String = "xml", _ hourseBeforeNow: Double = 1.0, stationString: String, callback: @escaping (Bool,String, [Weather]?)->Void){
        let relativeURL = "dataSource=\(dataSource)&requestType=\(requestType)&format=\(format)&hoursBeforeNow=\(hourseBeforeNow)&stationString=\(stationString)"
        HttpClient.default._GetXML(relativeUrl: relativeURL, callback: {(s,m,r:XMLIndexer?) in
            guard let result = r else{
                callback(false, m, nil)
                return
            }
            var dataText:[Weather] = []
            for i in 0..<(Int(result["response"]["data"].element?.attribute(by: "num_results")?.text ?? "0") ?? 0){
                let data = result["response"]["data"]["METAR"][i]
                dataText.append(Weather(raw_text: data["raw_text"].element?.text ?? "", station_id: data["station_id"].element?.text ?? "", observation_time: data["observation_time"].element?.text ?? "", latitude: Double(data["latitude"].element?.text ?? "0.0"), longitude: Double(data["longitude"].element?.text ?? "0.0"), temp_c: Double(data["temp_c"].element?.text ?? "0.0"), dewpoint_c: Double(data["dewpoint_c"].element?.text ?? "0.0"), wind_dir_degrees: Double(data["wind_dir_degrees"].element?.text ?? "0.0"), wind_speed_kt: Double(data["wind_speed_kt"].element?.text ?? "0.0"), visibility_statute_mi: Double(data["visibility_statute_mi"].element?.text ?? "0.0"), altim_in_hg: Double(data["altim_in_hg"].element?.text ?? "0.0"), quality_control_flags: WeatherQualityControlFlags(no_signal: Bool(data["quality_control_flags"]["no_signal"].element?.text ?? "false")), sky_condition: WeatherSkyCondition(sky_cover: data["sky_condition"].element?.attribute(by: "sky_cover")?.text ?? "", cloud_base_ft_agl: Int(data["sky_condition"].element?.attribute(by: "cloud_base_ft_agl")?.text ?? "0")), flight_category: data["flight_category"].element?.text ?? "", metar_type: data["metar_type"].element?.text ?? "", elevation_m: Double(data["elevation_m"].element?.text ?? "")))
            }
            let weatherResp = WeatherResponse(request_index: Int(result["response"]["request_index"].element?.text ?? "0"), data_source: result["response"]["data_source"].element?.attribute(by: "name")?.text ?? "", request: result["response"]["request"].element?.attribute(by: "type")?.text ?? "", errors: result["response"]["errors"].element?.text ?? "", warnings: result["response"]["warnings"].element?.text ?? "", time_taken_ms: Int(result["response"]["time_taken_ms"].element?.text ?? "0"), data: dataText)
            callback(s, "", weatherResp.data)
        })
    }
    
    func getServiceUrl() ->String {
        return Api_Names.main
    }
    
    func getUserId() ->String {
        return "\(App_Constants.Instance.LoadUser()?.user_id ?? 0)"
    }
    
}
