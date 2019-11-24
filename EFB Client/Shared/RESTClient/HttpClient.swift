//
//  HttpClient.swift
//  EFB Client
//
//  Created by Mr.Zee on 10/13/19.
//  Copyright © 2019 MehrPardaz. All rights reserved.
//

import Foundation
import Alamofire

class HttpClient:NSObject{
    
    public static let `default` = HttpClient()
    public var _Default_Headers:Dictionary<String,String> = ["Content-Type":"application/json"]
    private var _HttpMethod_Post = "POST"
    private var _HttpMethod_Get = "GET"
    private var _HttpMethod_Put = "PUT"
    private var _HttpMethod_Delete = "DELETE"
    
    convenience init(_ hasToken: Bool){
        self.init()
        if hasToken{
            self._Default_Headers = ["Content-Type":"application/json","Authorization":"Bearer \(App_Constants.Instance.Token_Return())"]
        }
    }
    
    public static func http()->HttpClient{
        return HttpClient.init(true)
    }
    
    public func _Post<T:Codable,Y:Codable>(relativeUrl:String,body:T,callback: @escaping (Bool,String,Y?)->Void){
        autoreleasepool{
            var result:Global<Y>?
            let params = try! JSONEncoder().encode(body)
            var request = URLRequest(url: URL(string:Api_Names.main + relativeUrl)!)
            request.httpMethod = _HttpMethod_Post
            request.allHTTPHeaderFields = _Default_Headers
            request.httpBody = params
            request.timeoutInterval = 120
            Alamofire.request(request).validate(statusCode: 200..<300).responseJSON(completionHandler: {response in
                switch response.result{
                case .success:
                    do{
                        result = try JSONDecoder().decode(Global<Y>.self, from: response.data!)
                        callback(true,"",result?.data)
                    }catch (let err){
                        print(err)
                        callback(false,App_Constants.Instance.Text(.try_again),nil)
                    }
                case .failure:
                    callback(false,App_Constants.Instance.Text(.try_again),nil)
                    if(response.response?.statusCode == 401) {
                        App_Constants.Instance.RemoveAllRecords()
                        let AppRunViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "splash") as! UINavigationController
                        UIApplication.shared.keyWindow?.rootViewController = AppRunViewController
                    }
                }
            })
        }
    }
    
    public func _PostHeader<T:Codable>(relativeUrl:String,body:T,callback: @escaping (Bool,String,String?)->Void){
        autoreleasepool{
            let params = try! JSONEncoder().encode(body)
            var request = URLRequest(url: URL(string:Api_Names.main + relativeUrl)!)
            request.httpMethod = _HttpMethod_Post
            request.allHTTPHeaderFields = _Default_Headers
            request.httpBody = params
            request.timeoutInterval = 120
            Alamofire.request(request).validate(statusCode: 200..<300).responseJSON(completionHandler: {response in
                switch response.result{
                case .success:
                    callback(true,"",response.response?.allHeaderFields["Authorization"] as? String ?? "")
                case .failure:
                    callback(false,App_Constants.Instance.Text(.try_again),nil)
                    if(response.response?.statusCode == 401) {
                        App_Constants.Instance.RemoveAllRecords()
                        let AppRunViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "splash") as! UINavigationController
                        UIApplication.shared.keyWindow?.rootViewController = AppRunViewController
                    }
                }
            })
        }
    }
    
    public func _PostArray<T:Codable,Y:Codable>(relativeUrl:String,body:T,callback: @escaping (Bool,String,[Y]?)->Void){
        autoreleasepool{
            var result:[Y]?
            let params = try! JSONEncoder().encode(body)
            var request = URLRequest(url: URL(string: Api_Names.main + relativeUrl)!)
            request.httpMethod = _HttpMethod_Post
            request.allHTTPHeaderFields = _Default_Headers
            request.httpBody = params
            request.timeoutInterval = 120
            Alamofire.request(request).validate(statusCode: 200..<300).responseJSON(completionHandler: {response in
                switch response.result{
                case .success:
                    do{
                        result = try JSONDecoder().decode([Y].self, from: response.data!)
                        
                        callback(true,"",result)
                        
                    }catch (let err){
                        print(err)
                        callback(false,String(describing: err),nil)
                    }
                case .failure:
                    callback(false,App_Constants.Instance.Text(.try_again),nil)
                    if(response.response?.statusCode == 401) {
                        App_Constants.Instance.RemoveAllRecords()
                        let AppRunViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "splash") as! UINavigationController
                        UIApplication.shared.keyWindow?.rootViewController = AppRunViewController
                    }
                }
            })
        }
    }
    
    public func _PostArray<T:Codable,Y:Codable>(relativeUrl:String,body:T,callback: @escaping (Bool,String,Y?)->Void){
        autoreleasepool{
            var result:Y?
            let params = try! JSONEncoder().encode(body)
            var request = URLRequest(url: URL(string: Api_Names.main + relativeUrl)!)
            request.httpMethod = _HttpMethod_Post
            request.allHTTPHeaderFields = _Default_Headers
            request.httpBody = params
            
            Alamofire.request(request).validate(statusCode: 200..<300).responseJSON(completionHandler: {response in
                switch response.result{
                case .success:
                    do{
                        result = try JSONDecoder().decode(Y.self, from: response.data!)
                        
                        callback(true,"",result)
                    }catch (let err){
                        print(err)
                        callback(false,String(describing: err),nil)
                    }
                case .failure:
                    callback(false,App_Constants.Instance.Text(.try_again),nil)
                    if(response.response?.statusCode == 401) {
                        App_Constants.Instance.RemoveAllRecords()
                        let AppRunViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "splash") as! UINavigationController
                        UIApplication.shared.keyWindow?.rootViewController = AppRunViewController
                    }
                }
            })
        }
    }
    
    public func _Put<T:Codable,Y:Codable>(relativeUrl:String,body:T,callback:@escaping(Bool,String,Y?)-> Void){
        autoreleasepool{
            var result:Y?
            let params = try! JSONEncoder().encode(body)
            var request = URLRequest(url: URL(string: Api_Names.main + relativeUrl)!)
            request.httpMethod = _HttpMethod_Put
            request.allHTTPHeaderFields = _Default_Headers
            request.httpBody = params
            Alamofire.request(request).validate(statusCode: 200..<300).responseJSON(completionHandler: {response in
                switch response.result{
                case .success:
                    do{
                        result = try JSONDecoder().decode(Y.self, from: response.data!)
                        
                        callback(true,"",result)
                    }catch (let err){
                        print(err)
                        callback(false,String(describing: err),nil)
                    }
                case .failure:
                    callback(false,App_Constants.Instance.Text(.try_again),nil)
                    if(response.response?.statusCode == 401) {
                        App_Constants.Instance.RemoveAllRecords()
                        let AppRunViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "splash") as! UINavigationController
                        UIApplication.shared.keyWindow?.rootViewController = AppRunViewController
                    }
                }
            })
        }
    }
    
    public func _GetHeader(relativeUrl:String,callback:@escaping (Bool,String,String?)->Void){
        Alamofire.request(Api_Names.main + relativeUrl,method: .get, encoding: JSONEncoding.default,headers: _Default_Headers).validate(statusCode: 200..<300).responseJSON(completionHandler: {response in
            switch response.result{
            case .success:
                callback(true,"",response.response?.allHeaderFields["Authorization"] as? String ?? "")
            case .failure:
                if response.response == nil{
                    callback(false,App_Constants.Instance.Text(.time_out),nil)
                }else{
                    callback(false,App_Constants.Instance.Text(.try_again),nil)
                }
                if(response.response?.statusCode == 401) {
                    App_Constants.Instance.RemoveAllRecords()
                    let AppRunViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "splash") as! UINavigationController
                    UIApplication.shared.keyWindow?.rootViewController = AppRunViewController
                }
                
            }
        })
    }
    
    public func _Get<T:Codable>(relativeUrl:String,callback:@escaping (Bool,String,T?)->Void){
        autoreleasepool{
            var result:Global<T>!
            Alamofire.request(Api_Names.main + relativeUrl,method: .get, encoding: JSONEncoding.default,headers: _Default_Headers).validate(statusCode: 200..<300).responseJSON(completionHandler: {response in
                switch response.result{
                case .success:
                    do{
                        result = try JSONDecoder().decode(Global<T>.self, from: response.data!)
                        callback(true,"",result.data)
                    }catch (let err){
                        callback(false,String(describing:err),nil)
                    }
                    
                case .failure:
                    if response.response == nil{
                        callback(false,App_Constants.Instance.Text(.time_out),nil)
                    }else{
                        callback(false,App_Constants.Instance.Text(.try_again),nil)
                    }
                    if(response.response?.statusCode == 401) {
                        App_Constants.Instance.RemoveAllRecords()
                        let AppRunViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "splash") as! UINavigationController
                        UIApplication.shared.keyWindow?.rootViewController = AppRunViewController
                    }
                    
                }
            })
        }
    }
    
    public func _GetArray<T:Codable>(relativeUrl:String,callback:@escaping (Bool,String,[T]?)->Void){
        autoreleasepool{
            var result:GlobalArray<T>!
            Alamofire.request(Api_Names.main + relativeUrl,method: .get ,encoding: JSONEncoding.default,headers: _Default_Headers).validate(statusCode: 200..<300).responseJSON(completionHandler: {response in
                switch response.result{
                case .success:
                    do{
                        result = try JSONDecoder().decode(GlobalArray<T>.self, from: response.data!)
                        callback(true,"",result.data)
                    }catch (let err){
                        callback(false,String(describing:err),nil)
                    }
                    
                case .failure:
                    callback(false,App_Constants.Instance.Text(.try_again),nil)
                    if(response.response?.statusCode == 401) {
                        App_Constants.Instance.RemoveAllRecords()
                        let AppRunViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "splash") as! UINavigationController
                        UIApplication.shared.keyWindow?.rootViewController = AppRunViewController
                    }
                }
            })
        }
    }
    
    public func _Delete<T:Codable>(relativeUrl:String,callback:@escaping (Bool,String,T?)->Void){
        
        var result:T!
        Alamofire.request(Api_Names.main + relativeUrl,method: .delete,headers: _Default_Headers).validate(statusCode: 200..<300).responseJSON(completionHandler: {response in
            switch response.result{
            case .success:
                result = try? JSONDecoder().decode(T.self, from: response.data!)
                callback(true,"",result)
            case .failure:
                callback(false,App_Constants.Instance.Text(.try_again),nil)
                if(response.response?.statusCode == 401) {
                    App_Constants.Instance.RemoveAllRecords()
                    let AppRunViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "splash") as! UINavigationController
                    UIApplication.shared.keyWindow?.rootViewController = AppRunViewController
                }
                
            }
        })
        
    }
    
    public func _Delete(relativeUrl:String,callback:@escaping (Bool,String,Bool)->Void){
        
        var result:Bool!
        Alamofire.request(Api_Names.main + relativeUrl,method: .delete,headers: _Default_Headers).validate(statusCode: 200..<300).responseJSON(completionHandler: {response in
            switch response.result{
            case .success:
                do{
                    result = try JSONDecoder().decode(Bool.self, from: response.data!)
                    callback(true,"",result)
                }catch(let err){
                    debugPrint(err)
                    callback(false,String(describing:err),false)
                }
            case .failure:
                callback(false,App_Constants.Instance.Text(.try_again),false)
                if(response.response?.statusCode == 401) {
                    App_Constants.Instance.RemoveAllRecords()
                    let AppRunViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "splash") as! UINavigationController
                    UIApplication.shared.keyWindow?.rootViewController = AppRunViewController
                }
            }
        })
    }
    
    public func _Delete1<T:Codable>(relativeUrl:String,callback:@escaping (Bool,String,T?)->Void){
        
        var result:T!
        Alamofire.request(Api_Names.main + relativeUrl,method: .delete,headers: _Default_Headers).validate(statusCode: 200..<300).responseJSON(completionHandler: {response in
            switch response.result{
            case .success:
                do{
                    result = try JSONDecoder().decode(T.self, from: response.data!)
                    
                    callback(true,"",result)
                    
                }catch(let err){
                    debugPrint(err)
                    callback(false,String(describing:err),nil)
                }
            case .failure:
                callback(false,App_Constants.Instance.Text(.try_again),nil)
                if(response.response?.statusCode == 401) {
                    App_Constants.Instance.RemoveAllRecords()
                    let AppRunViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "splash") as! UINavigationController
                    UIApplication.shared.keyWindow?.rootViewController = AppRunViewController
                }
            }
        })
    }
    
    public func _DeleteBody<T:Codable,Y:Codable>(relativeUrl:String,body:[T],callback:@escaping (Bool,String,[Y]?)->Void){
        var result:[Y]!
        let url = URL(string: Api_Names.main + relativeUrl)!
        var request = URLRequest.init(url: url)
        request.httpBody = try! JSONEncoder().encode(body)
        request.httpMethod = _HttpMethod_Delete
        request.allHTTPHeaderFields = _Default_Headers
        Alamofire.request(request).validate(statusCode: 200..<300).responseJSON(completionHandler: {response in
            switch response.result{
            case .success:
                result = try! JSONDecoder().decode([Y].self, from: response.data!)
                
                callback(true,"",result)
            case .failure:
                callback(false,App_Constants.Instance.Text(.try_again),nil)
                if(response.response?.statusCode == 401) {
                    App_Constants.Instance.RemoveAllRecords()
                    let AppRunViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "splash") as! UINavigationController
                    UIApplication.shared.keyWindow?.rootViewController = AppRunViewController
                }
            }
        })
    }
    
    public func _DeleteBody<T:Codable,Y:Codable>(relativeUrl:String,body:T,callback:@escaping (Bool,String,Y?)->Void){
        var result:Y!
        let url = URL(string: Api_Names.main + relativeUrl)!
        var request = URLRequest.init(url: url)
        request.httpBody = try! JSONEncoder().encode(body)
        request.httpMethod = _HttpMethod_Delete
        request.allHTTPHeaderFields = _Default_Headers
        Alamofire.request(request).validate(statusCode: 200..<300).responseJSON(completionHandler: {response in
            switch response.result{
            case .success:
                result = try! JSONDecoder().decode(Y.self, from: response.data!)
                
                callback(true,"",result)
            case .failure:
                callback(false,App_Constants.Instance.Text(.try_again),nil)
                if(response.response?.statusCode == 401) {
                    App_Constants.Instance.RemoveAllRecords()
                    let AppRunViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "splash") as! UINavigationController
                    UIApplication.shared.keyWindow?.rootViewController = AppRunViewController
                }
            }
        })
    }
    
    public func _Download(relativeUrl: String, to: DownloadRequest.DownloadFileDestination?, process:((Progress)->Void)? = nil, callback: @escaping (Bool,String)->Void){
        autoreleasepool{
            let url = URL(string: Api_Names.Main + relativeUrl)!
            Alamofire.download(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: self._Default_Headers, to: to).downloadProgress(closure: {progress in
                process?(progress)
            }).validate(statusCode: 200..<300).responseString(completionHandler: {response in
                switch response.result{
                case .success:
                    callback(true,"")
                case .failure:
                    callback(false,App_Constants.Instance.Text(.try_again))
                    if(response.response?.statusCode == 401) {
                        App_Constants.Instance.RemoveAllRecords()
                        let AppRunViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "splash") as! UINavigationController
                        UIApplication.shared.keyWindow?.rootViewController = AppRunViewController
                    }
                }
            })
        }
    }
    
}