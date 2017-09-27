#
# Be sure to run `pod lib lint CZImagePreviewer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|

  s.name             = 'CZImagePreviewer'
  s.version          = '0.1.0'
  s.summary      = "iOS下的图片浏览工具"
  s.description  = "iOS下的图片浏览工具,支持手势dismiss"

  s.homepage         = 'https://github.com/czeludzki/CZImagePreviewer'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'czeludzki' => 'czeludzki@gmail.com' }
  s.source           = { :git => 'https://github.com/czeludzki/CZImagePreviewer.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'CZImagePreviewer/Classes/**/*'

  s.frameworks = 'UIKit'
  s.dependency "Masonry"
  s.dependency "SDWebImage"

end
