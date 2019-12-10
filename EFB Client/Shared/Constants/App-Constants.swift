
import Foundation
import Alamofire
import UIKit
import Toast_Swift
import CoreData
import QuartzCore
import Firebase

class App_Constants:NSObject{
    
    public static let Instance = App_Constants()
    public static let UI = UI_Constants()
    
    private var _Token:String = ""
    public var _BGSessionCompletion:(()->Void)?
    
    public func _Initialize(){
        self._Token = Token_Return()
        self.RegisterForNotification()
        self.Reachability()
        SettingBundleManager.shared.settingInit()
    }
    
    //MARK: - Network Reachability
    func Reachability(){
        autoreleasepool{
            let reachability = NetworkReachabilityManager()
            reachability?.listener = {_ in
                if (reachability?.isReachable ?? false){
                    Sync.syncUser({r,m in })
                }else{
                    App_Constants.UI.Make_Alert("", App_Constants.Instance.Text(.no_connection))
                }
            }
            reachability?.startListening()
        }
    }
    
    func isReachable()->Bool{
        return NetworkReachabilityManager()?.isReachable ?? false
    }
    
    //MARK: - Token
    func Account_Check() -> Bool {
        return !Token_Return().isEmpty
    }
    
    func Token_Return()->String{
        return self.SettingsLoad(.Token) as? String ?? ""
    }
    
    //MARK: - Notification
    func RegisterForNotification(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge,.alert,.sound], completionHandler: {_,_ in })
        UIApplication.shared.registerForRemoteNotifications()
        
    }
    
    //MARK: - Alamofire
    func CancelRequest(){
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler({(sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach { $0.cancel() }
            uploadData.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
        })
    }
    
    func cancelRequest(with URL: URL){
        Alamofire.SessionManager.default.session.downloadTask(with: URL).cancel()
    }
    
    //MARK: - Save User
    func SaveUser(_ user: EFBUser){
        self.SaveToCore(user, .user)
    }
    
    func LoadUser()->EFBUser?{
        return self.LoadFromCore(.user)
    }
    
    func RemoveAllRecords(){
        SettingsRemove(.Token)
        SettingsRemove(.FCMToken)
        SettingsRemove(.IsFirstStart)
        SettingsRemove(.UserId)
        SettingsRemove(.UserInfo)
        SettingsRemove(.legal_time)
        ClearEntity(.manual)
        ClearEntity(.message)
        ClearEntity(.notification)
        ClearEntity(.organization)
        ClearEntity(.user)
        FilesManager.default.clearAll(Constants.kManualDirectory)
        _Token = self.Token_Return()
    }
    
    //MARK: - Settings
    func SettingsSave(_ key: SettingsApp, _ value: Any) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    func SettingsLoad(_ key: SettingsApp) -> Any? {
        return UserDefaults.standard.value(forKey: key.rawValue)
        
    }
    func SettingsRemove(_ key: SettingsApp) {
            UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
    
    //MARK: - Images
    func Image(_ name: Images)->UIImage{
        return UIImage(named: name.rawValue)!
    }
    //MARK: - Cell Names
    func Cell(_ name: Cell)->String{
        return name.rawValue
    }
    //MARK: - color
    func Color(_ name: Color)->UIColor{
        return UIColor.init(hexString:name.rawValue)
    }
    //MARK: - Notifications Name
    func Notification_Name(_ name: Notification_Name)->NSNotification.Name{
        return NSNotification.Name.init(name.rawValue)
    }
    // MARK: - Font
    func Font(_ type: FontType, _ size: CGFloat)-> UIFont {
        return UIFont.init(name: type.rawValue, size: size)!
    }
    
    // MARK: - Localized String
    func Text(_ text: Text)->String{
        return NSLocalizedString(text.rawValue, comment: "")
    }
    //MARK: - CoreData
    func SaveToCore<T:Codable>(_ data:T, _ entity: EntityName){
        autoreleasepool{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let Entity = NSEntityDescription.entity(forEntityName: entity.rawValue, in: context)
            let new = NSManagedObject(entity: Entity!, insertInto: context)
            let mirror = Mirror.init(reflecting: data).children
            for k in mirror{
                if k.label!.count < 4{
                    new.setValue(k.value, forKey: k.label?.lowercased() ?? "")
                }else{
                    if type(of: k.value) == String?.self{
                        let value = k.value as? String ?? ""
                        new.setValue(value, forKey: k.label ?? "")
                    }else if type(of: k.value) == Bool?.self{
                        let value = k.value as? Bool ?? nil
                        new.setValue(value, forKey: k.label ?? "")
                    }else if type(of: k.value) == Int?.self{
                        let value = k.value as? Int ?? nil
                        new.setValue(value, forKey: k.label ?? "")
                    }else{
                        new.setValue(k.value, forKey: k.label ?? "")
                    }
                }
            }
            do{
                try context.save()
            }catch{
                print("failed")
            }
        }
    }
    
    func SaveArrayToCore<T:Codable>(_ data:[T], _ entity: EntityName){
        self.ClearEntity(entity)
        for d in data{
            self.SaveToCore(d, entity)
        }
    }
    
    func LoadFromCore<T:Codable>(_ entity: EntityName)-> T?{
        return autoreleasepool{()->T? in
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity.rawValue)
            request.returnsObjectsAsFaults = false
            do{
                let result = try (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext.fetch(request)
                do{
                    if JSONSerialization.isValidJSONObject(result.last!){
                        let json = try JSONSerialization.data(withJSONObject: result.last!, options: .prettyPrinted)
                        return try JSONDecoder().decode(T.self, from: json)
                    }else{
                        let json = convertToJSONArray(moArray: result as! [NSManagedObject])
                        return try JSONDecoder().decode(T.self, from: try! JSONSerialization.data(withJSONObject: json.last!, options: .prettyPrinted))
                    }
                }catch (let err){
                    print(err.localizedDescription)
                    return nil
                }
            }catch{
                return nil
            }
        }
    }
    
    func LoadAllFormCore<T:Codable>(_ entity:EntityName)->[T]?{
        return autoreleasepool{()->[T]? in
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity.rawValue)
            request.returnsObjectsAsFaults = false
            do{
                let result = try (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext.fetch(request)
                let json = convertToJSONArray(moArray: result as! [NSManagedObject])
                let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                let r = try JSONDecoder().decode([T].self, from: jsonData)
                return r
            }catch(let err){
                print(err.localizedDescription)
                return nil
            }
        }
    }
    
    func convertToJSONArray(moArray: [NSManagedObject]) -> [[String: Any]] {
        return autoreleasepool{()->[[String:Any]] in
            var jsonArray: [[String: Any]] = []
            for item in moArray {
                var dict: [String: Any] = [:]
                for attribute in item.entity.attributesByName {
                    //check if value is present, then add key to dictionary so as to avoid the nil value crash
                    if let value = item.value(forKey: attribute.key) {
                        if attribute.key.count < 4{
                            dict[attribute.key.uppercased()] = value
                        }else{
                            
                            dict[attribute.key] = value
                            if type(of: value) == NSNumber.self{
                                let value1 = Bool.init(exactly: value as! NSNumber)
                                dict[attribute.key] = value1
                            }
                        }
                    }
                }
                
                jsonArray.append(dict)
            }
            return jsonArray
        }
    }
    
    func UpdateEntity<T:Equatable>(_ entity: EntityName, _ oldValue: T, _ newValue: Any, _ key: String, _ equatableKey: String,_ equatableValue: Int){
        autoreleasepool{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: entity.rawValue)
            do{
                let test:[NSManagedObject] = try context.fetch(fetchRequest) as! [NSManagedObject]
                let object = test.first(where: {$0.value(forKey: equatableKey) as! Int == equatableValue})
                object?.setValue(newValue, forKey: key)
                do{
                    try context.save()
                }catch(let err){
                    print(err.localizedDescription)
                }
            }catch(let err){
                print(err.localizedDescription)
            }
        }
    }
    
    func ClearEntity(_ entity: EntityName){
        autoreleasepool{
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.rawValue)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try context.execute(batchDeleteRequest)
            } catch (let err){
                print(err.localizedDescription)
            }
        }
    }
    
}

