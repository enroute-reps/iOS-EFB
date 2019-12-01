//
//  LibraryListViewController.swift
//  EFB Client
//
//  Created by Mr.Zee on 10/23/19.
//  Copyright © 2019 MehrPardaz. All rights reserved.
//

import UIKit
import PDFKit

public enum ArrangeType{
    case grid,list
}

public enum SortType{
    case date,name
}

class LibraryListViewController: UIViewController {
    
    fileprivate enum ManualType{
        case downloads,files
    }
    
    fileprivate enum FileType{
        case file,folder
    }
    
    @IBOutlet weak var mCollectionView: UICollectionView!
    @IBOutlet weak var mSortButton: UIButton!
    @IBOutlet weak var mSortView: UIView!
    @IBOutlet weak var mGridButton: UIButton!
    @IBOutlet weak var mListButton: UIButton!
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var mManualTypeSegment: UISegmentedControl!
    @IBOutlet weak var mSortLabel: UILabel!
    @IBOutlet weak var mSampleSortButton: UIButton!
    @IBOutlet weak var mManualTypeSegmentView: UIView!
    @IBOutlet weak var mBackButton: UIButton!
    
    private var path:String = Constants.kManualDirectory
    private var _Manuals:[Manual] = []
    private var _Files:[Manual] = []
    private var _Downloads:[Manual] = []
    private var _SelectedIndex:IndexPath = [0,0]
    private var _HighlightIndex:Int = -1
    private var _Type:ManualType = .files
    private var _ArrangeType:ArrangeType = .grid
    private var _SortType:SortType = .name
    private var _FileManager = FilesManager.default
    private var _App_Constants = App_Constants.Instance
    private var _Download_Manager = Download_Manager.default
    private var kMain = "Main"
    private var kLibrary = "library"
    private var kManual = "manual"
    private var kPDFReader = "pdfViewer"
    private var kName = "Name"
    private var kDate = "Date"
    private var kIsHidden = "isHidden"
    private var kManualNotificationId = "manual"

    override func viewDidLoad() {
        super.viewDidLoad()
        _Initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        NotificationCenter.default.post(name: App_Constants.Instance.Notification_Name(.tabbar_height), object: nil, userInfo: [kIsHidden: false])
        NotificationCenter.default.post(name: App_Constants.Instance.Notification_Name(.hide_statusBar), object: nil, userInfo: [kIsHidden: false])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? PDFViewerViewController{
            switch _Type{
            case .files:
                dest._Manual = self._Files[self._SelectedIndex.row]
            case .downloads:
                break
            }
        }
    }
    
    @IBAction func _BackButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func _ManualTypeValueChanged(_ sender: Any) {
        switch mManualTypeSegment.selectedSegmentIndex{
        case 0:
            self._Type = .downloads
            self._HighlightIndex = -1
        case 1:
            self._Type = .files
            self._HighlightIndex = -1
        default:
            break
        }
        self.mTableView.reloadData()
        self.mCollectionView.reloadData()
    }
    
    @IBAction func _GridButtonTapped(_ sender: Any) {
        self._ArrangeType = .grid
        self.mGridButton.backgroundColor = App_Constants.Instance.Color(.selected)
        self.mListButton.backgroundColor = .clear
        self._HighlightIndex = -1
        self.mCollectionView.isHidden = _ArrangeType != .grid
    }
    
    @IBAction func _ListButtonTapped(_ sender: Any) {
        self._ArrangeType = .list
        self.mGridButton.backgroundColor = .clear
        self.mListButton.backgroundColor = App_Constants.Instance.Color(.selected)
        self._HighlightIndex = -1
        self.mCollectionView.isHidden = _ArrangeType != .grid
    }
    
