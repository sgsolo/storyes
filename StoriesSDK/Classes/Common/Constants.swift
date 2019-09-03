
import Foundation

var isIphoneX: Bool {
	if #available(iOS 11.0, *) {
		return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0 > 0
	}
	return false
}
