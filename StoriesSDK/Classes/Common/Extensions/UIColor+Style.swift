extension UIColor {
    private convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let maxValue: CGFloat = 255.0
        let red = r/maxValue
        let green = g/maxValue
        let blue = b/maxValue
        let alpha = (a > 0.0 && a < 1.0) ? a : 1.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    // MARK - Music
    static let musicViewedStoryBorderDark = UIColor(white: 1, alpha: 0.2)
    static let musicViewedStoryBorderLight = UIColor(white: 0, alpha: 0.2)
    static let musicNonViewedStoryBorder = UIColor(red: 0, green: 0.47, blue: 0.8, alpha: 1)
    
    // MARK - KP
    static let kpViewedStoryBorder = UIColor(white: 0, alpha: 0.2)
    static let kpNonViewedStoryBorder = UIColor(r: 255, g: 102, b: 0, a: 1)
    static let grayGradient = UIColor(r: 232, g: 232, b: 232, a: 1)
    static let lightGrayGradient = UIColor(r: 242, g: 242, b: 242, a: 1)
}
