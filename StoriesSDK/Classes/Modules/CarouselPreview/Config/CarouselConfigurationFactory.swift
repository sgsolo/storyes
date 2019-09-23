public enum CarouselConfigurationFactory {
    static func configForApp(
        _ targetApp: SupportedApp
    ) -> CarouselConfiguration {
        switch targetApp {
        case .kinopoisk:
            return kpCarouselConfiguration()
        case .music:
            return musicCarouselConfiguration()
        }
    }
    
    private static func musicCarouselConfiguration() -> CarouselConfiguration {
        return MusicCarouselConfiguration()
    }
    
    private static func kpCarouselConfiguration() -> CarouselConfiguration {
        return KPCarouselConfiguration()
    }
}
