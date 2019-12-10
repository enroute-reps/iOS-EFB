

import UIKit
import PDFKit

let kExpandableViewHeight:CGFloat = 44

protocol HeaderExpandableViewDelegate{
    func outline(_ outline: PDFOutline)
}

class HeaderExpandableView: UIView {
    private var mainStack: UIStackView!
    private var innerStack:UIStackView!
    private var sourceView: SourceExpandableView!
    private var outline:PDFOutline?
    private var delegate:HeaderExpandableViewDelegate?
    
    convenience init(outline: PDFOutline, delegate: HeaderExpandableViewDelegate){
        self.init()
        self.outline = outline
        self.delegate = delegate
        _Initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

extension HeaderExpandableView {
    private func _Initialize(){
        mainStack = UIStackView()
        mainStack.alignment = .center
        mainStack.axis = .vertical
        mainStack.distribution = .fillProportionally
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(mainStack)
        mainStack.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        mainStack.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        mainStack.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        mainStack.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        sourceView = SourceExpandableView.init(outline: self.outline ?? PDFOutline(), text: outline?.label ?? "", isExpandable: (outline?.numberOfChildren ?? 0) > 0, delegate: self, index: 0)
        sourceView.translatesAutoresizingMaskIntoConstraints = false
        mainStack.addArrangedSubview(sourceView)
        sourceView.widthAnchor.constraint(equalTo: mainStack.widthAnchor).isActive = true
        sourceView.heightAnchor.constraint(equalToConstant: kExpandableViewHeight).isActive = true
        innerStack = UIStackView()
        innerStack.alignment = .fill
        innerStack.axis = .vertical
        innerStack.distribution = .fill
        innerStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.addArrangedSubview(innerStack)
        innerStack.widthAnchor.constraint(equalTo: mainStack.widthAnchor, multiplier: 0.9).isActive = true
        innerStack.isHidden = true
        
    }
    
    private func generateInnerViews(){
        innerStack.arrangedSubviews.forEach({
            innerStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        })
        for c in 0..<(outline?.numberOfChildren ?? 0){
            let v = HeaderExpandableView.init(outline: outline?.child(at: c) ?? PDFOutline(), delegate: self)
            v.isHidden = true
            innerStack.addArrangedSubview(v)
            
        }
    }
    
}

extension HeaderExpandableView: HeaderExpandableViewDelegate{
    func outline(_ outline: PDFOutline){
        delegate?.outline(outline)
    }
}

extension HeaderExpandableView: SourceExpandableViewDelegate{
    func moreButtonTapped(at inde: Int, show: Bool) {
        if innerStack.subviews.count == 0{
            self.generateInnerViews()
        }
        self.innerStack.isHidden.toggle()
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: [.showHideTransitionViews,.curveEaseInOut], animations: {
            self.innerStack.subviews.forEach({$0.isHidden.toggle()})
            self.innerStack.layoutIfNeeded()
        }, completion: {f in
            
        })
    }
    
    func outlineTapped(_ outline: PDFOutline) {
        delegate?.outline(outline)
    }
}




protocol SourceExpandableViewDelegate{
    func moreButtonTapped(at index: Int, show: Bool)
    func outlineTapped(_ outline: PDFOutline)
}

class SourceExpandableView: UIView {
    
    private var label:UILabel!
    private var openButton:UIButton!
    private var outlineButton:UIButton!
    private var isExpandable:Bool = false
    private var text:String = ""
    private var delegate:SourceExpandableViewDelegate?
    private var index:Int?
    private var outline:PDFOutline?
    
    convenience init(outline: PDFOutline ,text: String, isExpandable: Bool, delegate: SourceExpandableViewDelegate, index: Int){
        self.init()
        self.outline = outline
        self.text = text
        self.isExpandable = isExpandable
        self.delegate = delegate
        self.index = index
        _Initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}


extension SourceExpandableView{
    
    private func _Initialize(){
        openButton = UIButton()
        openButton.setImage(App_Constants.Instance.Image(.forward), for: .normal)
        openButton.setTitle("", for: .normal)
        openButton.tintColor = .white
        openButton.translatesAutoresizingMaskIntoConstraints = false
        openButton.addTarget(self, action: #selector(_OpenButtonTapped(_:)), for: .touchUpInside)
        self.addSubview(openButton)
        openButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        openButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        openButton.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5).isActive = true
        openButton.widthAnchor.constraint(equalToConstant: isExpandable ? 40 : 0).isActive = true
        label = UILabel()
        label.text = self.text
        label.font = App_Constants.Instance.Font(.regular, 13)
        label.numberOfLines = 1
        label.textColor = .white
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        label.leadingAnchor.constraint(equalTo:self.leadingAnchor,constant: 40).isActive = true
        label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        label.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        outlineButton = UIButton()
        outlineButton.setTitle("", for: .normal)
        outlineButton.addTarget(self, action: #selector(_OutlineButtonTapped(_:)), for: .touchUpInside)
        outlineButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(outlineButton)
        outlineButton.leadingAnchor.constraint(equalTo: label.leadingAnchor).isActive = true
        outlineButton.trailingAnchor.constraint(equalTo: label.trailingAnchor).isActive = true
        outlineButton.topAnchor.constraint(equalTo: label.topAnchor).isActive = true
        outlineButton.bottomAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
    }
    
    
    @objc private func _OpenButtonTapped(_ sender: UIButton){
        delegate?.moreButtonTapped(at: self.index ?? 0, show: self.openButton.transform == .identity)
        UIView.animate(withDuration: 0.3, animations: {
            self.openButton.transform = self.openButton.transform == .identity ? CGAffineTransform.init(rotationAngle: .pi/2) : .identity
        })
        
    }
    
    @objc private func _OutlineButtonTapped(_ sender: UIButton){
        delegate?.outlineTapped(self.outline ?? PDFOutline())
    }
    
}

