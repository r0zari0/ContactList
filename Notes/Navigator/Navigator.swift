
import Foundation
import UIKit

class Navigator {
    static let share = Navigator()
    
    func showContact(view: UIViewController, person: Model) {
        let vc = ContactVC(content: person)
            vc.delegate = view as? ContactUpdateDelegate
               
               view.addChild(vc)
               vc.view.frame = view.view.frame
               view.view.addSubview(vc.view)
               vc.didMove(toParent: view)
               
               vc.view.alpha = 0
               UIView.animate(withDuration: 0.5) {
                   vc.view.alpha = 1
               }
           }
}
