

import UIKit



class EFBTabbar: UIView {
    
    @IBOutlet var mMainView: UIView!
    @IBOutlet weak var mMainStack: UIStackView!
    @IBOutlet weak var mDashboardView: UIView!
    @IBOutlet weak var mDashboardImage: UIImageView!
    @IBOutlet weak var mDashboardLabel: UILabel!
    @IBOutlet weak var mSpaceView1: UIView!
    @IBOutlet weak var mLibraryView: UIView!
    @IBOutlet weak var mLibraryImage: UIImageView!
    @IBOutlet weak var mLibraryLabel: UILabel!
    @IBOutlet weak var mSpaceView2: UIView!
    @IBOutlet weak var mDashboardButton: UIButton!
    @IBOutlet weak var mLibraryButton: UIButton!
    @IBOutlet weak var mWeatherView: UIView!
    @IBOutlet weak var mWeatherImage: UIImageView!
    @IBOutlet weak var mWeatherLabel: UILabel!
    @IBOutlet weak var mWeatherButton: UIButton!
    
    
    private var view: UIView!
    private var selectedIndex:Int = 0
    private var user:EFBUser?
    public var isLibraryAvailable:Bool = true
    public var isWeatherAvailable:Bool = true

    public var currentIndex = 0
    public var delegate:EFBBarDelegate?
    
    private var kTabbar = "EFBTabbar"

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _Initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _Initialize ()
    }
    
    @IBAction func _DashboardButtonTapped(_ sender: Any) {
        self.selectedIndex = 0
        self.currentIndex = 0
        TabChanged(self.mDashboardImage, self.mDashboardLabel)
        delegate?.TabBar(self.currentIndex)
    }
    
    @IBAction func _LibraryButtonTapped(_ sender: Any) {
        if !isLibraryAvailable{
            App_Constants.UI.Make_Alert("", self.user?.user_status == 2 ? App_Constants.Instance.Text(.email_not_verified) : String(format: App_Constants.Instance.Text(.expire_library_message), 0))
            return
        }
        self.selectedIndex = 1
        self.currentIndex = 1
        TabChanged(self.mLibraryImage, self.mLibraryLabel)
        delegate?.TabBar(self.currentIndex)
    }

    @IBAction func _WeatherButtonTapped(_ sender: Any) {
        if !isWeatherAvailable{
            App_Constants.UI.Make_Alert("", self.user?.user_status == 2 ? App_Constants.Instance.Text(.email_not_verified) : String(format: App_Constants.Instance.Text(.expire_library_message), 0))
            return
        }
        self.selectedIndex = 2
        self.currentIndex = 2
        TabChanged(self.mWeatherImage, self.mWeatherLabel)
        delegate?.TabBar(self.currentIndex)
    }
}

extension EFBTabbar {
    
    private func _Initialize() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: kTabbar, bundle: bundle)
        view = nib.instantiate(withOwner: self, options: nil).first as? UIView
        view.frame = self.frame
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        self.mMainView.roundCorners([.layerMinXMinYCorner,.layerMaxXMinYCorner], radius: 25)
        self.mSpaceView1.cornerRadius = 10
        self.mSpaceView2.cornerRadius = 10
        
        self.user = App_Constants.Instance.LoadUser()
//        self.isLibraryAvailable = (user?.licence?.formattedDate()?.toDate() ?? Date()) >= Date() && user?.user_status != 2
//        self.isWeatherAvailable = (user?.licence?.formattedDate()?.toDate() ?? Date()) >= Date() && user?.user_status != 2
        if !self.isLibraryAvailable{
            self.mLibraryImage.tintColor = .gray
            self.mLibraryLabel.textColor = .gray
        }
        
        if !self.isWeatherAvailable{
            self.mWeatherImage.tintColor = .gray
            self.mWeatherLabel.textColor = .gray
        }
    }
    
    private func TabChanged(_ selectedImage:UIImageView, _ selectedLabel:UILabel){
        self.mDashboardImage.tintColor = App_Constants.Instance.Color(.dark)
        self.mDashboardLabel.textColor = App_Constants.Instance.Color(.dark)
        if isLibraryAvailable{
            self.mLibraryImage.tintColor = App_Constants.Instance.Color(.dark)
            self.mLibraryLabel.textColor = App_Constants.Instance.Color(.dark)
        }
        if isWeatherAvailable{
            self.mWeatherImage.tintColor = App_Constants.Instance.Color(.dark)
            self.mWeatherLabel.textColor = App_Constants.Instance.Color(.dark)
        }
        selectedImage.tintColor = .white
        selectedLabel.textColor = .white
    }
    
    public func gotoIndex(_ index: Int){
        if index == 0 {
            _DashboardButtonTapped(self)
        }else if index == 1 && isLibraryAvailable{
            _LibraryButtonTapped(self)
        }else if index == 2 && isWeatherAvailable{
            _WeatherButtonTapped(self)
        }
        delegate?.TabBar(index)
    }
    
}

protocol EFBBarDelegate {
    func TabBar(_ index:Int)
}
