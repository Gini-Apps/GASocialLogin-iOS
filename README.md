<h1 align="center">
  <a href="https://www.gini-apps.com/"><img src="https://cdn.xplace.com/companyLogo/u/e/uedrxh.png" alt="Markdownify" width="200"></a>
  <br>
  GASocialLogin
  <br>
</h1>

<h4 align="center">Easy social media log in </h4>

<p align="center">
  <img alt="Sponsor" src="https://img.shields.io/badge/sponsor-Gini--Apps-brightgreen.svg">
  <img alt="Version" src="https://img.shields.io/badge/pod-v1.0.0-blue.svg">
  <img alt="Author" src="https://img.shields.io/badge/author-Ido Meirov-yellow.svg">
  <img alt="Swift" src="https://img.shields.io/badge/swift-4.1%2B-orange.svg">
  <img alt="Swift" src="https://img.shields.io/badge/platform-ios-lightgrey.svg">
</p>

#### Table of Contents  
1. [Support](#support) 
2. [Requirements](#requirements)
3. [Installation](#installation)
4. [How to Use](#howToUse)
5. [Guides](#guides) 

<a name="support"/>

# Support

GASocialLogin support the following social login:
* Facebook
* Google

<a name="requirements"/>

# Requirements:
* iOS 9.0+ 
* Xcode 9.4+
* Swift 4.1+

<a name="installation"/>

# Installation:

### CocoaPods
CocoaPods is a dependency manager for Cocoa projects. You can install it with the following command:
```
$ gem install cocoapods
```
To integrate GASocialLogin into your Xcode project using CocoaPods, specify it in your Podfile:
```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
  pod 'GASocialLogin/Facebook'
  pod 'GASocialLogin/Google'
end
```
Then, run the following command:
```
$ pod install
```
<a name = "howToUse"/>

# How to Use:

Call to configure with the servises configuration you want at the application didFinishLaunchingWithOptions,
Than call to GASocialLogin.shard.application(application, didFinishLaunchingWithOptions: launchOptions).

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool 
{
        // Override point for customization after application launch.
        
        let facebookConfiguration = GAFacebookLoginConfiguration(facebookURLScheme: "facebookURLScheme")
        GASocialLogin.shard.configure(using: [facebookConfiguration])
        
        GASocialLogin.shard.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
}
```

implement "func application(_ app:, open url: , options: ) -> Bool" and call to GASocialLogin.shard.application(app, open: url, options: options)

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool
{
        return GASocialLogin.shard.application(app, open: url, options: options)
}
```


<a name="guides"/>

# Guides:

* **[Facebook](https://github.com/shay-somech/GASocialLogin/wiki/Facebook)**
* **[Google](https://github.com/shay-somech/GASocialLogin/wiki/Google)**




