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
  s.author       = { "murawaki" => "mitsuhiromurawaki@gmail.com" }
  s.platform     = :ios, '9.0'
  s.requires_arc = true
  s.source       = { :git => "https://github.com/vazteam/ProperMediaView.git", :tag => "v0.0.1" }
  s.source_files = "Classes/**/*.swift"

  s.resource_bundles = {
    'ProperMediaView' => ['Resources/*']
  }

  s.dependency "SDWebImage"
end

