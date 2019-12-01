//
//  LibraryViewController.swift
//  EFB Client
//
//  Created by Mr.Zee on 10/14/19.
//  Copyright © 2019 MehrPardaz. All rights reserved.
//

import UIKit
import PDFKit

class PDFViewerViewController: UIViewController {
    
    fileprivate enum ManualType{
        case downloads,files
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    @IBOutlet weak var mCurrentPageView: UIView!
    @IBOutlet weak var mPageLabel: UILabel!
    @IBOutlet weak var mPDFView: PDFView!
    @IBOutlet weak var mTopView: UIView!
    @IBOutlet weak var mPDFThumbnailView: PDFThumbnailView!
    @IBOutlet weak var mSearchView: UIView!
    @IBOutlet weak var mSearchTextField: UITextField!
    @IBOutlet weak var mSearchButton: UIButton!
    @IBOutlet weak var mSearchNextButton: UIButton!
    @IBOutlet weak var mSearchPrevButton: UIButton!
    @IBOutlet weak var mSearchViewBottom: NSLayoutConstraint!
    
    private var _Selections:[PDFSelection] = []
    private var _CurrentSearchedPageIndex = -1{
        didSet{
            self.mSearchNextButton.isEnabled = _CurrentSearchedPageIndex >= 0 && _CurrentSearchedPageIndex < self._Selections.count - 1
            self.mSearchNextButton.isEnabled ? (self.mSearchNextButton.tintColor = .white) : (self.mSearchNextButton.tintColor = .gray)
            self.mSearchPrevButton.isEnabled = self._CurrentSearchedPageIndex > 0
            self.mSearchPrevButton.isEnabled ? (self.mSearchPrevButton.tintColor = .white) : (self.mSearchPrevButton.tintColor = .gray)
            
        }
    }
    public var _Manual:Manual?
    private let kIsHidden = "isHidden"
    private var kPageCounter = "Page: %d Total: %d"
    
    override var prefersStatusBarHidden: Bool{
        return self.mTopView.alpha == 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self._Initialize()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.mPDFView.autoScales = true
    }

    @IBAction func _BackButtonTapped(_ sender: Any) {
        NotificationCenter.default.post(name: App_Constants.Instance.Notification_Name(.tabbar_height), object: nil, userInfo: [kIsHidden: false])
        NotificationCenter.default.post(name: App_Constants.Instance.Notification_Name(.hide_statusBar), object: nil, userInfo: [kIsHidden: false])
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func _SearchButtonTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
            self.mSearchView.isHidden = false
        }, completion: {f in
            self.mSearchTextField.becomeFirstResponder()
        })
    }
    
    @IBAction func _SearchCloseButtonTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
            self.mSearchView.isHidden = true
        }, completion: {f in
            self._RemoveAllAnnotations()
            self.mSearchTextField.text = ""
            self.view.endEditing(true)
        })
        
    }
    
    @IBAction func _SearchNextButtonTapped(_ sender: Any) {
        self._CurrentSearchedPageIndex += 1
        self.mPDFView.go(to: self._Selections[self._CurrentSearchedPageIndex].pages.first ?? PDFPage())
        for selected in self._Selections{
            selected.color = .yellow
        }
        self._Selections[_CurrentSearchedPageIndex].color = .orange
        self.mPDFView.setCurrentSelection(self._Selections[_CurrentSearchedPageIndex], animate: true)
    }
    
    @IBAction func _SearchPrevButtonTapped(_ sender: Any) {
        self._CurrentSearchedPageIndex -= 1
        self.mPDFView.go(to: self._Selections[self._CurrentSearchedPageIndex].pages.first ?? PDFPage())
        for selected in self._Selections{
            selected.color = .yellow
        }
        self._Selections[_CurrentSearchedPageIndex].color = .orange
        self.mPDFView.setCurrentSelection(self._Selections[_CurrentSearchedPageIndex], animate: true)
    }
}

extension PDFViewerViewController{
    
    private func _Initialize(){
        _ChangePDF()
        self.mPDFView.displayDirection = .horizontal
        self.mPDFView.usePageViewController(true, withViewOptions: nil)
        self.mPDFView.pageBreakMargins = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        self.mPDFView.autoScales = true
        self.mPDFThumbnailView.pdfView = mPDFView
        self.mPDFThumbnailView.thumbnailSize = CGSize.init(width: 50, height: 50)
        self.mPDFThumbnailView.layoutMode = .horizontal
        self.mCurrentPageView.round = true
        self._CurrentSearchedPageIndex = -1
        NotificationCenter.default.addObserver(self, selector: #selector(_KeyboardHeightChanged(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(_PDFPageChanged(_:)),name: Notification.Name.PDFViewPageChanged,object: nil)
        NotificationCenter.default.post(name: App_Constants.Instance.Notification_Name(.tabbar_height), object: nil, userInfo: [kIsHidden:true])
        autoreleasepool{[weak self] in
            guard let weak = self else{return}
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(_ViewTapped(_:)))
            weak.mPDFView.addGestureRecognizer(tap)
        }
        self.navigationController?.delegate = self
    }
    
