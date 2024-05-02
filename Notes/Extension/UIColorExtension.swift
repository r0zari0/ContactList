
import Foundation
import UIKit

//extension UIColor {
//    var rgbComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
//        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
//        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
//            return nil
//        }
//        return (red, green, blue, alpha)
//    }
//}
//
//extension UIColor {
//    func encode() -> Data? {
//        return try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
//    }
//    
//    static func decode(data: Data) -> UIColor? {
//        return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor
//    }
//}

extension UIColor {
    func encode() -> Data {
        return try! NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }
    
    static func decode(data: Data) -> UIColor? {
        return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor
    }
    
    var rgbComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return (red, green, blue, alpha)
        } else {
            return nil
        }
    }
}
