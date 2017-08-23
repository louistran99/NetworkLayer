#
#  Be sure to run `pod spec lint WebService.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "WebService"
  s.version      = "1.0.0"
  s.summary      = "A network calls"

  s.description  = "Use to make networking request & upload data" 
  s.homepage     = "http://EXAMPLE/WebService"
  s.license      = "MIT"

  s.author             = { "louistran99" => "louist@zillow.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :path => "." }
  s.source_files  = "WebService/**/*.{h,m,swift}"

  s.pod_target_xcconfig = {'SWIFT_VERSION' => '3'}
end
