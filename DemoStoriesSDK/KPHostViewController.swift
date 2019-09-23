import StoriesSDK

// KP не поддерживает темную тему
class KPHostViewController: ViewController {
    override func applyColorTheme(_ theme: YColorTheme) {
        view.backgroundColor = .white
    }
    
    override func makeDarkUI() {
        // метод должны вызываться в applyColorTheme(), но в KP поддержки темной темы нет, поэтому метод ничего не делает
    }
    
    override func makeLightUI() {
        // метод должны вызываться в applyColorTheme(), но в KP поддержки темной темы нет, поэтому метод ничего не делает
    }
}
