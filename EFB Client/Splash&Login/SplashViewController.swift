

import UIKit
import SwiftyGif
import RxSwift

class SplashViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBOutlet weak var mImage: UIImageView!
    
    private var gifDidEnd = false{
        didSet{
            if syncDidEnd && gifDidEnd{
                self._RemoveImage()
                App_Constants.UI.changeRootController(canGoDirect ? "main" : "login")
            }else if gifDidEnd && !canGoDirect{
                self._RemoveImage()
                App_Constants.UI.changeRootController("login")
            }
        }
    }
    private var syncDidEnd = false{
        didSet{
            if syncDidEnd && gifDidEnd{
                self._RemoveImage()
                App_Constants.UI.changeRootController(canGoDirect ? "main" : "login")
            }
        }
    }
    private var canGoDirect = false
    private let kIntroGif = "intro.gif"
    private var disposeBag = DisposeBag()
    private var subscribe:Disposable?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self._Initialize()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        subscribe?.dispose()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension SplashViewController{
    
    private func _Initialize(){
        self.canGoDirect = false
        self.gifDidEnd = false
        self.syncDidEnd = false
        self._LoadGif()
        if App_Constants.Instance.Account_Check(){
            self._Sync()
            canGoDirect = true
        }else{
            canGoDirect = false
        }
    }
    
    private func _LoadGif(){
        autoreleasepool{[weak self] in
            guard let weak = self else{return}
            do{
                let gif = try UIImage(gifName: kIntroGif)
                weak.mImage.setGifImage(gif)
                weak.mImage.loopCount = 1
                weak.mImage.delegate = self
            }catch(let err){
                print(err.localizedDescription)
            }
        }
    }
    
    private func _Sync(){
        Sync.shared.syncUser()
        self.subscribe = Sync.shared.sync_finished.asObservable().subscribe(onNext: {[weak self] s in
            guard let weak = self else{return}
            weak.syncDidEnd = s
        })
        subscribe?.disposed(by: disposeBag)
        
    }
    
    private func _RemoveImage(){
        SwiftyGifManager.defaultManager.clear()
        self.mImage.delegate = nil
        self.mImage.stopAnimatingGif()
    }
}

extension SplashViewController:SwiftyGifDelegate{
    func gifDidStop(sender: UIImageView) {
        self.gifDidEnd = true
    }
}
