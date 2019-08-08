import UIKit
import Stories_iOS

class ViewController: UIViewController {
    #warning("Temporary: just for UI testing")
    var storiesCarousel: CarouselPreviewViewController!
    var carosuelModule: CarouselPreviewModule!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let config = CarouselPreviewConfiguration(carouselWidth: UIScreen.main.bounds.width)
        let carosuelModule = CarouselPreviewAssembly.setup(withConfig: config)
        storiesCarousel = carosuelModule.view
        configureStoriesCarousel()
    }
    
    #warning("Temporary: just for UI testing")
    private func configureStoriesCarousel() {
        addChildViewController(storiesCarousel)
        view.addSubview(storiesCarousel.view)
        storiesCarousel.view.translatesAutoresizingMaskIntoConstraints = false
        storiesCarousel.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        storiesCarousel.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        storiesCarousel.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        storiesCarousel.view.heightAnchor.constraint(equalToConstant: 500).isActive = true
        storiesCarousel.didMove(toParentViewController: self)
    }
}
