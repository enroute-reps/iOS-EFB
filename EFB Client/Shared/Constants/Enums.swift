

import Foundation

public enum SettingsApp: String{
    case Token
    case IsFirstStart
    case UserId
    case UserInfo
    case auto_lock
    case version_app
    case server
    case FCMToken
    case legal_time
}

public enum Images:String{
    case message = "message"
    case notification = "notification"
    case download = "download"
    case pdf = "pdf"
    case revision = "revision"
    case check = "check"
    case folder = "folder"
    case forward = "forward"
}

public enum Cell:String{
    case cell = "cell"
    case Cell = "Cell"
}

public enum Color:String{
    case white = "FFFFFF"
    case light = "4468C1"
    case preDark = "1F3154"
    case green = "07A316"
    case red = "D60505"
    case lightBlue = "00e1ff"
    case dark = "18253A"
    case selected = "4C6FD0"
    case gray = "BFC1C1"
}

public enum Notification_Name:String{
    case sync_all = "sync_all"
    case `default` = "default"
    case notif_seen = "notif_seen"
    case notif_seened = "notif_seened"
    case msg_seen = "msg_seen"
    case msg_seened = "msg_seened"
    case tabbar_height = "tabbar_height"
    case hide_statusBar = "hide_statusBar"
    case revision = "revision"
    case syncing = "syncing"
    case sync_finished = "sync_finished"
    case to_login = "to_login"
    case notification_recieved = "notification_recieved"
    case logout = "logout"
}

public enum FontType:String{
    case regular = "KohinoorBangla-Regular"
    case medium = "KohinoorBangla-Medium"
    case bold = "KohinoorBangla-Bold"
    case semiBold = "KohinoorBangla-Semibold"
    case light = "KohinoorBangla-Light"
}

public enum Text:String{
    case time_out = "time-out"
    case try_again = "try-again"
    case support_mail = "support-mail"
    case password_changed_s = "password-changed-s"
    case no_connection = "no-connection"
    case sync_completed = "sync-completed"
    case logout = "logout"
    case logout_message = "logout-message"
    case yes = "yes"
    case accept = "accept"
    case no = "no"
    case cancel = "cancel"
    case warning = "warning"
    case unknown = "unknown"
    case message_seen_failed = "message-seen-failed"
    case notification_seen_failed = "notification-seen-failed"
    case sort_by_name = "sort-by-name"
    case sort_by_date = "sort-by-date"
    case load_manual_failed = "load-manual-failed"
    case message_not_sent = "message-not-sent"
    case message_sent = "message-sent"
    case feedback = "feedback"
    case logout_failed = "logout_failed"
    case expire_library_message = "expire_library_message"
    case email_not_verified = "email_not_verified"
    case email_not_valid = "email_not_valid"
}

public enum SegueId:String{
    case login = "login"
    case direct = "direct"
    case preview = "preview"
    case profile = "profile"
    case help = "help"
    case reader = "reader"
}

public enum EntityName:String{
    case user = "Users"
    case message = "Messages"
    case notification = "Notifications"
    case log_notification = "Notifications_Log"
    case manual = "Manuals"
    case organization = "Organizations"
}

public enum Log_Event:String{
    case notification_seen = "NOTIFICATION_SEEN"
    case message_seen = "MESSAGE_SEEN"
    case logout = "LOGOUT"
    case manual_downloaded = "MANUAL_DOWNLOADED"
    case sync = "DATA_SYNCED"
    case legal_accepted = "LEGAL_ACCEPTED"
}

public enum Log_Event_Type:String{
    case notification = "notification"
    case message = "message"
    case logout = "logout"
    case manual = "manual"
    case sync = "sync"
    case legal = "legal"
}
