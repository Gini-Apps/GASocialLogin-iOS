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
1. [Requirements](#requirements)
2. [Installation](#installation)
3. [Guides](#guides) 

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
To integrate GABiometricAuthentication into your Xcode project using CocoaPods, specify it in your Podfile:
```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
  pod 'GABiometricAuthentication/Facebook'
  pod 'GABiometricAuthentication/Google'
end
```
Then, run the following command:
```
$ pod install
```

<a name="guides"/>

# Guides:

* **[Facebook](https://github.com/rubygarage/authorize-me/wiki/Facebook-Provider)**
* **[Google](https://github.com/rubygarage/authorize-me/wiki/Google-Provider)**




