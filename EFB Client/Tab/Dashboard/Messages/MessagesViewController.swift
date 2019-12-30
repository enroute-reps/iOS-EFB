

import UIKit
import Alamofire
import RxSwift
import RxCocoa

enum MessageType{
    case message
    case notification
}

class MessagesViewController: UIViewController {
    
    @IBOutlet weak var mTableView: UITableView!
    
    public var _Type:MessageType = .message
    public var _DidShowNotif:BehaviorRelay<Bool> = BehaviorRelay(value: false)
    public var _DidShowMessage:BehaviorRelay<Bool> = BehaviorRelay(value: false)
    private var _SelectedIndex:IndexPath = [0,0]
    private var _Messages:[Message] = []
    private var _Notification:[Notification_Model] = []
    private var _Seened_Notifications:[Log] = []
    private var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self._Initialize()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? MessagesPreviewViewController{
            dest._Type = self._Type
            switch _Type{
            case .message:
                dest._Message = self._Messages[_SelectedIndex.row]
            case .notification:
                dest._Notification = self._Notification[_SelectedIndex.row]
            }
        }
    }

}

extension MessagesViewController{
    
    private func _Initialize(){
        switch _Type{
        case .message:
            self._LoadMessages()
        case .notification:
            self._LoadNotifications()
        }

        NotificationCenter.default.removeObserver(self, name: App_Constants.Instance.Notification_Name(.notification_recieved), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_NotificationRecieved), name: App_Constants.Instance.Notification_Name(.notification_recieved), object: nil)
    }
    
    private func _LoadMessages(){
        Sync.shared.messages.asObservable().subscribe(onNext: {[weak self] messages in
            guard let weak = self else{return}
            weak._Messages = messages ?? []
            weak.mTableView.reloadData()
        }).disposed(by: disposeBag)
    }
    
    private func _LoadNotifications(){
        Sync.shared.notifications.asObservable().subscribe(onNext: {[weak self] notifications in
            guard let weak = self else{return}
            weak._Notification = notifications ?? []
            weak.mTableView.reloadData()
        }).disposed(by: disposeBag)
        
        Sync.shared.synced_notifications.asObservable().subscribe(onNext: {[weak self] logs in
            guard let weak = self else{return}
            weak._Seened_Notifications = logs ?? []
            weak.mTableView.reloadData()
        }).disposed(by: disposeBag)
    }
    
    @objc private func _Reload(){
        switch _Type {
        case .message:
            self._LoadMessages()
        case .notification:
            self._LoadMessages()
        }
    }
    
    @objc private func _NotificationRecieved(_ notification: NSNotification){
        if let str = NotificationManager.data[kMessageId] as? String, let id = Int(str){
            if _Type == .message{
                goToMessage(IndexPath.init(row: _Messages.firstIndex(where: {$0.message_id == id}) ?? 0, section: 0))
            }
        }else if let str = NotificationManager.data[kNotificationId] as? String, let id = Int(str){
            if _Type == .notification{
                goToMessage(IndexPath.init(row: _Notification.firstIndex(where: {$0.notification_id == id}) ?? 0, section: 0))
            }
        }
    }
    
    private func goToMessage(_ indexPath: IndexPath){
        self._SelectedIndex = indexPath
        self.navigationController?.popToRootViewController(animated: true)
        switch _Type{
        case .message:
            if !(_Messages[indexPath.row].message_read_date_time?.isEmpty ?? true){
                App_Constants.UI.performSegue(self, .preview)
                self._DidShowMessage.accept(true)
            }else{
                if App_Constants.Instance.isReachable(){
                    App_Constants.UI.performSegue(self, .preview)
                    self._DidShowMessage.accept(true)
                }else{
                    App_Constants.UI.Make_Alert("", App_Constants.Instance.Text(.no_connection))
                }
            }
        case .notification:
            if _Seened_Notifications.contains(where: {$0.log_type_id == self._Notification[indexPath.row].notification_id}){
                App_Constants.UI.performSegue(self, .preview)
                self._DidShowNotif.accept(true)
            }else{
                if App_Constants.Instance.isReachable(){
                    App_Constants.UI.performSegue(self, .preview)
                    self._DidShowNotif.accept(true)
                }else{
                    App_Constants.UI.Make_Alert("", App_Constants.Instance.Text(.no_connection))
                }
            }
        }
    }
    
}


extension MessagesViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch _Type {
        case .message:
            return self._Messages.count
        case .notification:
            return self._Notification.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return autoreleasepool{[weak self] ()-> UITableViewCell in
            guard let weak = self else{return UITableViewCell()}
            let cell = tableView.dequeueReusableCell(withIdentifier: App_Constants.Instance.Cell(.cell)) as! MessagesTableViewCell
            cell.cornerRadius = 5
            switch _Type{
            case .message:
                cell.mImage.image = App_Constants.Instance.Image(.message)
                cell.mSeenViewWidth.constant = (weak._Messages[indexPath.row].message_read_date_time ?? "").isEmpty ? 10 : 0
                cell.mDateLabel.text = (weak._Messages[indexPath.row].message_date_time ?? "").formattedDate() ?? ""
                cell.mTitleLabel.text = "\(weak._Messages[indexPath.row].SFN ?? "") \(weak._Messages[indexPath.row].SLN ?? "")"
            case .notification:
                cell.mImage.image = App_Constants.Instance.Image(.notification)
                cell.mSeenViewWidth.constant = weak._Seened_Notifications.contains(where: {$0.log_type_id == weak._Notification[indexPath.row].notification_id}) ? 0 : 10
                cell.mDateLabel.text = (weak._Notification[indexPath.row].notification_date_time ?? "").formattedDate() ?? ""
                cell.mTitleLabel.text = weak._Notification[indexPath.row].notification_title
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToMessage(indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}
