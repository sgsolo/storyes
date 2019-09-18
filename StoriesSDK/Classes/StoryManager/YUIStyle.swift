import UIKit

public enum YColorTheme {
    case light
    case dark
    
    public init(_ isDark: Bool) {
        self = isDark ? .dark : .light
    }
}

// MARK: -
protocol YUIStyle {
    var storiesTitle: UIColor { get }
    var viewedStoryBorderColor: UIColor { get }
    var nonViewedStoryBorderColor: UIColor { get }
}

class YUIStyleService {
    private let targetApp: SupportedApp
    private let uiStyle: YUIStyle
    init(
        with colorTheme: YColorTheme,
        for targetApp: SupportedApp
    ) {
        self.targetApp = targetApp
        uiStyle = YUIStyleFactory.uiStyle(colorTheme, for: targetApp)
    }
}

extension YUIStyleService: YUIStyle {
    var storiesTitle: UIColor {
        return uiStyle.storiesTitle
    }
    
    var viewedStoryBorderColor: UIColor {
        return uiStyle.viewedStoryBorderColor
    }
    var nonViewedStoryBorderColor: UIColor {
        return uiStyle.nonViewedStoryBorderColor
    }
}

// MARK: -
private enum YUIStyleFactory {
    static func uiStyle(
        _ colorThemeType: YColorTheme,
        for targetApp: SupportedApp) -> YUIStyle {
        switch targetApp {
        case .kinopoisk:
            return kpUIStyle()
        case .music:
            return musicUIStyle(colorThemeType)
        }
    }
    
    private static func kpUIStyle() -> YUIStyle {
        return YKinopoiskUIStyle()
    }
    
    private static func musicUIStyle(_ themeType: YColorTheme) -> YUIStyle {
        switch themeType {
        case .dark:
            return YMusicUIStyleDark()
        case .light:
            return YMusicUIStyleLight()
        }
    }
}

class YMusicUIStyleLight: YUIStyle {
    public let storiesTitle = UIColor.black
    var viewedStoryBorderColor = UIColor.musicViewedStoryBorderLight
    var nonViewedStoryBorderColor = UIColor.musicNonViewedStoryBorder
}

class YMusicUIStyleDark: YUIStyle {
    public let storiesTitle = UIColor.white
    var viewedStoryBorderColor = UIColor.musicViewedStoryBorderDark
    var nonViewedStoryBorderColor = UIColor.musicNonViewedStoryBorder
}

class YKinopoiskUIStyle: YUIStyle {
    public let storiesTitle = UIColor.white
    var viewedStoryBorderColor = UIColor.kpViewedStoryBorder
    var nonViewedStoryBorderColor = UIColor.kpNonViewedStoryBorder
}
