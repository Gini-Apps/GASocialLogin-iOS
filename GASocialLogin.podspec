#
# Be sure to run `pod lib lint GASocialLogin.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'GASocialLogin'
    s.version          = '2.5.1'
    s.summary          = 'Easy social media log in'
    
    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!
    
    s.description      = <<-DESC
    Easy social media log in.
    DESC
    
    s.homepage         = 'https://github.com/Gini-Apps/GASocialLogin'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'idoMeirov' => 'idom@gini-apps.com' }
    s.source           = { :git => 'https://github.com/Gini-Apps/GASocialLogin.git', :tag => s.version.to_s }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
    
    s.swift_version    = '5.0'
    s.ios.deployment_target = '9.0'
    
    s.frameworks = 'UIKit'
    
    s.default_subspec = 'Core'
    
    s.subspec 'Core' do |spec|
        
        spec.source_files = 'GASocialLogin/Core/**/*'
        
    end
    
    s.subspec 'Facebook' do |spec|
        
        spec.source_files = 'GASocialLogin/Facebook/**/*'
        
        spec.dependency 'GASocialLogin/Core'
        spec.dependency 'FBSDKLoginKit', '~> 7.1.1'
        
    end
    
    s.subspec 'Google' do |spec|
        
        
        spec.source_files = 'GASocialLogin/Google/**/*'
        
        spec.pod_target_xcconfig = {
            'OTHER_SWIFT_FLAGS' => '$(inherited) -DSYNCSERVER_GOOGLE_SIGNIN',
            'OTHER_LDFLAGS' => '$(inherited) -ObjC'
        }
        
        spec.resource =
        'GASocialLogin/Assets/Google/GoogleSignIn.bundle'
        
        spec.preserve_paths      = 'GASocialLogin/ExternalVendors/Google/*.framework'
        spec.vendored_frameworks = 'GASocialLogin/ExternalVendors/Google/GoogleSignIn.framework'
        
        spec.frameworks = 'UIKit', 'CoreGraphics', 'CoreText', 'Foundation', 'LocalAuthentication', 'Security', 'SystemConfiguration', 'SafariServices'
        
        spec.dependency 'GASocialLogin/Core'
        
        spec.dependency 'AppAuth'                , '~> 1.4.0'
        spec.dependency 'GTMAppAuth'             , '~> 1.0.0'
        spec.dependency 'GTMSessionFetcher/Core' , '~> 1.4.0'
        
    end
    
    s.subspec 'Apple' do |spec|
        
        spec.source_files = 'GASocialLogin/Apple/**/*'
        
        spec.ios.deployment_target = '13.0'
        
        spec.frameworks = 'AuthenticationServices'
        
        spec.dependency 'GASocialLogin/Core'
        
    end

end
