Pod::Spec.new do |s|
  s.name             = "MediaKeyTap"
  s.version          = "2.2.1"
  s.summary          = "Access the Mac's media keys in Swift"
  s.homepage         = "https://github.com/nhurden/MediaKeyTap"
  s.license          = { type: 'MIT', file: 'LICENSE' }
  s.author           = { "Nicholas Hurden" => "git@nhurden.com" }
  s.source           = { git: "https://github.com/nhurden/MediaKeyTap.git", tag: s.version.to_s }

  s.platform     = :osx, '10.10'
  s.requires_arc = true

  s.source_files = 'MediaKeyTap/*.{swift}'
  s.framework    = 'CoreGraphics'
end
