
import UIKit
import StoriesSDK

class StartViewController: UIViewController {
	

	@IBAction func tapOnMusic(_ sender: Any) {
		let vc = ViewController()
		vc.targetApp = .music
		self.present(vc, animated: true)
	}
	
	@IBAction func tapOnKinopoisk(_ sender: Any) {
		let vc = ViewController()
		vc.targetApp = .kinopoisk
		self.present(vc, animated: true)
	}
	@IBAction func tapOnUseMockData(_ sender: UISwitch) {
		YStoriesManager.needUseMockData = sender.isOn
	}
}
