

import UIKit
import TransitionButton


class PopupViewController: UIViewController {
    
    @IBOutlet weak var mMainView: UIView!
    @IBOutlet weak var mTitleLabel: UILabel!
    @IBOutlet weak var mMessageLabel: UILabel!
    @IBOutlet weak var mLeftButton: TransitionButton!
    @IBOutlet weak var mRightButton: TransitionButton!
    
    
    public var _title:String = ""{
        didSet{
            self.mTitleLabel.text = _title
            self.mTitleLabel.isHidden = _title.isEmpty
        }
    }
    
    public var message:String = ""{
        didSet{
            self.mMessageLabel.text = message
            self.mMessageLabel.isHidden = message.isEmpty
        }
    }
    
    public var rightButtonTitle:String = ""{
        didSet{
            self.mRightButton.setTitle(rightButtonTitle, for: .normal)
        }
    }
    
    public var leftButtonTitle:String = ""{
        didSet{
            self.mLeftButton.setTitle(leftButtonTitle, for: .normal)
        }
    }
    
    
    public var leftButtonFunc:((TransitionButton,TransitionButton,UIViewController?)->Void)?
    public var rightButtonFunc:((TransitionButton,TransitionButton,UIViewController?)->Void)?
    
    convenience init(title: String, message: String, leftButtonTitle: String, rightButtonTitle: String, leftButtonFunc: ((TransitionButton,TransitionButton,UIViewController?)->Void)?, rightButtonFunc: ((TransitionButton,TransitionButton,UIViewController?)->Void)?){
        self.init()
        self._title = title
        self.message = message
        self.leftButtonTitle = leftButtonTitle
        self.rightButtonTitle = rightButtonTitle
        self.leftButtonFunc = leftButtonFunc
        self.rightButtonFunc = rightButtonFunc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self._Initialize()
    }
    
    
    @IBAction func _LeftButtonTapped(_ sender: Any) {
        leftButtonFunc?(mLeftButton,mRightButton,self)
    }
    
    @IBAction func _RightButtonTapped(_ sender: Any) {
        rightButtonFunc?(mRightButton,mLeftButton,self)
    }
    
}

extension PopupViewController{
    
    private func _Initialize(){
        self.mMainView.cornerRadius = 10
        self.mLeftButton.border(1, self.mRightButton.backgroundColor ?? App_Constants.Instance.Color(.light))
        self.mTitleLabel.text = _title
        self.mTitleLabel.isHidden = _title.isEmpty
        self.mMessageLabel.text = message
        self.mMessageLabel.isHidden = message.isEmpty
        self.mRightButton.setTitle(rightButtonTitle, for: .normal)
        self.mLeftButton.setTitle(leftButtonTitle, for: .normal)
    }
    
}
