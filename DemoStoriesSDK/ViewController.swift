import UIKit
import StoriesSDK
import AVFoundation

class ViewController: UIViewController {
    var storiesCarousel: UIViewController!
    var carosuelModule: UIViewController!
    var storiesManager: YStoriesManager!
	var targetApp: SupportedApp = .music
	
	var playerSwitch = UISwitch()
	lazy var avPlayer: MusicalPlayer = {
		let url = Bundle.main.url(forResource: "ImagineDragons-Believer.mp3", withExtension: nil)
		return MusicalPlayer(url: url!)
	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		addCloseButton()
        let isDark = UserDefaults.standard.bool(forKey: kIsColorThemeDark)
        let colorTheme = YColorTheme(isDark)
        applyColorTheme(colorTheme)
        YStoriesManager.configure(
            for: targetApp,
            with: colorTheme
        )
        storiesManager = YStoriesManager(
            storiesManagerOutput: self
        )
        storiesCarousel = storiesManager.caruselViewController
        self.addChildViewController(storiesCarousel)
        view.addSubview(storiesCarousel.view)
        storiesCarousel.view.translatesAutoresizingMaskIntoConstraints = false
        storiesCarousel.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        storiesCarousel.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        storiesCarousel.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        let h = CarouselPreviewSizeCalculator.carouselHeight(forWidth: view.bounds.width, targetApp: targetApp)
        storiesCarousel.view.heightAnchor.constraint(equalToConstant: h).isActive = true
        storiesCarousel.didMove(toParentViewController: self)
        storiesManager.loadStories()
		
		if targetApp == .music {
			addPlayer()
		}
		addCloseButton()
    }

	deinit {
		NotificationCenter.default.removeObserver(self)
	}
    
    // Может быть переопределен в подклассе
    func applyColorTheme(_ theme: YColorTheme) {
        switch theme {
        case .dark:
            makeDarkUI()
        case .light:
            makeLightUI()
        }
    }
    
    func makeDarkUI() {
        assertionFailure("Реализовать в подклассе")
    }
    
    func makeLightUI() {
        assertionFailure("Реализовать в подклассе")
    }
}

extension ViewController {
	func addCloseButton() {
		let button = UIButton(type: .custom)
		let bundle = Bundle(for: YStoriesManager.self)
		button.setImage(UIImage(named: "closeIcon", in: bundle, compatibleWith: nil), for: .normal)
		button.addTarget(self, action: #selector(closeButtonDidTap), for: .touchUpInside)
		button.layer.borderWidth = 4
		button.layer.cornerRadius = 20
		button.layer.borderColor = UIColor.black.cgColor
		self.view.addSubview(button)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16).isActive = true
		button.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 35).isActive = true
		button.heightAnchor.constraint(equalToConstant: 40).isActive = true
		button.widthAnchor.constraint(equalToConstant: 40).isActive = true
	}
	
	func addPlayer() {
		addPlayerButton()
		NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.avPlayer.currentItem, queue: .main) { [weak self] _ in
			self?.avPlayer.seek(to: kCMTimeZero)
			self?.avPlayer.play()
		}
	}
	
	func addPlayerButton() {
		self.view.addSubview(playerSwitch)
		playerSwitch.isOn = false
		playerSwitch.addTarget(self, action: #selector(playerSwitchDidTap), for: .touchUpInside)
		playerSwitch.translatesAutoresizingMaskIntoConstraints = false
		playerSwitch.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16).isActive = true
		playerSwitch.topAnchor.constraint(equalTo: storiesCarousel.view.bottomAnchor, constant: 35).isActive = true
		playerSwitch.heightAnchor.constraint(equalToConstant: 40).isActive = true
		playerSwitch.widthAnchor.constraint(equalToConstant: 60).isActive = true
		
		let label = UILabel()
		label.text = "Музыкальный плеер"
		self.view.addSubview(label)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16).isActive = true
		label.topAnchor.constraint(equalTo: storiesCarousel.view.bottomAnchor, constant: 35).isActive = true
		label.heightAnchor.constraint(equalToConstant: 20).isActive = true
		label.widthAnchor.constraint(equalToConstant: 2000).isActive = true
	}
	
	@objc private func playerSwitchDidTap(_ sender: UISwitch) {
		avPlayer.isPlaying = sender.isOn
		if sender.isOn {
			avPlayer.play()
		} else {
			avPlayer.pause()
		}
	}
	
	@objc private func closeButtonDidTap() {
		self.dismiss(animated: true)
	}
	
	private func showUrl(_ url: URL, fullScreen: FullScreenViewController) {
		fullScreen.dismiss(animated: true) {
			let alert = UIAlertController(title: "Открыт диплинк", message: url.absoluteString, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			self.present(alert, animated: true)
		}
	}
}

extension ViewController: YStoriesManagerOutput {
    func needShowFullScreen(_ fullScreen: FullScreenViewController) {
        self.present(fullScreen, animated: true)
    }
    
    func fullScreenDidTapOnCloseButton(fullScreen: FullScreenViewController) {
		avPlayer.playIfNeeded()
		fullScreen.dismiss(animated: true)
    }
    
    func fullScreenStoriesDidEnd(fullScreen: FullScreenViewController) {
		avPlayer.playIfNeeded()
		fullScreen.dismiss(animated: true)
    }
    
    func storiesDidLoad(_ isSuccess: Bool, error: Error?) {
		guard let error = error else { return }
		let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "ок", style: .default, handler: nil))
		self.present(alert, animated: true)
    }
	
	func playPlayerIfNeeded() {
		avPlayer.playIfNeeded()
	}
	
	func stopPlayerIfNeeded() {
		avPlayer.pause()
	}
	
	func openUrlIfPossible(url: URL, fullScreen: FullScreenViewController) {
		self.showUrl(url, fullScreen: fullScreen)
	}
}

class MusicalPlayer: AVPlayer {
	var isPlaying = false
	
	func playIfNeeded() {
		if isPlaying == true {
			play()
		}
	}
}
