
import UIKit

class MyTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    // MARK: - Setup
    
    func setupTabBar() {
        self.navigationController?.isNavigationBarHidden = true
        
           let peopleListVC = PeopleListVC()
           let settingVC = SettingsVC()
           
        let notSelectedImage = UIImage(systemName: "person.crop.circle.fill")?.withTintColor(.myDarkPerple, renderingMode: .alwaysOriginal)
        let selectedImage = UIImage(systemName: "person.crop.circle.fill")?.withTintColor(.myPerple, renderingMode: .alwaysOriginal)
           peopleListVC.tabBarItem = UITabBarItem(title: "List", image: notSelectedImage, selectedImage: selectedImage)
           peopleListVC.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightGray], for: .normal)
           peopleListVC.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
           
        let notSelectedSettingImage = UIImage(systemName: "gearshape.fill")?.withTintColor(.myDarkPerple, renderingMode: .alwaysOriginal)
           let selectedSettingImage = UIImage(systemName: "gearshape.fill")?.withTintColor(.myPerple, renderingMode: .alwaysOriginal)
           settingVC.tabBarItem = UITabBarItem(title: "Settings", image: notSelectedSettingImage, selectedImage: selectedSettingImage)
        settingVC.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightGray], for: .normal)
        settingVC.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
           
           self.viewControllers = [peopleListVC, settingVC]
       }
}
