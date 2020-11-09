#
#  Be sure to run `pod spec lint CZImagePreviewer.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "CZImagePreviewer"
  s.version      = "1.0.2"
  s.summary      = "iOS下的图片浏览工具"
  s.description  = "iOS下的图片浏览工具,支持手势dismiss"


  s.homepage     = "https://github.com/czeludzki/CZImagePreviewer"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'czeludzki' => 'czeludzki@gmail.com' }
  s.platform     = :ios
  s.ios.deployment_target = '8.0'

  s.source       = { :git => "https://github.com/czeludzki/CZImagePreviewer.git", :tag => s.version.to_s }
  s.source_files = 'CZImagePreviewer/Classes/**/*'
  s.frameworks   = "UIKit"
  s.requires_arc = true

  # s.dependency 'Masonry'
  # s.dependency 'AFNetworking'
  s.dependency 'SDWebImage'

end
