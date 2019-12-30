

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
    var speed:Speed_Model = Speed_Model.init(speed: 0, prevDownloadedBytes: 0, totalDownloadBytes: 0, bytesWritten: 0, totalBytesWritten: 0, totalBytesExpectedToWrite: 0, T: nil)
    var progress:Float = 0
}

struct Speed_Model{
    var speed:Int = 0
    var prevDownloadedBytes:Int = 0
    var totalDownloadBytes:Int = 0
    var bytesWritten:Int64 = 0
    var totalBytesWritten:Int64 = 0
    var totalBytesExpectedToWrite:Int64 = 0
    weak var T:Timer!
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
            download.speed.T = Timer.scheduledTimer(withTimeInterval: kTimeConstant, repeats: true, block: {_ in
                download.speed.speed = ((download.speed.totalDownloadBytes) - (download.speed.prevDownloadedBytes)) / Int(kTimeConstant)
                download.speed.prevDownloadedBytes = download.speed.totalDownloadBytes
            })
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
                if download.speed.T != nil{
                    download.speed.T.invalidate()
                    download.speed.T = nil
                }
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
                if download.speed.T != nil {
                    download.speed.T.invalidate()
                    download.speed.T = nil
                }
            }
        }
    }
    
    func resumeDownload(_ track: Manual,_ relUrl:String) {
        autoreleasepool{
            guard let download = activeDownloads[URL(string:Api_Names.Main + relUrl)!] else{return}
            if let resumeData = download.resumeData{
                download.task = downloadsSession.downloadTask(withResumeData: resumeData)
            }
            download.task!.resume()
            download.isDownloading = true
            download.resumeData = nil
            download.speed.T = Timer.scheduledTimer(withTimeInterval: kTimeConstant, repeats: true, block: {_ in
                download.speed.speed = ((download.speed.totalDownloadBytes) - (download.speed.prevDownloadedBytes)) / Int(kTimeConstant)
                download.speed.prevDownloadedBytes = download.speed.totalDownloadBytes
            })
        }
    }
    
}

class Download_Manager:NSObject{
    
    public static let `default` = Download_Manager()
    
    let downloadService = DownloadService_New()
    var didFinishishDownload:((URLSession,URLSessionDownloadTask,URL,Bool)->Void)?
    var didWriteData:((URLSession,URLSessionDownloadTask,Int64,Int64,Int64)->Void)?
    
    public func startDownload(_ Manual:Manual, _ relUrl:String){
        self.downloadService.activeDownloads[URL(string:Api_Names.Main + relUrl)!] = self.downloadService.startDownload(Manual, relUrl)
    }
    
    public func cancelDownload(_ Manual:Manual, _ relUrl:String){
        downloadService.cancelDownload(Manual, relUrl)
        self.downloadService.activeDownloads[URL(string:Api_Names.Main + relUrl)!] = nil
    }
    
    public func pauseDownload(_ Manual: Manual, _ relUrl: String){
        downloadService.pauseDownload(Manual, relUrl)
    }
    
    public func resumeDownload(_ manual: Manual, _ relUrl: String){
        downloadService.resumeDownload(manual, relUrl)
    }
    
}

extension Download_Manager:URLSessionDownloadDelegate{
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        autoreleasepool{
            do{
                let manual = downloadService.activeDownloads[(downloadTask.originalRequest?.url)!]?.manual
                FilesManager.default.createDirectory("\(Constants.kManualDirectory)/\((manual?.manual_category ?? ""))")
                let to = FilesManager.default.path("\(manual?.manual_category ?? "")/\(manual?.manual_version ?? "")_\(manual?.manual_title ?? "")_\(manual?.upload_date ?? "")_\(manual?.manual_description ?? "").pdf")!
                let status = (downloadTask.response as? HTTPURLResponse)?.statusCode
                if FileManager.default.fileExists(atPath: to.path){
                    let _ = try FileManager.default.replaceItemAt(location, withItemAt: to)
                }else{
                    try FileManager.default.moveItem(at: location, to: to)
                }
                didFinishishDownload?(session,downloadTask,location, status == 200 || status == 206)
                if status == 200 || status == 206{
                    let download = self.downloadService.activeDownloads[(downloadTask.originalRequest?.url)!]
                    if download?.speed.T != nil{
                        download?.speed.T.invalidate()
                        download?.speed.T = nil
                    }
                    self.downloadService.activeDownloads[(downloadTask.originalRequest?.url)!] = nil
                }
            }catch(let err){
                print(err.localizedDescription)
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        print("did resume")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let download = downloadService.activeDownloads[(task.originalRequest?.url)!]
        if download?.speed.T != nil {
            download?.speed.T.invalidate()
            download?.speed.T = nil
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let download = downloadService.activeDownloads[(downloadTask.originalRequest?.url)!]
        download?.speed.totalDownloadBytes = Int(totalBytesWritten)
        download?.speed.bytesWritten = bytesWritten
        download?.speed.totalBytesWritten = totalBytesWritten
        download?.speed.totalBytesExpectedToWrite = totalBytesExpectedToWrite
        didWriteData?(session,downloadTask,bytesWritten,totalBytesWritten,totalBytesExpectedToWrite)
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
