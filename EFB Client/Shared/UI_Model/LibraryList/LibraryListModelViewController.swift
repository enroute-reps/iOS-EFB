//
//  LibraryListModelViewController.swift
//  EFB Client
//
//  Created by Mr.Zee on 11/9/19.
//  Copyright © 2019 MehrPardaz. All rights reserved.
//

import UIKit

class LibraryListModelViewController: UIViewController {
    
    @IBOutlet weak var mNavigationView: UIView!
    @IBOutlet weak var mBackButton: UIButton!
    @IBOutlet weak var mTitleLabel: UILabel!
    @IBOutlet weak var mSortView: UIView!
    @IBOutlet weak var mGridButton: UIButton!
    @IBOutlet weak var mListButton: UIButton!
    @IBOutlet weak var mSortTitleLabel: UILabel!
    @IBOutlet weak var mSortButton: UIButton!
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var mCollectionView: UICollectionView!
    
    
    private var path:String = ""
    private var arrange:ArrangeType = .grid
    private var sort:SortType = .date
    private var files:[Manual] = []
    private var _SelectedIndex:IndexPath = [0,0]
    private var kMain = "Main"
    private var kManual = "manual"
    private var kCollectionCell = "LibraryListModelCollectionViewCell"
    private var kTableCell = "LibraryListModelTableViewCell"
    private var kDate = "Date"
    private var kName = "Name"
    private var kPDFViewer = "pdfViewer"
    private var kIsHidden = "isHidden"
    
    convenience init(path: String, arrange: ArrangeType, sort: SortType){
        self.init()
        self.path = path
        self.arrange = arrange
        self.sort = sort
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self._Initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func _BackButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func _GridButtonTapped(_ sender: Any) {
        self.arrange = .grid
        self.mGridButton.backgroundColor = App_Constants.Instance.Color(.selected)
        self.mListButton.backgroundColor = .clear
        self.mCollectionView.isHidden = false
    }
    
    @IBAction func _ListButtonTapped(_ sender: Any) {
        self.arrange = .list
        self.mGridButton.backgroundColor = .clear
        self.mListButton.backgroundColor = App_Constants.Instance.Color(.selected)
        self.mCollectionView.isHidden = true
    }
    
    @IBAction func _SortButtonTapped(_ sender: Any) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let name = UIAlertAction.init(title: kName, style: .default, handler: {action in
            self.mSortTitleLabel.text = App_Constants.Instance.Text(.sort_by_name)
            self.sort = .name
            self.sortByName()
        })
        let date = UIAlertAction.init(title: kDate, style: .default, handler: {action in
            self.mSortTitleLabel.text = App_Constants.Instance.Text(.sort_by_date)
            self.sort = .date
            self.sortByDate()
        })
        controller.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = App_Constants.Instance.Color(.light)
        controller.view.tintColor = .white
        controller.addAction(name)
        controller.addAction(date)
        if let popup = controller.popoverPresentationController{
            popup.sourceView = sender as? UIButton
            popup.permittedArrowDirections = [.up]
            popup.sourceRect = CGRect.init(x: (sender as! UIButton).frame.maxX - 20, y: self.mSortButton.frame.maxY, width: 0, height: 0)
        }
        self.present(controller, animated: true, completion: nil)
    }
    
}

extension LibraryListModelViewController{
    
    private func _Initialize(){
        self.mCollectionView.register(UINib.init(nibName: kCollectionCell, bundle: nil), forCellWithReuseIdentifier: App_Constants.Instance.Cell(.cell))
        self.mTableView.register(UINib.init(nibName: kTableCell, bundle: nil), forCellReuseIdentifier: App_Constants.Instance.Cell(.cell))
        self.reload()
        self.mTitleLabel.text = self.path.components(separatedBy: "/").last ?? ""
        self.mGridButton.cornerRadius = 5
        self.mListButton.cornerRadius = 5
        self.arrange == .grid ? (self.mGridButton.backgroundColor = App_Constants.Instance.Color(.selected)) : (self.mListButton.backgroundColor = App_Constants.Instance.Color(.selected))
        self.mCollectionView.isHidden = self.arrange != .grid
        autoreleasepool{[weak self] in
            guard let weak = self else{return}
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.itemSize = CGSize.init(width: weak.view.frame.size.width / 4, height: (weak.view.frame.size.width / 4) * 1.4)
            weak.mCollectionView.collectionViewLayout = layout
        }
    }
    
    @objc private func reload(){
        self.generateManuals()
    }
    
    private func sortByName(){
        self.files = self.files.sorted(by: {($0.manual_title ?? "") < ($1.manual_title ?? "")})
        reloadUI()
    }
    
    private func sortByDate(){
        self.files = self.files.sorted(by: {($0.upload_date ?? "").toDate() < ($1.upload_date ?? "").toDate()})
        reloadUI()
    }
    
    private func reloadUI(){
        DispatchQueue.main.async{
            self.mTableView.beginUpdates()
            self.mTableView.reloadData()
            self.mTableView.endUpdates()
            self.mCollectionView.performBatchUpdates({
                self.mCollectionView.reloadData()
            }, completion: nil)
        }
    }
    
    private func generateManuals(){
        autoreleasepool{[weak self] in
            guard let weak = self else{return}
            weak.files = FilesManager.default.get_manuals(at: weak.path)
            weak.sort == .name ? weak.sortByName() : weak.sortByDate()
        }
    }
    
