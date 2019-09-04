
import UIKit

extension UIFont {
	
	static let loadAllFonts: () = {
		registerFontWith(filenameString: "Graphik Kinopoisk LC-Regular.otf")
		registerFontWith(filenameString: "Graphik Kinopoisk LC-Medium.otf")
		registerFontWith(filenameString: "Graphik Kinopoisk LC-Semibold.otf")
		registerFontWith(filenameString: "Graphik Kinopoisk LC-Semibold Italic.otf")
		registerFontWith(filenameString: "Graphik Kinopoisk LC-Bold.otf")
		registerFontWith(filenameString: "Graphik Kinopoisk LC-Bold Italic.otf")
		registerFontWith(filenameString: "Graphik Kinopoisk LC-Light.otf")
	}()
	
	static func registerFontWith(filenameString: String) {
		let frameworkBundle = Bundle(for: YStoriesManager.self)
		
		if let path = frameworkBundle.path(forResource: filenameString, ofType: nil),
			let fontData = NSData(contentsOfFile: path),
			let dataProvider = CGDataProvider(data: fontData),
			let fontRef = CGFont(dataProvider) {
			
			var errorRef: Unmanaged<CFError>? = nil
			if (CTFontManagerRegisterGraphicsFont(fontRef, &errorRef) == false) {
				print("Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
			}
		}
	}
}

// Kinopoisk Fonts
extension UIFont {
	enum KinopoiskFontWeight: String {
		case regular = "Regular"
		case medium = "Medium"
		case semibold = "Semibold"
		case semiboldItalic = "SemiboldItalic"
		case bold = "Bold"
		case boldItalic = "BoldItalic"
		case light = "Light"
	}
	
	class func kinopoiskFont(ofSize: CGFloat, weight: UIFont.KinopoiskFontWeight) -> UIFont {
		let kinopoiskFontFamilyName = "GraphikKinopoiskLC-"
		return UIFont(descriptor: UIFontDescriptor(name: kinopoiskFontFamilyName + weight.rawValue, size: 0), size: ofSize)
	}
}