class UI_Constants:NSObject{
    
    func performSegue(_ ct: UIViewController, _ segueId: SegueId){
        DispatchQueue.main.async{
            ct.performSegue(withIdentifier: segueId.rawValue, sender: ct)
        }
    }
    
    public func Make_Toast(on view: UIView? = UIApplication.shared.keyWindow,with title: String, in duration: Double = 2.5, in position: ToastPosition = .top){
        autoreleasepool{
            var style = ToastStyle()
            style.messageColor = App_Constants.Instance.Color(.light)
            style.messageFont = App_Constants.Instance.Font(.medium,14)
            style.backgroundColor = UIColor.white.withAlphaComponent(0.8)
            style.fadeDuration = 0.5
            style.messageAlignment = .center
            style.messageNumberOfLines = 3
            ToastManager.shared.style = style
            ToastManager.shared.isTapToDismissEnabled = true
            ToastManager.shared.isQueueEnabled = true
            ToastManager.shared.duration = duration
            view?.makeToast(title, duration: duration, position: position , title: nil, image: nil, style: style, completion: nil)
        }
    }
    
    public func Make_Alert(_ title: String, _ message: String,_ doneButton: (()->Void)? = {}){
        AlertView.init(title: title, message: message, done: doneButton).show()
    }
    
    func RemoveChildView(_ controller:[UIViewController]){
        for i in controller {
            i.willMove(toParent: nil)
            i.view.removeFromSuperview()
            i.removeFromParent()
        }
    }
    
    func AddChildView(mother: UIViewController, _ view: UIView, _ controller:UIViewController){
        mother.addChild(controller)
        view.addSubview(controller.view)
        controller.view.frame = view.bounds
        controller.didMove(toParent: mother)
    }
    
    func _Rotate(_ view: UIView){
        autoreleasepool{
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotateAnimation.fromValue = 0.0
            rotateAnimation.toValue = CGFloat(.pi * 2.0)
            rotateAnimation.duration = 1
            rotateAnimation.repeatCount = .greatestFiniteMagnitude
            view.layer.add(rotateAnimation, forKey: nil)
        }
    }
    
    func _StopRotate(_ view:UIView){
        view.layer.removeAllAnimations()
    }
    
}

class Constants{
    
    public static let kManualDirectory = "Manuals"
    public static let kOldManualDirectory = "Olds"
    public static let kBgSessionId = "bd_dl"
    public static let kEmailNotVerified = 2
    
}

class NotificationManager{
    public static var data:[AnyHashable : Any] = [:]
}