    @IBAction func _SortButtonTapped(_ sender: Any) {
        autoreleasepool{[weak self] in
            guard let weak = self else{return}
            let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let name = UIAlertAction.init(title: kName, style: .default, handler: {action in
                weak.mSortLabel.text = weak._App_Constants.Text(.sort_by_name)
                weak._SortType = .name
                weak._SortByName()
                weak.mTableView.reloadData()
                weak.mCollectionView.reloadData()
            })
            let date = UIAlertAction.init(title: kDate, style: .default, handler: {action in
                weak.mSortLabel.text = weak._App_Constants.Text(.sort_by_date)
                weak._SortType = .date
                weak._SortByDate()
                weak.mTableView.reloadData()
                weak.mCollectionView.reloadData()
            })
            controller.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = App_Constants.Instance.Color(.light)
            controller.view.tintColor = .white
            controller.addAction(name)
            controller.addAction(date)
            if let popup = controller.popoverPresentationController{
                popup.sourceView = weak.mSortButton
                popup.permittedArrowDirections = [.up]
                popup.sourceRect = CGRect.init(x: weak.mSampleSortButton.frame.midX - 10, y: weak.mSampleSortButton.frame.maxY, width: 0, height: 0)
            }
            weak.present(controller, animated: true, completion: nil)
        }
    }
    
}

extension LibraryListViewController{
    
