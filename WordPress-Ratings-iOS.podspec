Pod::Spec.new do |s|
  s.name                = "WordPress-Ratings-iOS"
  s.version             = "0.0.1"
  s.summary             = "Library for handling Ratings WPiOS"
  s.homepage            = "http://apps.wordpress.org"
  s.license             = { :type => "GPLv2" }
  s.author              = { "Sendhil Panchadsaram" => "sendhil@automattic.com" }
  s.social_media_url    = "http://twitter.com/WordPressiOS"
  s.platform            = :ios, "7.0"
  s.source              = { :git => "https://github.com/wordpress-mobile/WordPress-Ratings-iOS.git", :tag => s.version.to_s }
  s.source_files        = "WordPress-Ratings-iOS", "WordPress-Ratings-iOS/*.{h,m}"
  s.requires_arc        = true
end
