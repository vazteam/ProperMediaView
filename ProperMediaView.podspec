#
#  Be sure to run `pod spec lint ProperMediaView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
Pod::Spec.new do |s|

  s.name         = "ProperMediaView"
  s.version      = "0.0.1"
  s.summary      = "Image and Movie Viewer"
  s.description  = <<-DESC
                      Image and Movie Viewer.
                      You can get it from the URL.
                      You can also display it in fullscreen.
                      At that time, playback of the movie inherited seemlessly. And when it closes as well.
                   DESC
  s.homepage     = "https://github.com/vazteam/ProperMediaView"

  s.license      = {:type => "MIT", :file => "LICENSE" }

  s.author             = { "murawaki" => "mitsuhiromurawaki@gmail.com" }

  s.platform     = :ios

  s.requires_arc = true

  s.source       = { :git => "https://github.com/vazteam/ProperMediaView.git", :tag => "#{s.version}" }
  s.source_files  = "Classes/**/*.swift"

  # s.resource  = "icon.png"
  s.resources = "Resources/*"

  #s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"

  # s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  s.dependency "SDWebImage"

end