    private func _Initialize(){
        autoreleasepool{
            var config: URLSessionConfiguration? = URLSessionConfiguration.background(withIdentifier: Constants.kBgSessionId)
            config!.urlCache = URLCache.init(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
            config!.urlCredentialStorage = nil
            config!.requestCachePolicy = .useProtocolCachePolicy
            _Download_Manager.downloadService.downloadsSession = URLSession.init(configuration: config!, delegate: _Download_Manager, delegateQueue: nil)
            config = nil
        }
        self.mManualTypeSegment.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: _App_Constants.Font(.regular, 14)], for: .normal)
        self.mManualTypeSegment.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: _App_Constants.Font(.regular, 14)], for: .selected)
        self._Reload()
        NotificationCenter.default.removeObserver(self, name: _App_Constants.Notification_Name(.sync_all), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self._Reload), name: _App_Constants.Notification_Name(.sync_all), object: nil)
        NotificationCenter.default.removeObserver(self, name: App_Constants.Instance.Notification_Name(.revision), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self._HightlightRevision(_:)), name: App_Constants.Instance.Notification_Name(.revision), object: nil)
        //UI
        if _Files.isEmpty{
            self._Type = .downloads
            self.mManualTypeSegment.selectedSegmentIndex = 0
        }else{
            self._Type = .files
            self.mManualTypeSegment.selectedSegmentIndex = 1
        }
        self.mGridButton.cornerRadius = 5
        self.mListButton.cornerRadius = 5
        self.mGridButton.backgroundColor = App_Constants.Instance.Color(.selected)
        autoreleasepool{
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.itemSize = CGSize.init(width: self.view.frame.size.width / 4, height: (self.view.frame.size.width / 4) * 1.4)
            self.mCollectionView.collectionViewLayout = layout
        }
    }
    
    @objc private func _HightlightRevision(_ notification: Notification){
        if let man = notification.userInfo?[kManualNotificationId] as? Manual{
            self._Type = .downloads
            self.mManualTypeSegment.selectedSegmentIndex = 0
            self._HighlightIndex = self._Downloads.firstIndex(where: {m in m.manual_title == man.manual_title}) ?? -1
            self.mTableView.reloadData()
            self.mCollectionView.reloadData()
            self.mCollectionView.scrollToItem(at: [0,self._HighlightIndex], at: .centeredVertically, animated: false)
            self.mTableView.scrollToRow(at: [0,self._HighlightIndex], at: .middle, animated: false)
        }
    }
    
    @objc private func revisionButtonTapped(_ sender: UIButton){
        autoreleasepool{[weak self] in
            guard let weak = self else{return}
            let i = sender.tag - 1
            NotificationCenter.default.post(name: App_Constants.Instance.Notification_Name(.revision), object: nil, userInfo: [kManual:weak._Files[i]])
        }
    }
    
    @objc private func _Reload(){
        self._GenerateManuals()
    }
    
    private func _GenerateManuals(){
        autoreleasepool{
            self._Manuals = _App_Constants.LoadAllFormCore(.manual) ?? []
            self._Downloads = []
            self._Files = _FileManager.get_manuals(at: self.path)
            let all_files = _FileManager.getAllManuals(Constants.kManualDirectory)

            for (_,man) in self._Manuals.enumerated(){
                if all_files.contains(where: {f in
                    f.manual_title == man.manual_title &&
                        f.manual_description == man.manual_description &&
                        f.upload_date == man.upload_date &&
                        f.manual_version == man.manual_version
                }){
                    continue
                }else{
                    if all_files.contains(where: {f in
                        f.manual_title == man.manual_title &&
                            ((man.manual_version ?? "1").compare((f.manual_version ?? "1"), options: .numeric) == .orderedDescending)
                    }){
                        self._Downloads.append(man)
                    }else if !all_files.contains(where: {f in
                        f.manual_title == man.manual_title
                    }){
                        self._Downloads.append(man)
                    }
                }
            }
            self._SortType == .name ? self._SortByName() : self._SortByDate()
            DispatchQueue.main.async{
                self.mTableView.reloadData()
                self.mCollectionView.reloadData()
            }
        }
    }
    
    private func _RemoveDuplicateManual(){
        autoreleasepool{
            let files = _FileManager.getAllManuals(Constants.kManualDirectory)
            for file1 in files{
                for file2 in files{
                    if file1.is_folder ?? false || file2.is_folder ?? false {
                        continue
                    }
                    if file1.manual_title == file2.manual_title{
                        if (file1.manual_version ?? "1").compare((file2.manual_version ?? "1")) == ComparisonResult.orderedDescending{
                            _FileManager.deleteManual("\(Constants.kManualDirectory)/\(file2.manual_category ?? "")", "\(file2.manual_version ?? "")_\(file2.manual_file_name ?? "")_\(file2.upload_date ?? "")_\(file2.manual_description ?? "").pdf")
                            if let d = _FileManager.getFilesInDirectory(file2.manual_category ?? ""){
                                _FileManager.deleteManual(Constants.kManualDirectory, file2.manual_category ?? "")
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    private func _HasRevision(_ manual: Manual)->Bool{
        return autoreleasepool{()->Bool in
            for man in self._Downloads{
                if man.manual_title == manual.manual_title{
                    if (man.manual_version ?? "1").compare(manual.manual_version ?? "1", options: .numeric) == ComparisonResult.orderedDescending{
                        return true
                    }else{
                        return false
                    }
                }
            }
            return false
        }
    }
    
    private func _ReloadCells(at indexpath: [IndexPath]){
        self._ReloadRows(at: indexpath)
        self._ReloadCell(at: indexpath)
    }
    
    private func _ReloadRows(at indexPath: [IndexPath]){
        self.mTableView.beginUpdates()
        self.mTableView.reloadRows(at: indexPath, with: .automatic)
        self.mTableView.endUpdates()
    }
    
    private func _ReloadCell(at indexPath: [IndexPath]){
        self.mCollectionView.performBatchUpdates({
            self.mCollectionView.reloadItems(at: indexPath)
        }, completion: nil)
    }
    
    private func _SortByName(){
        self._Files = self._Files.sorted(by: {($0.manual_title ?? "") < ($1.manual_title ?? "")})
        self._Downloads = self._Downloads.sorted(by: {($0.manual_title ?? "") < ($1.manual_title ?? "")})
    }
    
    private func _SortByDate(){
        self._Files = self._Files.sorted(by: {($0.upload_date ?? "").toDate() < ($1.upload_date ?? "").toDate()})
        self._Downloads = self._Downloads.sorted(by: {($0.upload_date ?? "").toDate() < ($1.upload_date ?? "").toDate()})
    }
    
    
}

extension LibraryListViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch _Type{
        case .downloads:
            return self._Downloads.count
        case .files:
            return self._Files.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: _App_Constants.Cell(.cell)) as! PDFListTableViewCell
        cell.delegate = self
        switch _Type{
        case .downloads:
            cell.mNameLabel.text = self._Downloads[indexPath.row].manual_title
            cell.mDateLabel.text = self._Downloads[indexPath.row].upload_date?.formattedDate() ?? ""
            cell.mCategoryLabel.text = self._Downloads[indexPath.row].manual_description
            cell.mPDFStateButton.setImage(self._App_Constants.Image(.download), for: .normal)
            autoreleasepool{
                let relURL = Api_Names.download_manual + (_Downloads[indexPath.row].manual_file_name ?? "")
                cell.mTypeImage._GenerateThumbFromPDF(URL(string: Api_Names.Main + relURL)!, self._App_Constants.Image(.pdf))
                cell._Configure(download: _Download_Manager.downloadService.activeDownloads[URL(string:Api_Names.Main + relURL)!])
            }
            //show selected file to update
            if indexPath.row == self._HighlightIndex{
                UIView.animate(withDuration: 0.5, animations: {
                    cell.contentView.backgroundColor = .cyan
                }, completion: { f in
                    UIView.animate(withDuration: 0.5, animations: {
                        cell.contentView.backgroundColor = .clear
                    })
                })
            }
        case .files:
            cell.mNameLabel.text = self._Files[indexPath.row].manual_title
            cell.mDateLabel.text = self._Files[indexPath.row].upload_date?.formattedDate() ?? ""
            cell.mCategoryLabel.text = self._Files[indexPath.row].manual_description
            cell.mPDFStateButton.isHidden = (self._Files[indexPath.row].is_folder ?? false)
            cell.mPDFStateButton.setImage(_HasRevision(_Files[indexPath.row]) ? self._App_Constants.Image(.revision) : self._App_Constants.Image(.check), for: .normal)
            autoreleasepool{
                let relURL = FilesManager.default.path("\(_Files[indexPath.row].manual_category ?? "")/\(_Files[indexPath.row].manual_version ?? "")_\(_Files[indexPath.row].manual_title ?? "")_\(_Files[indexPath.row].upload_date ?? "")_\(_Files[indexPath.row].manual_description ?? "")")
                cell.mTypeImage._GenerateThumbFromPDF(relURL!, (self._Files[indexPath.row].is_folder ?? false) ? self._App_Constants.Image(.folder) : self._App_Constants.Image(.pdf))
            }
            cell._Configure(download: nil)
            cell.mPDFStateButton.isHidden = (self._Files[indexPath.row].is_folder ?? false) && !(self._HasRevision(_Files[indexPath.row]))
            if self._Files[indexPath.row].is_folder ?? false{
                cell.mPDFStateButton.isHidden = true
            }else{
                if self._HasRevision(_Files[indexPath.row]){
                    cell.mPDFStateButton.isHidden = false
                    cell.mPDFStateButton.tag = indexPath.row + 1
                    cell.mPDFStateButton.addTarget(self, action: #selector(revisionButtonTapped(_:)), for: .touchUpInside)
                }else{
                    cell.mPDFStateButton.isHidden = true
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch _Type{
        case .downloads:
            break
        case .files:
            self._SelectedIndex = indexPath
            if (_Files[indexPath.row].is_folder ?? false){
                autoreleasepool{
                    let vc = LibraryListModelViewController.init(path: "\(self.path)/\(_Files[indexPath.row].manual_title ?? "")", arrange: self._ArrangeType, sort: self._SortType)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }else{
                autoreleasepool{
                    let vc = UIStoryboard.init(name: kMain, bundle: nil).instantiateViewController(withIdentifier: kPDFReader) as! PDFViewerViewController
                    vc._Manual = self._Files[indexPath.row]
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}

extension LibraryListViewController:DownloadDelegate{
    func downloadDidBegin(_ cell: PDFListTableViewCell) {
        switch _Type{
        case .downloads:
            self._HighlightIndex = -1
            if let indexPath = self.mTableView.indexPath(for: cell){
                self.mTableView.reloadRows(at: [indexPath], with: .automatic)
                let manual = _Downloads[indexPath.row]
                let relURL = Api_Names.download_manual + (manual.manual_file_name ?? "")
                _Download_Manager.didFinishishDownload = {session,downloadTask,location,success in
                    guard let sourceURL = downloadTask.originalRequest?.url else { return }
                    let download = self._Download_Manager.downloadService.activeDownloads[sourceURL]
                    self._Download_Manager.downloadService.activeDownloads[sourceURL] = nil
                    DispatchQueue.main.async{
                        let name = self._Downloads[indexPath.row].manual_title
                        self._RemoveDuplicateManual()
                        self._ReloadCells(at: [[0,(self._Downloads.firstIndex(where: {$0.manual_file_name == download?.manual.manual_file_name}) ?? 0)]])
                        if success{
                            self._Reload()
                            self._Type = .files
                            self._SelectedIndex = [0,self._Files.firstIndex(where: {m in m.manual_title == name}) ?? 0]
                            self.mManualTypeSegment.selectedSegmentIndex = 1
                            self.mTableView.reloadSections(IndexSet(integer: 0), with: .none)
                            self.mCollectionView.reloadSections(IndexSet(integer: 0))
                        }
                        Sync.Log_Event(event: .manual_downloaded, type: .manual, id: "\(manual.manual_id ?? 0)", {s,m in})
                    }
                }
                _Download_Manager.didWriteData = {session,downloadTask,bytesWritten,totalBytesWritten,totalBytesExpectedToWrite,speed in
                    guard let sourceURL = downloadTask.originalRequest?.url else { return }
                    let download = self._Download_Manager.downloadService.activeDownloads[sourceURL]
                    var estimatedTime:Double = 0
                    if speed != 0{
                        estimatedTime = Double(totalBytesExpectedToWrite - totalBytesWritten) / Double(speed)
                    }else{
                        estimatedTime = 0
                    }
                    DispatchQueue.main.async{
                        if let cell = self.mCollectionView.cellForItem(at: [0,(self._Downloads.firstIndex(where: {$0.manual_file_name == download?.manual.manual_file_name}) ?? 0)]) as? PDFListCollectionViewCell{
                            cell._UpdateDisplay(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite, speed, estimatedTime.toString())
                        }
                        if let cell = self.mTableView.cellForRow(at: [0,(self._Downloads.firstIndex(where: {$0.manual_file_name == download?.manual.manual_file_name}) ?? 0)]) as? PDFListTableViewCell{
                            cell._UpdateDisplay(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite, speed, estimatedTime.toString())
                        }
                    }
                }
                
                _Download_Manager.startDownload(manual, relURL)
                self._ReloadCells(at: [indexPath])
            }
        case .files:
            if self.path == Constants.kManualDirectory{
                self._Type = .downloads
                self.mManualTypeSegment.selectedSegmentIndex = 0
                self._HighlightIndex = self._Downloads.firstIndex(where: {m in m.manual_title == _Files[self.mTableView.indexPath(for: cell)?.row ?? 0].manual_title}) ?? -1
                self.mTableView.reloadData()
                self.mCollectionView.reloadData()
                self.mTableView.scrollToRow(at: [0,self._HighlightIndex], at: .middle, animated: false)
            }else{
                self.navigationController?.popViewController(animated: true)
                NotificationCenter.default.post(name: App_Constants.Instance.Notification_Name(.revision), object: nil, userInfo: [kManual:self._Files[self.mTableView.indexPath(for: cell)?.row ?? 0]])
            }
        }
    }
    
    func downloadDidStop(_ cell: PDFListTableViewCell) {
        if let indexPath = self.mTableView.indexPath(for: cell){
            _Download_Manager.cancelDownload(_Downloads[indexPath.row], Api_Names.download_manual + (self._Downloads[indexPath.row].manual_file_name ?? ""))
            self._ReloadCells(at: [indexPath])
        }
    }
  
}

extension LibraryListViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch _Type{
        case .downloads:
            return self._Downloads.count
        case .files:
            return self._Files.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self._App_Constants.Cell(.cell), for: indexPath) as! PDFListCollectionViewCell
        cell.delegate = self
        switch _Type{
        case .downloads:
            cell.mNameLabel.text = self._Downloads[indexPath.row].manual_title
            cell.mDateLabel.text = self._Downloads[indexPath.row].upload_date?.formattedDate() ?? ""
            cell.mDescLabel.text = self._Downloads[indexPath.row].manual_description
            cell.mPDFStateButton.setImage(self._App_Constants.Image(.download), for: .normal)
            cell.mPDFStateButton.isUserInteractionEnabled = true
            let relURL = Api_Names.download_manual + (_Downloads[indexPath.row].manual_file_name ?? "")
            cell.mTypeImage._GenerateThumbFromPDF(URL(string: Api_Names.Main + relURL)!, self._App_Constants.Image(.pdf))
            cell._Configure(download: _Download_Manager.downloadService.activeDownloads[URL(string:Api_Names.Main + relURL)!])
            //show selected file to update
            if indexPath.row == self._HighlightIndex{
                UIView.animate(withDuration: 0.5, animations: {
                    cell.contentView.backgroundColor = .cyan
                }, completion: { f in
                    UIView.animate(withDuration: 0.5, animations: {
                        cell.contentView.backgroundColor = .clear
                    })
                })
            }
        case .files:
            cell.mNameLabel.text = self._Files[indexPath.row].manual_title
            cell.mDateLabel.text = self._Files[indexPath.row].upload_date?.formattedDate() ?? ""
            cell.mDescLabel.text = self._Files[indexPath.row].manual_description
            cell.mPDFStateButton.setImage(_HasRevision(_Files[indexPath.row]) ? self._App_Constants.Image(.revision) : self._App_Constants.Image(.check), for: .normal)
            autoreleasepool{
                let relURL = FilesManager.default.path("\(_Files[indexPath.row].manual_category ?? "")/\(_Files[indexPath.row].manual_version ?? "")_\(_Files[indexPath.row].manual_title ?? "")_\(_Files[indexPath.row].upload_date ?? "")_\(_Files[indexPath.row].manual_description ?? "")")
                cell.mTypeImage._GenerateThumbFromPDF(relURL!, (self._Files[indexPath.row].is_folder ?? false) ? self._App_Constants.Image(.folder) : self._App_Constants.Image(.pdf))
            }
            cell._Configure(download: nil)
            cell.mPDFStateButton.isHidden = (self._Files[indexPath.row].is_folder ?? false)
            if self._Files[indexPath.row].is_folder ?? false{
                cell.mPDFStateButton.isHidden = true
            }else{
                if self._HasRevision(_Files[indexPath.row]){
                    cell.mPDFStateButton.isHidden = false
                    cell.mPDFStateButton.tag = indexPath.row + 1
                    cell.mPDFStateButton.addTarget(self, action: #selector(revisionButtonTapped(_:)), for: .touchUpInside)
                }else{
                    cell.mPDFStateButton.isHidden = true
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch _Type{
        case .downloads:
            break
        case .files:
            self._SelectedIndex = indexPath
            if (_Files[indexPath.row].is_folder ?? false){
                autoreleasepool{
                    let vc = LibraryListModelViewController.init(path: "\(self.path)/\(_Files[indexPath.row].manual_title ?? "")", arrange: self._ArrangeType, sort: self._SortType)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }else{
                autoreleasepool{
                    let vc = UIStoryboard.init(name: kMain, bundle: nil).instantiateViewController(withIdentifier: kPDFReader) as! PDFViewerViewController
                    vc._Manual = self._Files[indexPath.row]
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
        }
    }
    
}

extension LibraryListViewController:CollectionDownloadDelegate{
    func downloadDidBegin(_ cell: PDFListCollectionViewCell) {
        switch _Type{
        case .downloads:
            self._HighlightIndex = -1
            if let indexPath = self.mCollectionView.indexPath(for: cell){
                self.mCollectionView.reloadItems(at: [indexPath])
                let manual = _Downloads[indexPath.row]
                let relURL = Api_Names.download_manual + (manual.manual_file_name ?? "")
                _Download_Manager.didFinishishDownload = {session,downloadTask,location,success in
                    guard let sourceURL = downloadTask.originalRequest?.url else { return }
                    let download = self._Download_Manager.downloadService.activeDownloads[sourceURL]
                    self._Download_Manager.downloadService.activeDownloads[sourceURL] = nil
                    DispatchQueue.main.async{
                        let name = self._Downloads[indexPath.row].manual_title
                        self._RemoveDuplicateManual()
                        self._ReloadCells(at: [[0,(self._Downloads.firstIndex(where: {$0.manual_file_name == download?.manual.manual_file_name}) ?? 0)]])
                        if success{
                            self._Reload()
                            self._Type = .files
                            self._SelectedIndex = [0,self._Files.firstIndex(where: {m in m.manual_title == name}) ?? 0]
                            self.mManualTypeSegment.selectedSegmentIndex = 1
                            self.mCollectionView.reloadSections(IndexSet.init(integer: 0))
                            self.mTableView.reloadSections(IndexSet(integer: 0), with: .none)
                        }
                        Sync.Log_Event(event: .manual_downloaded, type: .manual, id: "\(download?.manual.manual_id ?? 0)", {s,m in})
                    }
                }
                _Download_Manager.didWriteData = {session,downloadTask,bytesWritten,totalBytesWritten,totalBytesExpectedToWrite,speed in
                    guard let sourceURL = downloadTask.originalRequest?.url else { return }
                    let download = self._Download_Manager.downloadService.activeDownloads[sourceURL]
                    var estimatedTime:Double = 0
                    if speed != 0{
                        estimatedTime = Double(totalBytesExpectedToWrite - totalBytesWritten) / Double(speed)
                    }else{
                        estimatedTime = 0
                    }
                    DispatchQueue.main.async{
                        if let cell = self.mCollectionView.cellForItem(at: [0,(self._Downloads.firstIndex(where: {$0.manual_file_name == download?.manual.manual_file_name}) ?? 0)]) as? PDFListCollectionViewCell{
                            cell._UpdateDisplay(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite, speed, estimatedTime.toString())
                        }
                        if let cell = self.mTableView.cellForRow(at: [0,(self._Downloads.firstIndex(where: {$0.manual_file_name == download?.manual.manual_file_name}) ?? 0)]) as? PDFListTableViewCell{
                            cell._UpdateDisplay(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite, speed, estimatedTime.toString())
                        }
                    }
                }
                
                _Download_Manager.startDownload(manual, relURL)
                self._ReloadCells(at: [indexPath])
            }
        case .files:
            if self.path == Constants.kManualDirectory{
                self._Type = .downloads
                self.mManualTypeSegment.selectedSegmentIndex = 0
                self._HighlightIndex = self._Downloads.firstIndex(where: {m in m.manual_title == _Files[self.mCollectionView.indexPath(for: cell)?.row ?? 0].manual_title}) ?? -1
                self.mTableView.reloadData()
                self.mCollectionView.reloadData()
                self.mCollectionView.scrollToItem(at: [0,self._HighlightIndex], at: .centeredVertically, animated: false)
                self.mTableView.scrollToRow(at: [0,self._HighlightIndex], at: .middle, animated: false)
            }else{
                self.navigationController?.popViewController(animated: true)
                NotificationCenter.default.post(name: App_Constants.Instance.Notification_Name(.revision), object: nil, userInfo: [kManual:self._Files[self.mCollectionView.indexPath(for: cell)?.row ?? 0]])
            }
        }
    }
    
    func downloadDidStop(_ cell: PDFListCollectionViewCell) {
        if let indexPath = self.mCollectionView.indexPath(for: cell){
            _Download_Manager.cancelDownload(_Downloads[indexPath.row], Api_Names.download_manual + (self._Downloads[indexPath.row].manual_file_name ?? ""))
            self._ReloadCells(at: [indexPath])
        }
    }
    
}
