import UIKit
import StoriesSDK

class ViewController: UIViewController {
//    #warning("Temporary: just for UI testing")
    var storiesCarousel: UIViewController!
    var carosuelModule: UIViewController!
    var storiesManager: YStoriesManager!
    //    var fullScreen: FullScreenViewController!
    var startFrame: CGRect!
    var endFrame: CGRect!
	var targetApp: SupportedApp = .music
    
    override func viewDidLoad() {
        super.viewDidLoad()
		self.view.backgroundColor = .white
		addCloseButton()
		
        storiesManager = YStoriesManager(targetApp: targetApp, user: "user", experiments: [:], storiesManagerOutput: self)
        
        storiesCarousel = storiesManager.caruselViewController
        view.addSubview(storiesCarousel.view)
        storiesCarousel.view.translatesAutoresizingMaskIntoConstraints = false
        storiesCarousel.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        storiesCarousel.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        storiesCarousel.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        storiesCarousel.view.isUserInteractionEnabled = false
        
        storiesManager.loadStories()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        let h = storiesCarousel.preferredContentSize.height
        storiesCarousel.view.heightAnchor.constraint(equalToConstant: h).isActive = true
    }
	
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
        self.endFrame = frame
        self.presentedViewController?.dismiss(animated: true)
    }
    
    func fullScreenStoriesDidEnd(atStoryWith frame: CGRect) {
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
