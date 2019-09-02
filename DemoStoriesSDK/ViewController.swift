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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storiesManager = YStoriesManager(currentApp: .music, user: "user", experiments: [:], storiesManagerOutput: self)
        
        storiesCarousel = storiesManager.caruselViewController
        view.addSubview(storiesCarousel.view)
        storiesCarousel.view.translatesAutoresizingMaskIntoConstraints = false
        storiesCarousel.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        storiesCarousel.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        storiesCarousel.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        storiesCarousel.view.heightAnchor.constraint(equalToConstant: 500).isActive = true
        storiesCarousel.view.isUserInteractionEnabled = false
        
        storiesManager.loadStories()
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
