//
//  MessagesPreviewViewController.swift
//  EFB Client
//
//  Created by Mr.Zee on 10/14/19.
//  Copyright © 2019 MehrPardaz. All rights reserved.
//

import UIKit

class MessagesPreviewViewController: UIViewController {
    
    
    @IBOutlet weak var mTitleLabel: UILabel!
    @IBOutlet weak var mDescLabel: UILabel!
    @IBOutlet weak var mDateLabel: UILabel!
    
    public var _Message:Message?
    public var _Notification:Notification_Model?
    public var _Type:MessageType = .message
    private var _Seened_Notifications:[Log] = []
    
    private var kMessageReadDateTime = "message_read_date_time"
    private var kLogEvent = "NOTIFICATION_SEEN"
    private var kLogDesc = "RESET API"
    private var kLogDevice = "iOS App"
    private var kLogType = "notification"
    private var kLogIP = "::1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self._Initialize()
    }
    
}

extension MessagesPreviewViewController{
    
    private func _Initialize(){
        switch _Type{
        case .message:
            self.mDescLabel.text = _Message?.message_text ?? ""
            self.mTitleLabel.text = "\(_Message?.SFN ?? "") \(_Message?.SLN ?? "")"
            self.mDateLabel.text = (_Message?.message_date_time ?? "").formattedDate() ?? ""
            self._SeenMessage()
        case .notification:
            self.mTitleLabel.text = "\(_Notification?.notification_title ?? "")"
            self.mDescLabel.text = "\(_Notification?.notification_text ?? "")"
            self.mDateLabel.text = "\((_Notification?.notification_date_time ?? "").formattedDate() ?? "")"
            self._Seened_Notifications = App_Constants.Instance.LoadAllFormCore(.log_notification) ?? []
            self._MarkNotification()
        }
    }
    
    
    private func _SeenMessage(){
        if !((_Message?.message_read_date_time ?? "").isEmpty){
            return
        }
        HttpClient.http()._Post(relativeUrl: Api_Names.message_seen, body: Message_Seen_Body(messageId: self._Message?.message_id ?? 0), callback: {(s,m,r:Edit?) in
            if s{
                Sync.Log_Event(event: .message_seen, type: .message, id: "\(self._Message?.message_id ?? 0)", {s,m1 in
                    if s{
                        App_Constants.Instance.UpdateEntity(.message, self._Message?.message_read_date_time ?? "", (self._Message?.message_read_date_time ?? "") == "" ? "\("\(Date())".formattedDate() ?? "")":(self._Message?.message_read_date_time ?? ""), self.kMessageReadDateTime)
                        NotificationCenter.default.post(name: App_Constants.Instance.Notification_Name(.msg_seened), object: nil)
                    }
                })
            }
        })
    }
    
    private func _MarkNotification(){
        if self._Seened_Notifications.contains(where: {$0.log_type_id == _Notification?.notification_id}){
            return
        }
        Sync.Log_Event(event: .notification_seen, type: .notification, id: "\(self._Notification?.notification_id ?? 0)", {s,m in
            if s{
                App_Constants.Instance.SaveToCore(Log(log_id: nil, create_date_time: "\(Date())", log_description: self.kLogDesc, log_device: self.kLogDevice, log_event: self.kLogEvent, logip: self.kLogIP, user_id: 0, log_type: self.kLogType, log_type_id: self._Notification?.notification_id ?? 0), .log_notification)
                NotificationCenter.default.post(name: App_Constants.Instance.Notification_Name(.notif_seened), object: nil)
            }
        })
    }
    
}
