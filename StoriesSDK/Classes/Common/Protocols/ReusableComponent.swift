import Foundation

protocol ReusableComponent {
    static var identifier: String { get }
}

import UIKit

extension ReusableComponent where Self: UIView {
    static var identifier: String {
        return String(describing: self.classForCoder())
    }
}