    @objc private func _KeyboardHeightChanged(_ notification: Notification){
        if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue{
            UIView.animate(withDuration: 0.5, animations: {
                self.mSearchViewBottom.constant == 0 ? (self.mSearchViewBottom.constant = frame.cgRectValue.height) : (self.mSearchViewBottom.constant = 0)
            })
        }
    }
    
    @objc private func _PDFPageChanged(_ sender: Notification){
        self.mPageLabel.text = String(format: self.kPageCounter, (self.mPDFView.document?.index(for: self.mPDFView.currentPage ?? PDFPage()) ?? 0) + 1, self.mPDFView.document?.pageCount ?? 0)
    }
    
    @objc private func _ViewTapped(_ sender: UITapGestureRecognizer){
        UIView.animate(withDuration: 0.3, animations: {
            self.mTopView.alpha = self.mTopView.alpha == 1 ? 0 : 1
            self.mPDFThumbnailView.alpha = self.mPDFThumbnailView.alpha == 1 ? 0 : 1
            self.mCurrentPageView.alpha = self.mCurrentPageView.alpha == 1 ? 0 : 1
        },completion: {finished in
            NotificationCenter.default.post(name: App_Constants.Instance.Notification_Name(.hide_statusBar), object: nil, userInfo: [self.kIsHidden: (self.mTopView.alpha == 0.0)])
        })
    }
    
    private func _ChangePDF(){
        autoreleasepool{[weak self] in
            guard let weak = self else{return}
            guard let manual = weak._Manual else {
                App_Constants.UI.Make_Alert("", App_Constants.Instance.Text(.load_manual_failed))
                return
            }
            guard let url = FilesManager.default.path("\(manual.manual_category ?? "")/\(manual.manual_version ?? "")_\(manual.manual_title ?? "")_\(manual.upload_date ?? "")_\(manual.manual_description ?? "").pdf") else{
                App_Constants.UI.Make_Alert("", App_Constants.Instance.Text(.load_manual_failed))
                return
            }
            guard let doc = PDFDocument.init(url: url) else{
                App_Constants.UI.Make_Alert("", App_Constants.Instance.Text(.load_manual_failed))
                return
            }
            weak.mPDFView.document = doc
            weak.mPDFView.goToFirstPage(self)
            weak.mPDFView.autoScales = true
            weak.mPageLabel.text = String(format: weak.kPageCounter, 1, doc.pageCount)
        }
    }
    
    private func _Search(_ text: String?){
        autoreleasepool{[weak self] in
            guard let weak = self else{return}
            weak._RemoveAllAnnotations()
            let selections = mPDFView.document?.findString(text ?? "", withOptions: [.caseInsensitive])
            weak._Selections = selections ?? []
            weak._CurrentSearchedPageIndex = weak._Selections.isEmpty ? -1 : 0
            for selected in weak._Selections{
                selected.color = .yellow
            }
            weak.mPDFView.highlightedSelections = weak._Selections
            !weak._Selections.isEmpty ? (weak.mPDFView.go(to: weak._Selections[weak._CurrentSearchedPageIndex].pages.first ?? PDFPage())) : ()
            !weak._Selections.isEmpty ? (weak._Selections[_CurrentSearchedPageIndex].color = .orange) : ()
            !weak._Selections.isEmpty ? (weak.mPDFView.setCurrentSelection(weak._Selections[_CurrentSearchedPageIndex], animate: true)) : ()
        }
    }
    
    private func _RemoveAllAnnotations(){
        self._Selections = []
        self.mPDFView.highlightedSelections = []
        self.mPDFView.currentSelection = nil
    }
    
}


extension PDFViewerViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self._Search(textField.text)
        self.view.endEditing(true)
        return true
    }
}

extension PDFViewerViewController: UINavigationControllerDelegate{
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController is LibraryListModelViewController{
            NotificationCenter.default.post(name: App_Constants.Instance.Notification_Name(.tabbar_height), object: nil, userInfo: [kIsHidden: false])
        }else if viewController is PDFViewerViewController{
            NotificationCenter.default.post(name: App_Constants.Instance.Notification_Name(.tabbar_height), object: nil, userInfo: [kIsHidden: true])
            self.mPDFView.autoScales = true
            self.view.layoutSubviews()
            self.view.layoutIfNeeded()
        }
    }
}
