import Foundation

protocol RegistrableSupplementaryViewComponent: RegistrableComponent {
    static var kind: String { get }
}
