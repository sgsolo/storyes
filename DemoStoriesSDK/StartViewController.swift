
import UIKit
import StoriesSDK

let kIsColorThemeDark = "com.yandex.demo-stories.isColorThemeDark"

class StartViewController: UIViewController {
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var colorThemeSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        let isDark = UserDefaults.standard.bool(forKey: kIsColorThemeDark)
        applyColorTheme(YColorTheme(isDark))
        colorThemeSwitch.setOn(isDark, animated: false)
    }

	@IBAction func tapOnMusic(_ sender: Any) {
		let vc = MusicHostViewController()
		vc.targetApp = .music
		self.present(vc, animated: true)
	}
	
	@IBAction func tapOnKinopoisk(_ sender: Any) {
		let vc = KPHostViewController()
		vc.targetApp = .kinopoisk
		self.present(vc, animated: true)
	}
	@IBAction func tapOnUseMockData(_ sender: UISwitch) {
		YStoriesManager.needUseMockData = sender.isOn
	}
    
    @IBAction func colorThemeChanged(_ sender: UISwitch) {
        let isDark = sender.isOn
        applyColorTheme(YColorTheme(isDark))
    }
    
    func applyColorTheme(_ theme: YColorTheme) {
        var isDark = false
        var changeUIAnimating: () -> Void = makeDarkUI
        switch theme {
        case .dark:
            isDark = true
        case .light:
            changeUIAnimating = makeLightUI
        }
        UIView.animate(withDuration: 0.3) {
            changeUIAnimating()
        }
        UserDefaults.standard.set(isDark, forKey: kIsColorThemeDark)
    }
    
    private func makeDarkUI() {
        view.backgroundColor = UIColor.black
        buttons.forEach {
            $0.setTitleColor(.white, for: .normal)
            $0.backgroundColor = .lightGray
        }
        labels.forEach { $0.textColor = .white }
    }
    
    private func makeLightUI() {
        view.backgroundColor = UIColor.white
        buttons.forEach {
            $0.setTitleColor($0.tintColor, for: .normal)
            $0.backgroundColor = .clear
        }
        labels.forEach { $0.textColor = .black }
    }
}
