

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
    @IBOutlet weak var mPDFOutlineButton: UIButton!
    
    private var _Selections:[PDFSelection] = []{
        didSet{
            self.mSearchNextButton.isEnabled = _CurrentSearchedPageIndex >= 0 && _CurrentSearchedPageIndex < self._Selections.count - 1
            self.mSearchNextButton.isEnabled ? (self.mSearchNextButton.tintColor = .white) : (self.mSearchNextButton.tintColor = .gray)
            self.mSearchPrevButton.isEnabled = self._CurrentSearchedPageIndex > 0
            self.mSearchPrevButton.isEnabled ? (self.mSearchPrevButton.tintColor = .white) : (self.mSearchPrevButton.tintColor = .gray)
        }
    }
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
        App_Constants.UI.tabbarIsHidden.accept(false)
        App_Constants.UI.statusBarIsHidden.accept(false)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func _SearchButtonTapped(_ sender: Any) {
        self.mSearchView.isHidden = false
        self.mSearchTextField.becomeFirstResponder()
    }
    
    @IBAction func _OutlineButtonTapped(_ sender: Any) {
        let outlineController = OutlineViewController.init(outline: self.mPDFView.document?.outlineRoot ?? PDFOutline(), delegate: self)
        let nav = UINavigationController.init(rootViewController: outlineController)
        nav.modalPresentationStyle = .popover
        let pop = nav.popoverPresentationController
        outlineController.preferredContentSize = CGSize.init(width: self.view.frame.size.width*0.5, height: self.view.frame.size.height*0.5)
        pop?.backgroundColor = App_Constants.Instance.Color(.light)
        pop?.sourceView = self.mPDFOutlineButton
        pop?.sourceRect = self.mPDFOutlineButton.bounds
        pop?.permittedArrowDirections = [.up]
        self.present(nav, animated: true, completion: nil)
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
        for ann in self.mPDFView.currentPage?.annotations ?? []{
            self.mPDFView.currentPage?.removeAnnotation(ann)
        }
        self.mPDFView.go(to: self._Selections[self._CurrentSearchedPageIndex].pages.first ?? PDFPage())
        let annot = PDFAnnotation.init(bounds: self._Selections[self._CurrentSearchedPageIndex].bounds(for: self._Selections[self._CurrentSearchedPageIndex].pages.first ?? PDFPage()), forType: .highlight, withProperties: nil)
        annot.color = .orange
        self.mPDFView.currentPage?.addAnnotation(annot)
    }
    
    @IBAction func _SearchPrevButtonTapped(_ sender: Any) {
        self._CurrentSearchedPageIndex -= 1
        self.mPDFView.go(to: self._Selections[self._CurrentSearchedPageIndex].pages.first ?? PDFPage())
        for ann in self.mPDFView.currentPage?.annotations ?? []{
            self.mPDFView.currentPage?.removeAnnotation(ann)
        }
        let annot = PDFAnnotation.init(bounds: self._Selections[self._CurrentSearchedPageIndex].bounds(for: self._Selections[self._CurrentSearchedPageIndex].pages.first ?? PDFPage()), forType: .highlight, withProperties: nil)
        annot.color = .orange
        self.mPDFView.currentPage?.addAnnotation(annot)
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
        self.mPDFThumbnailView.thumbnailSize = CGSize.init(width: 30, height: self.mPDFThumbnailView.frame.height-20)
        self.mPDFThumbnailView.layoutMode = .horizontal
        self.mCurrentPageView.round = true
        self._CurrentSearchedPageIndex = -1
        NotificationCenter.default.addObserver(self, selector: #selector(_KeyboardHeightChanged(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(_PDFPageChanged(_:)),name: Notification.Name.PDFViewPageChanged,object: nil)
        App_Constants.UI.tabbarIsHidden.accept(true)
        autoreleasepool{[weak self] in
            guard let weak = self else{return}
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(_ViewTapped(_:)))
            weak.mPDFView.addGestureRecognizer(tap)
        }
        self.navigationController?.delegate = self
    }
    
    @objc private func _KeyboardHeightChanged(_ notification: Notification){
        if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue{
            UIView.animate(withDuration: notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.5, animations: {
                self.mSearchViewBottom.constant = self.view.frame.height-frame.cgRectValue.origin.y
            })
        }
    }
    
    @objc private func _PDFPageChanged(_ sender: Notification){
        self.mPageLabel.text = String(format: self.kPageCounter, (self.mPDFView.document?.index(for: self.mPDFView.currentPage ?? PDFPage()) ?? 0) + 1, self.mPDFView.document?.pageCount ?? 0)
    }
    
    @objc private func _ViewTapped(_ sender: UITapGestureRecognizer){
        App_Constants.UI.statusBarIsHidden.accept(self.mTopView.alpha != 0.0)
        UIView.animate(withDuration: 0.5, animations: {
            self.mTopView.alpha = self.mTopView.alpha == 1 ? 0 : 1
            self.mPDFThumbnailView.alpha = self.mPDFThumbnailView.alpha == 1 ? 0 : 1
            self.mCurrentPageView.alpha = self.mCurrentPageView.alpha == 1 ? 0 : 1
        },completion: {finished in
            
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
            weak.mPDFView.document?.delegate = self
            weak.mPageLabel.text = String(format: weak.kPageCounter, 1, doc.pageCount)
        }
    }
    
    private func _Search(_ text: String?){
        autoreleasepool{[weak self] in
            guard let weak = self else{return}
            weak._RemoveAllAnnotations()
            weak.mPDFView.document?.beginFindString(text ?? "", withOptions: [.caseInsensitive])
        }
    }
    
    private func _RemoveAllAnnotations(){
        self.mPDFView.document?.cancelFindString()
        self._Selections = []
        for annot in self.mPDFView.currentPage?.annotations ?? []{
            self.mPDFView.currentPage?.removeAnnotation(annot)
        }
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
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is LibraryListModelViewController{
            App_Constants.UI.tabbarIsHidden.accept(false)
            App_Constants.UI.statusBarIsHidden.accept(false)
        }else if viewController is PDFViewerViewController{
            App_Constants.UI.tabbarIsHidden.accept(true)
            self.mPDFView.autoScales = true
            self.view.layoutSubviews()
            self.view.layoutIfNeeded()
        }
    }
}

extension PDFViewerViewController: ExpandableViewDelegate{
    func goToOutline(_ outline: PDFOutline) {
        if let presented = self.presentedViewController as? UINavigationController{
            presented.dismiss(animated: true, completion: nil)
            self.mPDFView.go(to: outline.destination ?? PDFDestination())
        }
    }
    
}

extension PDFViewerViewController:PDFDocumentDelegate{
    func didMatchString(_ instance: PDFSelection) {
        self._Selections.append(instance)
        if instance.pages.contains(self.mPDFView.currentPage ?? PDFPage()) && self.mPDFView.currentPage?.annotations.isEmpty ?? true{
            self._CurrentSearchedPageIndex = self._Selections.firstIndex(of: instance) ?? 0
            for ann in self.mPDFView.currentPage?.annotations ?? []{
                self.mPDFView.currentPage?.removeAnnotation(ann)
            }
            let annot = PDFAnnotation.init(bounds: self._Selections[self._CurrentSearchedPageIndex].bounds(for: self._Selections[self._CurrentSearchedPageIndex].pages.first ?? PDFPage()), forType: .highlight, withProperties: nil)
            annot.color = .orange
            self.mPDFView.currentPage?.addAnnotation(annot)
        }
    }
}
