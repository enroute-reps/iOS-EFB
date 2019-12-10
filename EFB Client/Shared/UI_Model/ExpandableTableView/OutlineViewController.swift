

import UIKit
import PDFKit

class OutlineViewController: UIViewController {
    
    private var outline:PDFOutline?
    private var delegate:ExpandableViewDelegate?
    
    convenience init(outline: PDFOutline, delegate: ExpandableViewDelegate){
        self.init()
        self.outline = outline
        self.delegate = delegate
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        _Initialize()
    }
}

extension OutlineViewController{
    
    private func _Initialize(){
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        self.view.backgroundColor = App_Constants.Instance.Color(.light)
        let table = ExpandableView.init(dataSource: self.outline ?? PDFOutline(), delegate: delegate!)
        table.frame.size = CGSize.init(width: self.view.frame.size.width, height: self.view.frame.size.height)
        table.center = self.view.center
        table.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(table)
        table.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        table.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
        table.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        table.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    
    
}
