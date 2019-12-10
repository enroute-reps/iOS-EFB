

import UIKit

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
    private var _User:EFBUser?
    private var _Org:Organization?

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
        self._SetUser()
        NotificationCenter.default.removeObserver(self, name: App_Constants.Instance.Notification_Name(.sync_all), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_SetUser), name: App_Constants.Instance.Notification_Name(.sync_all), object: nil)
    }
    
    @objc private func _SetUser(){
        self._User = App_Constants.Instance.LoadUser()
        self._Org = App_Constants.Instance.LoadFromCore(.organization)
        self.mNameLabel.text = "\(self._User?.first_name ?? "") \(self._User?.last_name ?? "")"
        self.mRoleLabel.text = self._User?.job_title ?? kUnrecorded
        self.mNationalIDLabel.text = self._User?.national_id ?? kUnrecorded
        self.mPersonalIDLabel.text = self._User?.personel_id ?? kUnrecorded
        self.mCellphoneLabel.text = self._User?.cell_phone ?? kUnrecorded
        self.mLinePhoneLabel.text = self._User?.stationary_phone ?? kUnrecorded
        self.mEmailLabel.text = self._User?.email_address ?? kUnrecorded
        self.mCerExpireDateLabel.text = (self._User?.licence ?? "").formattedDate() ?? kUnrecorded
        autoreleasepool{
            let interval = (self._User?.licence?.defaultToDate() ?? Date()).timeIntervalSinceNow
            let distance = abs(Int((interval) / (24*60*60)))
            self.mCerExpireDateLabel.textColor = (distance <= 30 && distance > 10) ? (.orange) : (distance <= 10 ? (App_Constants.Instance.Color(.red)) : (.white))
        }
        self.mCerIssue.text = self._Org?.organization_name ?? kUnrecorded
        self.mImage.sd_setImage(with: URL(string:  Api_Names.Main + Api_Names.image + (self._User?.profile_image ?? "")), completed: nil)
    }
    
}
