public enum CarouselConfigurationFactory {
    static func configForApp(_ targetApp: SupportedApp) -> CarouselPreviewConfiguration {
        switch targetApp {
        case .kinopoisk:
            return kinopoiskCarouselConfiguration(targetApp)
        case .music:
            return musicCarouselConfiguration(targetApp)
        }
    }
    
    private static func musicCarouselConfiguration(_ targetApp: SupportedApp) -> CarouselPreviewConfiguration {
        return CarouselPreviewConfiguration(
            targetApp: targetApp,
            cellsSpacing: 16,
            sectionInset: UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0),
            numberOfVisibleCells: 2,
            visibleWidthOfPartialCell: 16,
            cellApectRatio: .heightToWidth(1.5)
        )
    }
    
    private static func kinopoiskCarouselConfiguration(_ targetApp: SupportedApp) -> CarouselPreviewConfiguration {
        return CarouselPreviewConfiguration(
            targetApp: targetApp,
            cellsSpacing: 6,
            sectionInset: UIEdgeInsets(top: 0.0, left: 11.0, bottom: 0.0, right: 11.0),
            numberOfVisibleCells: 2,
            visibleWidthOfPartialCell: 16,
            cellApectRatio: .widthToHeight(0.68)
        )
    }
}

enum AspectRatio {
    case heightToWidth(CGFloat)
    case widthToHeight(CGFloat)
}
