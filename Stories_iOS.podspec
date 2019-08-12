#
# Be sure to run `pod lib lint Stories_iOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'StoriesSDK'
  s.version          = '0.0.1'
  s.summary          = 'Stories for Music and Kinopoisk Application.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC
  s.homepage         = 'https://bb.yandex-team.ru/projects/MUSIC-MOBILE/repos/mobile-stories-sdk-ios/browse'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'gsoloviev100@yandex-team.ru' => 'gsoloviev@htc-cs.ru' }
  s.source           = { :git => 'ssh://git@bb.yandex-team.ru/music-mobile/mobile-stories-sdk-ios.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.source_files = 'StoriesSDK/Classes/**/*'
end
