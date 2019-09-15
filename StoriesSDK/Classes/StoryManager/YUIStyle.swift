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
    var background: UIColor { get }
    var storiesTitle: UIColor { get }
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
    var background: UIColor {
        return uiStyle.background
    }
    var storiesTitle: UIColor {
        return uiStyle.storiesTitle
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
    public let background = UIColor.lightBackground
    public let storiesTitle = UIColor.black
}

class YMusicUIStyleDark: YUIStyle {
    public let background = UIColor.darkBackground
    public let storiesTitle = UIColor.white
}

class YKinopoiskUIStyle: YUIStyle {
    public let background = UIColor.darkBackground
    public let storiesTitle = UIColor.white
}
