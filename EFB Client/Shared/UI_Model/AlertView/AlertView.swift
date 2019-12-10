

import UIKit

class AlertView: UIView {

    private var view: UIView!
    private var kAlertView = "AlertView"
    
    private var _title:String?
    private var message:String?
    private var doneButtonTapped:(()->Void)?
    
    @IBOutlet var mMainView: UIView!
    @IBOutlet weak var mTitle: UILabel!
    @IBOutlet weak var mMessage: UILabel!
    @IBOutlet weak var mButton: UIButton!
    
    
    
    convenience init(title: String, message: String, done: (()->Void)?){
        self.init()
        self._title = title
        self.message = message
        doneButtonTapped = done
        _Initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func _ButtonTapped(_ sender: Any) {
        changeUserInteraction(true)
        doneButtonTapped?()
        self.animHide()
    }
    
}

extension AlertView{
    
    private func _Initialize() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: kAlertView, bundle: bundle)
        view = nib.instantiate(withOwner: self, options: nil).first as? UIView
        view.frame = self.frame
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.mButton.cornerRadius = 5
        self.mButton.border(1, App_Constants.Instance.Color(.dark))
        let width = UIScreen.main.bounds.size.width * 0.4
        self.frame.size.width = width
        self.mTitle.text = _title
        self.mMessage.text = message
        let titleHeight = _title?.height(withConstrainedWidth: width - 24, font: App_Constants.Instance.Font(.semiBold, 17)) ?? 0
        let messageHeight = message?.height(withConstrainedWidth: width - 24, font: App_Constants.Instance.Font(.regular, 15)) ?? 0
        let height = titleHeight + messageHeight + 120
        self.frame.size.height = height
        self.center = CGPoint.init(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.height + height)
        self.cornerRadius = 5
        view.cornerRadius = 5
        view.border(1, App_Constants.Instance.Color(.dark))
    }
    
    public func show(){
        if let view = UIApplication.shared.keyWindow?.subviews.first(where: {$0 is AlertView}){
            view.removeFromSuperview()
        }
        UIApplication.shared.keyWindow?.addSubview(self)
        changeUserInteraction(false)
        self.animShow()
    }
    
    private func animShow(){
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.center.y = UIScreen.main.bounds.midY
        }, completion: nil)
    }
    
    private func animHide(){
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.center.y += UIScreen.main.bounds.height
            self.layoutIfNeeded()
        }, completion: {f in
            self.removeFromSuperview()
        })
    }
    
    private func changeUserInteraction(_ enable: Bool){
        self.superview?.subviews.forEach({view in
            if view != self{
                view.isUserInteractionEnabled = enable
            }
        })
    }
}
