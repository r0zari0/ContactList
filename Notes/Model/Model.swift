
import Foundation
import UIKit

class Model: Codable {
    var name: String
    var phone: String
    var address: String?
    var password: String?
    var category: String
    var imageData: Data?
    
    init(name: String, phone: String, image: UIImage, address: String?, category: String, password: String? = nil) {
        self.name = name
        self.phone = phone
        self.password = password
        self.address = address
        self.category = category
        self.imageData = image.jpegData(compressionQuality: 1.0)
    }
}
