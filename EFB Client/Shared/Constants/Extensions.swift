//
//  Extensions.swift
//  EFB Client
//
//  Created by Mr.Zee on 10/13/19.
//  Copyright © 2019 MehrPardaz. All rights reserved.
//

import Foundation
import UIKit
import PDFKit
import QuickLookThumbnailing
import AudioToolbox

extension UIColor{
    
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(
            format: "%02X%02X%02X",
            Int(r * 0xff),
            Int(g * 0xff),
            Int(b * 0xff)
        )
    }
    
}

extension UIView{
    
    public var cornerRadius:CGFloat{
        get{
            return self.layer.cornerRadius
        }
        set{
            self.layer.cornerRadius = newValue
        }
    }
    
    public var round:Bool{
        get{
            return self.layer.cornerRadius == self.frame.height / 2
        }
        
        set{
            self.cornerRadius = self.frame.height / 2
            self.layoutIfNeeded()
        }
    }
    
    func roundCorners(_ corners: CACornerMask, radius: CGFloat) {
        if #available(iOS 11.0, *) {
            self.clipsToBounds = true
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = corners
        } else {
            // Fallback on earlier versions
        }
    }
    
    func border(_ width: CGFloat = 1, _ color: UIColor = .white){
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
        self.clipsToBounds = true
    }
    
}

extension String{
    
    func formattedDate() -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        inputFormatter.timeZone = TimeZone.init(identifier: "UTC")
        if let date = inputFormatter.date(from: self) {
            let outputFormatter = DateFormatter()
            outputFormatter.timeZone = TimeZone.init(identifier: "UTC")
            outputFormatter.dateFormat = "MMM dd ',' yyyy '-' HH:mm'Z'"
            return outputFormatter.string(from: date)
        }
        return nil
    }
    
}

extension UIViewController {
    static func loadFromNib() -> Self {
        func instantiateFromNib<T: UIViewController>() -> T {
            return T.init(nibName: String(describing: T.self), bundle: nil)
        }
        
        return instantiateFromNib()
    }
}

extension TimeInterval{
    func format()->String{
        return autoreleasepool{()->String in
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.day,.hour,.minute,.second]
            formatter.unitsStyle = .full
            formatter.maximumUnitCount = 1
            return formatter.string(from: self) ?? ""
        }
    }
    
    func toString()->String{
        return "\(self.format())"
    }
}


extension String{
    
    func toDate()->Date{
        return autoreleasepool{()->Date in
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone.init(identifier: "UTC")
            formatter.dateFormat = "MMM dd ',' YYYY '-' HH:mm'Z'"
            return formatter.date(from: self) ?? Date()
        }
    }
    
    func defaultToDate()-> Date{
        return autoreleasepool{()->Date in
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone.init(identifier: "UTC")
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            return formatter.date(from: self) ?? Date()
        }
    }
    
    func toIsoDate()->Date{
        return autoreleasepool{
            let formatter = ISO8601DateFormatter()
            return formatter.date(from: self) ?? Date()
        }
    }
    
    var isEmail: Bool {
       let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,20}"
       let emailTest  = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
}

extension Date{
    
    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {
        let currentCalendar = Calendar.current
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }
        return end - start
    }
    
}


extension UIImageView{
    
    static let imageCache = NSCache<NSString, UIImage>()
    
    public func _GenerateThumbFromPDF(_ url: URL,_ placeHolder: UIImage? = UIImage()){
        autoreleasepool{
            if let cachedImage = UIImageView.imageCache.object(forKey: url.absoluteString as NSString){
                self.image = cachedImage
                return
            }
            DispatchQueue.main.async{
                self.image = placeHolder ?? UIImage()
            }
            DispatchQueue.global(qos: .background).async{
                guard let dc = PDFDocument.init(url: URL(string: url.absoluteString + ".pdf")!),
                    let page = dc.page(at: 0) else{return}
                let pageSize = page.bounds(for: .mediaBox)
                
                DispatchQueue.main.async{
                    let scale = UIScreen.main.scale
                    let screenSize = CGSize(width: pageSize.width * scale, height: pageSize.height * scale)
                    self.image = page.thumbnail(of: screenSize, for: .mediaBox)
                    UIImageView.imageCache.setObject(self.image ?? UIImage(), forKey: url.absoluteString as NSString)
                }
            }
        }
    }
}

extension String{
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.height)
    }
}

extension UIDevice{
    
    func vibrate(){
        UIImpactFeedbackGenerator.init(style: .medium).impactOccurred()
    }
    
    
}
