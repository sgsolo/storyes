import Foundation

protocol RegistrableComponent: ReusableComponent {
    static var registrableSource: RegistrableSource { get }
}

import UIKit

extension RegistrableComponent where Self: UIView {
    static var registrableSource: RegistrableSource {
        return .class
    }
}
