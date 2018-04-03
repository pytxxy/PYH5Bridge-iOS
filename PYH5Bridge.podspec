#
# Be sure to run `pod lib lint PYH5Bridge.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'PYH5Bridge'
    s.version          = '1.2.0'
    s.summary          = 'PYH5Bridge SDK'
    
    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!
    
    s.description      = <<-DESC
    鹏元征信 H5Bridge SDK(iOS)
    DESC
    
    s.homepage         = 'https://github.com/pytxxy/PYH5Bridge-iOS'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'Apache', :file => 'LICENSE' }
    s.author           = { 'tianxiaxinyong' => 'ios1@pycredit.cn' }
    s.source           = { :git => 'https://github.com/pytxxy/PYH5Bridge-iOS.git', :tag => s.version.to_s }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
    
    s.ios.deployment_target = '8.0'
    
    s.source_files = 'PYH5Bridge/Classes/**/*'
    
    s.resources = "PYH5Bridge/Assets/*.bundle"
    
    # s.resource_bundles = {
    #  'PYH5Bridge' => ['PYH5Bridge/Assets/*.png']
    # }
    
    # s.public_header_files = 'Pod/Classes/**/*.h'
    s.frameworks = 'AVFoundation', 'JavaScriptCore', 'CoreMedia', 'SystemConfiguration', 'MobileCoreServices', 'Photos'
    s.libraries  = 'z', 'resolv.9'
    s.dependency 'AFNetworking', '~> 3.0'
    s.dependency 'MBProgressHUD', '~> 1.1.0'
end

