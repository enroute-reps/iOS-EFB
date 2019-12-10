

import Foundation


public let kPort8080 = 8080
public let kPort4000 = 4000

public class Api_Names:NSObject{
    
    public static let main = "https://Enrouteservice.com:\(kPort4000)/"
    public static let Main = "https://Enrouteservice.com:\(kPort8080)/"
    public static let main2 = "https://enrouteservice.com:%d/"
    
    public static var main1:String{
        get {return ((App_Constants.Instance.SettingsLoad(.server) as? String)?.isEmpty ?? true) ? "https://Enrouteservice.com:\(kPort4000)" : App_Constants.Instance.SettingsLoad(.auto_lock) as? String ?? main}
    }
    
    public static var Main1:String{
        get{return ((App_Constants.Instance.SettingsLoad(.server) as? String)?.isEmpty ?? true) ? "https://Enrouteservice.com:\(kPort8080)" : App_Constants.Instance.SettingsLoad(.auto_lock) as? String ?? Main}
    }
    
    public static let login = "users/login"
    public static let info = "users/info"
    public static let notifications = "notifications/list"
    public static let manuals = "manuals/list"
    public static let messages = "messages/list"
    public static let message_seen = "messages/seen"
    public static let download_manual = "assets/manuals/"
    public static let image = "assets/usersdata/"
    public static let org_image = "assets/orgdata/"
    public static let change_password = "users/changepassword"
    public static let feedback = "feedbacks/send"
    public static let organization = "organizations/info"
    public static let log = "logs/push"
    public static let seened_notifications = "logs/seennotifications"
    public static let logout = "users/logout"
    public static let fcmToken = "users/registernotificationtoken"
    public static let email_verify = "users/updateemail"
    public static let legal = "users/lastlegalnotes"
    public static let legal_content = "assets/legalnotes/%@"
}
