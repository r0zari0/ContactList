
import UIKit

class Cell: UITableViewCell
{
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var myView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.textColor = .white
        phoneLabel.textColor = .white
        
        myView.layer.cornerRadius = 10
        myView.backgroundColor = .myDark
    }
    
    func config(model: Model) {
        nameLabel.text = model.name
        phoneLabel.text = model.phone
    }
}
