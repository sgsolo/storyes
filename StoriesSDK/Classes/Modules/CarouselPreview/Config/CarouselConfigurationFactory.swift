public enum CarouselConfigurationFactory {
    static func configForApp(
        _ targetApp: SupportedApp
    ) -> CarouselConfiguration {
        switch targetApp {
        case .kinopoisk:
            return kpCarouselConfiguration(targetApp)
        case .music:
            return musicCarouselConfiguration(targetApp)
        }
    }
    
    private static func musicCarouselConfiguration(
        _ targetApp: SupportedApp
    ) -> CarouselConfiguration {
        return MusicCarouselConfiguration()
    }
    
    private static func kpCarouselConfiguration(
        _ targetApp: SupportedApp
    ) -> CarouselConfiguration {
        return KPCarouselConfiguration()
    }
}