    private func hasRevision(_ manual: Manual)->Bool{
        return autoreleasepool{()->Bool in
            let manuals:[Manual] = App_Constants.Instance.LoadAllFormCore(.manual) ?? []
            for man in manuals{
                if man.manual_title == manual.manual_title{
                    if (man.manual_version ?? "1").compare(manual.manual_version ?? "1", options: .numeric) == ComparisonResult.orderedDescending{
                        return true
                    }
                }
            }
            return false
        }
    }
    
    @objc private func revisionButtonTapped(_ sender: UIButton){
        autoreleasepool{[weak self] in
            guard let weak = self else{return}
            let i = sender.tag - 1
            weak.navigationController?.popToRootViewController(animated: true)
            NotificationCenter.default.post(name: App_Constants.Instance.Notification_Name(.revision), object: nil, userInfo: [kManual:weak.files[i]])
        }
    }
    
}

extension LibraryListModelViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.files.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: App_Constants.Instance.Cell(.cell)) as! LibraryListModelTableViewCell
        cell.mNameLabel.text = self.files[indexPath.row].manual_title
        cell.mDateLabel.text = self.files[indexPath.row].upload_date?.formattedDate() ?? ""
        cell.mCategoryLabel.text = self.files[indexPath.row].manual_description
        cell.mPDFStateButton.setImage(self.hasRevision(files[indexPath.row]) ? App_Constants.Instance.Image(.revision) : App_Constants.Instance.Image(.check), for: .normal)
        autoreleasepool{[weak self] in
            guard let weak = self else{return}
            let relURL = FilesManager.default.path("\(files[indexPath.row].manual_category ?? "")/\(files[indexPath.row].manual_version ?? "")_\(files[indexPath.row].manual_title ?? "")_\(files[indexPath.row].upload_date ?? "")_\(files[indexPath.row].manual_description ?? "")")
            cell.mTypeImage._GenerateThumbFromPDF(relURL!, (weak.files[indexPath.row].is_folder ?? false) ? App_Constants.Instance.Image(.folder) : App_Constants.Instance.Image(.pdf))
        }
        if self.files[indexPath.row].is_folder ?? false{
            cell.mPDFStateButton.isHidden = true
        }else{
            if self.hasRevision(files[indexPath.row]){
                cell.mPDFStateButton.isHidden = false
                cell.mPDFStateButton.tag = indexPath.row + 1
                cell.mPDFStateButton.addTarget(self, action: #selector(revisionButtonTapped(_:)), for: .touchUpInside)
            }else{
                cell.mPDFStateButton.isHidden = true
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self._SelectedIndex = indexPath
        if (files[indexPath.row].is_folder ?? false){
            autoreleasepool{[weak self] in
                guard let weak = self else{return}
                let vc = LibraryListModelViewController.init(path: weak.path + (files[indexPath.row].manual_category ?? ""), arrange: arrange, sort: sort)
                weak.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            autoreleasepool{[weak self] in
                guard let weak = self else{return}
                let vc = UIStoryboard.init(name: kMain, bundle: nil).instantiateViewController(withIdentifier: kPDFViewer) as! PDFViewerViewController
                vc._Manual = weak.files[indexPath.row]
                weak.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    

    
}

extension LibraryListModelViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.files.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: App_Constants.Instance.Cell(.cell), for: indexPath) as! LibraryListModelCollectionViewCell
        cell.mNameLabel.text = self.files[indexPath.row].manual_title
        cell.mDateLabel.text = self.files[indexPath.row].upload_date?.formattedDate() ?? ""
        cell.mDescLabel.text = self.files[indexPath.row].manual_description
        cell.mPDFStateButton.setImage(self.hasRevision(files[indexPath.row]) ? App_Constants.Instance.Image(.revision) : App_Constants.Instance.Image(.check), for: .normal)
        autoreleasepool{[weak self] in
            guard let weak = self else{return}
            let relURL = FilesManager.default.path("\(files[indexPath.row].manual_category ?? "")/\(files[indexPath.row].manual_version ?? "")_\(files[indexPath.row].manual_title ?? "")_\(files[indexPath.row].upload_date ?? "")_\(files[indexPath.row].manual_description ?? "")")
            cell.mTypeImage._GenerateThumbFromPDF(relURL!, (weak.files[indexPath.row].is_folder ?? false) ? App_Constants.Instance.Image(.folder) : App_Constants.Instance.Image(.pdf))
        }
        if self.files[indexPath.row].is_folder ?? false{
            cell.mPDFStateButton.isHidden = true
        }else{
            if self.hasRevision(files[indexPath.row]){
                cell.mPDFStateButton.isHidden = false
                cell.mPDFStateButton.tag = indexPath.row + 1
                cell.mPDFStateButton.addTarget(self, action: #selector(revisionButtonTapped(_:)), for: .touchUpInside)
            }else{
                cell.mPDFStateButton.isHidden = true
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self._SelectedIndex = indexPath
        if (files[indexPath.row].is_folder ?? false){
            autoreleasepool{[weak self] in
                guard let weak = self else{return}
                let vc = LibraryListModelViewController.init(path: weak.path + (files[indexPath.row].manual_category ?? ""), arrange: arrange, sort: sort)
                weak.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            autoreleasepool{[weak self] in
                guard let weak = self else{return}
                let vc = UIStoryboard.init(name: kMain, bundle: nil).instantiateViewController(withIdentifier: kPDFViewer) as! PDFViewerViewController
                vc._Manual = weak.files[indexPath.row]
                weak.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
}
