#
# Be sure to run `pod lib lint LightweightPickerController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LightweightPickerController'
  s.version          = '0.1.0'
  s.summary          = 'Controller to pick and crop media. Writte in Swift.'
  s.description      = <<-DESC
Lightweight piker controller that allows to pick different media types from different sources and crop images.
                       DESC
  s.homepage         = 'https://github.com/anatoliyv/lightweight-picker-controller'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Anatoliy Voropay' => 'anatoliy.voropay@gmail.com' }
  s.source           = { :git => 'https://github.com/anatoliyv/lightweight-picker-controller.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/anatoliy_v'
  s.ios.deployment_target = '9.0'
  s.source_files     = 'PreviewController/Classes/**/*'
  s.resources        = 'PreviewController/Assets/**/*'
  s.frameworks       = 'UIKit', 'AssetsLibrary', 'Photos', 'MobileCoreServices'
end
