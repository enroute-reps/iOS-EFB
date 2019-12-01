//
//  DownloadManager_New.swift
//  Axbox
//
//  Created by Mr.Zee on 12/11/18.
//  Copyright © 2018 Axbox. All rights reserved.
//

import Foundation
import UIKit

class Download_Model{
    var manual:Manual
    init(manual: Manual){
        self.manual = manual
    }
    
    var task:URLSessionDownloadTask?
    var isDownloading = false
    var resumeData:Data?
    
    var progress:Float = 0
}

let kTimeConstant:Double = 1

class DownloadService_New {
    
    var downloadsSession: URLSession!
    var activeDownloads:[URL:Download_Model] = [:]
    
    func startDownload(_ manual: Manual,_ relUrl:String) ->Download_Model{
        return autoreleasepool{()-> Download_Model in
            let download = Download_Model(manual: manual)
            
            download.task = downloadsSession.downloadTask(with:URL(string:Api_Names.Main + relUrl)!)
            download.task!.resume()
            download.isDownloading = true
            return download
        }
    }
    
    func pauseDownload(_ track: Manual,_ relUrl:String) {
        autoreleasepool{
            guard let download = activeDownloads[URL(string:Api_Names.Main + relUrl)!] else{return}
            if download.isDownloading{
                download.task?.cancel(byProducingResumeData: {data in
                    download.resumeData = data
                })
                download.isDownloading = false
            }
        }
    }
    
    func cancelDownload(_ track:Manual,_ relUrl:String){
        autoreleasepool{
            if let download = activeDownloads[URL(string:Api_Names.Main + relUrl)!] {
                download.task?.cancel()
                download.task?.suspend()
                download.task = nil
                download.isDownloading = false
            }
        }
    }
    
    func resumeDownload(_ track: Manual,_ relUrl:String) {
        autoreleasepool{
            guard let download = activeDownloads[URL(string:Api_Names.Main + relUrl)!] else{return}
            if let resumeData = download.resumeData{
                download.task = downloadsSession.downloadTask(withResumeData: resumeData)
            }else{
                download.task = downloadsSession.downloadTask(with: URL(string:Api_Names.Main + relUrl)!)
            }
            download.task!.resume()
            download.isDownloading = true
            download.resumeData = nil
        }
    }
    
}

class Download_Manager:NSObject{
    
    public static let `default` = Download_Manager()
    
    let downloadService = DownloadService_New()
    var didFinishishDownload:((URLSession,URLSessionDownloadTask,URL,Bool)->Void)?
    var didWriteData:((URLSession,URLSessionDownloadTask,Int64,Int64,Int64,Int)->Void)?
    private weak var T:Timer!
    private var speed:Int = 0
    private var prevDownloadedBytes:Int = 0
    private var totalDownloadedBytes:Int = 0
    
    public func startDownload(_ Manual:Manual, _ relUrl:String){
        self.downloadService.activeDownloads[URL(string:Api_Names.Main + relUrl)!] = self.downloadService.startDownload(Manual, relUrl)
        T = Timer.scheduledTimer(withTimeInterval: kTimeConstant, repeats: true, block: {_ in
            self.speed = (self.totalDownloadedBytes - self.prevDownloadedBytes) / Int(kTimeConstant)
            self.prevDownloadedBytes = self.totalDownloadedBytes
        })
    }
    
    public func cancelDownload(_ Manual:Manual, _ relUrl:String){
        downloadService.cancelDownload(Manual, relUrl)
        self.downloadService.activeDownloads[URL(string:Api_Names.Main + relUrl)!] = nil
    }
    
    private func _CloseTimer(){
        if T != nil {
            T.invalidate()
            T = nil
        }
    }
}

extension Download_Manager:URLSessionDownloadDelegate{
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        autoreleasepool{
            do{
                let manual = downloadService.activeDownloads[(downloadTask.originalRequest?.url)!]?.manual
                FilesManager.default.createDirectory("\(Constants.kManualDirectory)/\((manual?.manual_category ?? ""))")
                let to = FilesManager.default.path("\(manual?.manual_category ?? "")/\(manual?.manual_version ?? "")_\(manual?.manual_title ?? "")_\(manual?.upload_date ?? "")_\(manual?.manual_description ?? "").pdf")!
                if FileManager.default.fileExists(atPath: to.absoluteString){
                    let _ = try FileManager.default.replaceItemAt(location, withItemAt: to)
                }else{
                    try FileManager.default.moveItem(at: location, to: to)
                }
                didFinishishDownload?(session,downloadTask,location, (downloadTask.response as? HTTPURLResponse)?.statusCode == 200)
            }catch(let err){
                print(err.localizedDescription)
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        _CloseTimer()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        self.totalDownloadedBytes = Int(totalBytesWritten)
        didWriteData?(session,downloadTask,bytesWritten,totalBytesWritten,totalBytesExpectedToWrite,speed)
    }
    
    
}

extension Download_Manager:URLSessionDelegate{
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        autoreleasepool{
            DispatchQueue.main.async{
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let completionHandler = appDelegate.backgroundTaskCompletionHandler{
                    appDelegate.backgroundTaskCompletionHandler = nil
                    completionHandler()
                }
            }
        }
    }
}
