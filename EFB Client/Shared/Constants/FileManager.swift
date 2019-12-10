

import Foundation

class FilesManager:NSObject{
    static let `default` = FilesManager()
    
    private let manager = FileManager.default
    
    public func path(_ name: String)->URL?{
        return manager.urls(for: .libraryDirectory, in: .userDomainMask).first?.appendingPathComponent(Constants.kManualDirectory).appendingPathComponent(name)
    }
    
    public func getFilesInDirectory(_ name: String)->[String]?{
        return autoreleasepool{()->[String]? in
            let path = manager.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent(name)
            if manager.fileExists(atPath: path.path){
                return try? manager.contentsOfDirectory(atPath: path.path)
            }else{
                createDirectory(Constants.kManualDirectory)
                return try? manager.contentsOfDirectory(atPath: path.path)
            }
        }
    }
    
    public func clearAll(_ name: String){
        autoreleasepool{
            let path = manager.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent(name)
            let content = try? manager.contentsOfDirectory(atPath: path.path)
            for p in content ?? [] {
                let fullPath = path.appendingPathComponent(p)
                try? manager.removeItem(at: fullPath)
            }
        }
    }
    
    public func deleteManual(_ dName: String, _ mName: String){
        autoreleasepool{
            let path = manager.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent(dName)
            try? manager.removeItem(at: path.appendingPathComponent(mName))
        }
    }
    
    public func createDirectory(_ name: String){
        autoreleasepool{
            let path = manager.urls(for: .libraryDirectory, in: .userDomainMask).first?.appendingPathComponent("\(name)")
            if !manager.fileExists(atPath: path!.path){
                try? manager.createDirectory(atPath: path!.path, withIntermediateDirectories: true, attributes: nil)
            }
        }
    }
    
    public func get_manuals(at path: String)->[Manual]{
        let files = self.getFilesInDirectory(path)
        var manuals:[Manual] = []
        for file in files ?? []{
            if !self.isDirectory(file){
                manuals.append(Manual(manual_id: nil, manual_description: file.components(separatedBy: "_")[3].components(separatedBy: ".")[0], manual_file_name: nil, manual_version: file.components(separatedBy: "_")[0], upload_date: file.components(separatedBy: "_")[2], manual_title: file.components(separatedBy: "_")[1], aircraft_type: nil, manual_category: (path == Constants.kManualDirectory ? nil:path.components(separatedBy: "/")[1]), manual_status: nil, is_folder: false))
            }else{
                manuals.append(Manual(manual_id: nil, manual_description: "", manual_file_name: "", manual_version: "", upload_date: "", manual_title: file.components(separatedBy: ".")[0], aircraft_type: "", manual_category: "", manual_status: "", is_folder: true))
            }
        }
        return manuals
    }
    
    public func getAllManuals(_ path: String)->[Manual]{
        let files = self.getFilesInDirectory(path)
        var manuals:[Manual] = []
        for file in files ?? []{
            if !self.isDirectory(file){
                manuals.append(Manual(manual_id: nil, manual_description: file.components(separatedBy: "_")[3].components(separatedBy: ".")[0], manual_file_name: nil, manual_version: file.components(separatedBy: "_")[0], upload_date: file.components(separatedBy: "_")[2], manual_title: file.components(separatedBy: "_")[1], aircraft_type: nil, manual_category: (path == Constants.kManualDirectory ? nil:path.components(separatedBy: "/")[1]), manual_status: nil, is_folder: false))
            }else{
                manuals.append(Manual(manual_id: nil, manual_description: "", manual_file_name: "", manual_version: "", upload_date: "", manual_title: file.components(separatedBy: ".")[0], aircraft_type: "", manual_category: "", manual_status: "", is_folder: true))
                manuals.append(contentsOf: self.getAllManuals("\(path)/\(file.components(separatedBy: ".")[0])"))
            }
        }
        return manuals
    }
    
    public func isDirectory(_ path: String)->Bool{
        let comp = path.components(separatedBy: ".")
        if comp.count > 1{
            return false
        }
        return true
    }
    
    public func isDirectory(_ path: URL)->Bool{
        let comp = path.absoluteString.components(separatedBy: ".")
        if comp.count > 1{
            return false
        }
        return true
    }
    
}
