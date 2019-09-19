import UIKit
import StoriesSDK
import AVFoundation

class ViewController: UIViewController {
//    #warning("Temporary: just for UI testing")
    var storiesCarousel: UIViewController!
    var carosuelModule: UIViewController!
    var storiesManager: YStoriesManager!
    //    var fullScreen: FullScreenViewController!
    var startFrame: CGRect!
    var endFrame: CGRect!
	var targetApp: SupportedApp = .music
	
	var playerSwitch = UISwitch()
	lazy var avPlayer: MusicalPlayer = {
		let url = Bundle.main.url(forResource: "ImagineDragons-Believer.mp3", withExtension: nil)
		return MusicalPlayer(url: url!)
	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.view.backgroundColor = .white
		
        storiesManager = YStoriesManager(targetApp: targetApp, user: "user", experiments: [:], storiesManagerOutput: self)
        storiesCarousel = storiesManager.caruselViewController
        view.addSubview(storiesCarousel.view)
        storiesCarousel.view.translatesAutoresizingMaskIntoConstraints = false
        storiesCarousel.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        storiesCarousel.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        storiesCarousel.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        storiesCarousel.view.heightAnchor.constraint(equalToConstant: 500).isActive = true
        storiesCarousel.view.isUserInteractionEnabled = false
        
        storiesManager.loadStories()
		
		if targetApp == .music {
			addPlayer()
		}
		addCloseButton()
    }

	deinit {
		NotificationCenter.default.removeObserver(self)
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
}

extension ViewController: YStoriesManagerOutput {
    func needShowFullScreen(_ fullScreen: FullScreenViewController, from frame: CGRect) {
        self.startFrame = frame
        fullScreen.transitioningDelegate = self
        presentFullScreenView(fullScreen: fullScreen)
    }
    
    func fullScreenDidTapOnCloseButton(atStoryWith frame: CGRect) {
		avPlayer.playIfNeeded()
        self.endFrame = frame
        self.presentedViewController?.dismiss(animated: true)
    }
    
    func fullScreenStoriesDidEnd(atStoryWith frame: CGRect) {
		avPlayer.playIfNeeded()
        self.endFrame = frame
        self.presentedViewController?.dismiss(animated: true)
    }
    
    private func presentFullScreenView(fullScreen: FullScreenViewController) {
        self.present(fullScreen, animated: true)
    }
    
    func storiesDidLoad(_ isSuccess: Bool, error: Error?) {
        if isSuccess {
            storiesCarousel.view.isUserInteractionEnabled = true
        } else if let error = error {
            let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ок", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
	
	func playPlayerIfNeeded() {
		avPlayer.playIfNeeded()
	}
	
	func stopPlayerIfNeeded() {
		avPlayer.pause()
	}
}

extension ViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FullScreenPresentAnimation(startFrame: self.startFrame)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FullScreenDismissedAnimation(endFrame: self.endFrame)
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
