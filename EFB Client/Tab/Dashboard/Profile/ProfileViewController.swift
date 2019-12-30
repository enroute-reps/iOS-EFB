

import UIKit
import RxSwift

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var mCloseButton: UIButton!
    @IBOutlet weak var mPersonalInfoView: UIView!
    @IBOutlet weak var mImageView: UIView!
    @IBOutlet weak var mImage: UIImageView!
    @IBOutlet weak var mNameLabel: UILabel!
    @IBOutlet weak var mRoleLabel: UILabel!
    @IBOutlet weak var mNationalIDLabel: UILabel!
    @IBOutlet weak var mPersonalIDLabel: UILabel!
    @IBOutlet weak var mCellphoneLabel: UILabel!
    @IBOutlet weak var mLinePhoneLabel: UILabel!
    @IBOutlet weak var mEmailLabel: UILabel!
    @IBOutlet weak var mLicenceInfoView: UIView!
    @IBOutlet weak var mCerExpireDateLabel: UILabel!
    @IBOutlet weak var mCerIssue: UILabel!
    @IBOutlet weak var mSettingView: UIView!
    @IBOutlet weak var mChangePassButton: UIButton!
    
    private var kUnrecorded = "Unrecorded"
    private var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self._Initialize()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mImageView.round = true
        mImage.round = true
    }
    
    @IBAction func _CloseButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func _ChangePassButtonTapped(_ sender: Any) {
        autoreleasepool{[weak self] in
            guard let weak = self else{return}
            let p = ChangePasswordViewController()
            p.modalPresentationStyle = .overCurrentContext
            weak.present(p, animated: true, completion: nil)
        }
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension ProfileViewController{
    
    private func _Initialize(){
        self.mPersonalInfoView.roundCorners([.layerMaxXMaxYCorner,.layerMaxXMinYCorner], radius: self.mPersonalInfoView.frame.size.height / 2)
        self.mLicenceInfoView.roundCorners([.layerMaxXMaxYCorner,.layerMaxXMinYCorner], radius: self.mPersonalInfoView.frame.size.height / 2)
        self.mSettingView.roundCorners([.layerMaxXMaxYCorner,.layerMaxXMinYCorner], radius: self.mPersonalInfoView.frame.size.height / 2)
        mImageView.round = true
        mImage.round = true
        mImageView.border()
        Sync.shared.user.asObservable().subscribe(onNext: {[weak self] user in
            guard let weak = self else{return}
            weak.mNameLabel.text = "\(user?.first_name ?? "") \(user?.last_name ?? "")"
            weak.mRoleLabel.text = user?.job_title ?? weak.kUnrecorded
            weak.mNationalIDLabel.text = user?.national_id ?? weak.kUnrecorded
            weak.mPersonalIDLabel.text = user?.personel_id ?? weak.kUnrecorded
            weak.mCellphoneLabel.text = user?.cell_phone ?? weak.kUnrecorded
            weak.mLinePhoneLabel.text = user?.stationary_phone ?? weak.kUnrecorded
            weak.mEmailLabel.text = user?.email_address ?? weak.kUnrecorded
            weak.mCerExpireDateLabel.text = (user?.licence ?? "").formattedDate() ?? weak.kUnrecorded
            autoreleasepool{
                let interval = (user?.licence?.defaultToDate() ?? Date()).timeIntervalSinceNow
                let distance = abs(Int((interval) / (24*60*60)))
                weak.mCerExpireDateLabel.textColor = (distance <= 90 && distance > 30) ? (App_Constants.Instance.Color(.defaultYellow)) : (distance <= 30 ? (App_Constants.Instance.Color(.defaultRed)) : (.white))
            }
            weak.mImage.sd_setImage(with: URL(string:  Api_Names.Main + Api_Names.image + (user?.profile_image ?? "")), completed: nil)
        }).disposed(by: disposeBag)
        
        Sync.shared.organization.asObservable().subscribe(onNext: {[weak self] org in
            guard let weak = self else{return}
            weak.mCerIssue.text = org?.organization_name ?? weak.kUnrecorded
        }).disposed(by: disposeBag)
    }
    
}
