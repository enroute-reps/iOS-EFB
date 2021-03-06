

import Foundation

struct Global<T:Codable>:Codable{
    public var data:T?
    public var message:String?
    
    enum CodingKeys:String,CodingKey{
        case message = "message"
        case data = "data"
    }
    
    init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = (try container.decodeIfPresent(String.self, forKey: .message)) ?? ""
        do{
            data = try container.decodeIfPresent(T.self, forKey: .data)
        }catch (let err) {
            data = nil
            print(err)
        }
    }
}

struct GlobalArray<T:Codable>:Codable{
    public var data:[T]?
    public var message:String?
    
    enum CodingKeys:String,CodingKey{
        case message = "message"
        case data = "data"
    }
    
    init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do{
            message = (try container.decodeIfPresent(String.self, forKey: .message)) ?? ""
        }catch {
            message = ""
        }
        do{
            data = try container.decodeIfPresent([T].self, forKey: .data)
        }catch (let err) {
            data = nil
            print(err)
        }
    }
}

struct Edit:Codable{
    public var fieldCount:Int?
    public var affectedRows:Int?
    public var insertid:Int?
    public var serverStatus:Int?
    public var warningCount:Int?
    public var message:String?
    public var protocol41:Bool?
    public var changedRows:Int?
}

struct EFBUser : Codable{
    public var user_id : Int?
    public var user_description:String?
    public var email_address:String?
    public var first_name:String?
    public var last_name:String?
    public var password:String?
    public var role:String?
    public var user_status:Int?
    public var username:String?
    public var job_title:String?
    public var licence:String?
    public var address:String?
    public var cell_phone:String?
    public var certificate_issuer:String?
    public var national_id:String?
    public var personel_id:String?
    public var stationary_phone:String?
    public var profile_image:String?
}

struct Message:Codable, Equatable{
    static func ==(lhs: Message, rhs: Message) -> Bool {
        return lhs.message_id == rhs.message_id
    }
    
    public var message_id:Int?
    public var message_date_time:String?
    public var message_read_date_time:String? = ""
    public var message_status:String?
    public var message_text:String?
    public var reciever_id:Int?
    public var sender_id:Int?
    public var RID:Int?
    public var RFN:String?
    public var RLN:String?
    public var SID:Int?
    public var SFN:String?
    public var SLN:String?
}

struct Notification_Model:Codable{
    public var notification_id:Int?
    public var notification_audiance:String?
    public var notification_date_time:String?
    public var notification_text:String?
    public var notification_title:String?
    public var notification_status:String?
}

struct Log:Codable{
    public var log_id:Int?
    public var create_date_time:String?
    public var log_description:String?
    public var log_device:String?
    public var log_event:String?
    public var logip:String?
    public var user_id:Int?
    public var log_type:String?
    public var log_type_id:Int?
}

struct Manual:Codable{
    public var manual_id:Int?
    public var manual_description:String?
    public var manual_file_name:String?
    public var manual_version:String?
    public var upload_date:String?
    public var manual_title:String?
    public var aircraft_type:String?
    public var manual_category:String?
    public var manual_status:String?
    public var is_folder:Bool? = false
}

struct Organization:Codable{
    public var organization_id:Int?
    public var organization_name:String?
    public var organization_licence:Int?
    public var organization_cert_validity:String?
    public var organization_address:String?
    public var organization_tel:String?
    public var organization_email:String?
    public var organization_status:Int?
    public var organization_logo:String?
}

struct Legal:Codable{
    public var lastUpdate:String?
    public var privacyPolicy:String?
    public var licenceAgreement:String?
}

struct WeatherResponse:Codable{
    public var request_index:Int?
    public var data_source:String?
    public var request:String?
    public var errors:String?
    public var warnings:String?
    public var time_taken_ms:Int?
    public var data:[Weather]?
}


struct Weather:Codable{
    public var raw_text:String?
    public var station_id:String?
    public var observation_time:String?
    public var latitude:Double?
    public var longitude:Double?
    public var temp_c:Double?
    public var dewpoint_c:Double?
    public var wind_dir_degrees:Double?
    public var wind_speed_kt:Double?
    public var visibility_statute_mi:Double?
    public var altim_in_hg:Double?
    public var quality_control_flags:WeatherQualityControlFlags?
    public var sky_condition:WeatherSkyCondition?
    public var flight_category:String?
    public var metar_type:String?
    public var elevation_m:Double?
}


struct WeatherQualityControlFlags:Codable{
    public var no_signal:Bool?
}

struct WeatherSkyCondition:Codable{
    public var sky_cover:String?
    public var cloud_base_ft_agl:Int?
}

struct LoginBody:Codable{
    public var username:String
    public var password:String
}

struct Message_Seen_Body:Codable{
    public var messageId:Int?
}

struct Change_Password_Body:Codable{
    public var oldPassword:String?
    public var newPassword:String?
}

struct Log_Events:Codable{
    public var event:String
    public var description:Log_Desc_Body
}

struct Log_Desc_Body:Codable{
    public var device:String = "iOS Device"
    public var type:String
    public var id:String?
}

struct Feedback_Body:Codable{
    public var title:String
    public var text:String
}

struct FCMToken_Body:Codable{
    public var token:String
}

struct Email_Body:Codable{
    public var email:String
}
