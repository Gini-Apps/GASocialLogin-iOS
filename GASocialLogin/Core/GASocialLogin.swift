//
//  GASocialLogin.swift
//  Pods-GASocialLogin_Example
//
//  Created by ido meirov on 04/09/2018.
//

import Foundation

/// GASocialLoginService is a protocol that every login service need to implement
/// to initialize the social dependency framework
public protocol GASocialLoginService: UIApplicationDelegate { }

/// Interface struct
public class GASocialLogin: NSObject
{
    
    /// Shared instance
    public static let shared = GASocialLogin()
    
    /// The list of available services by the given GASocialLoginConfiguration
    var services = [String : GASocialLoginService]()
    
    /// Create services by given GASocialLoginConfiguration
    /// (example: if you give GAFacebookLoginConfiguration this will create facebook login service).
    /// Must be call in the application main delegate object (or call to configure(using configurations: [GASocialLoginConfiguration])).
    ///
    /// - Parameter configurations: list of GASocialLoginConfiguration
    public func configure(using configurations: GASocialLoginConfiguration...)
    {
        configure(using: configurations)
    }
    
    /// Create services by given GASocialLoginConfiguration
    /// (example: if you give GAFacebookLoginConfiguration this will create facebook login service).
    /// Must be call in the application main delegate object (or call to configure(using configurations: GASocialLoginConfiguration...)).
    ///
    /// - Parameter configurations: list of GASocialLoginConfiguration
    public func configure(using configurations: [GASocialLoginConfiguration])
    {
        configurations.forEach { (configuration) in
        
            services[configuration.serviceName] = configuration.service
        }
    }
    
    @discardableResult public func configure(using configurations: [GASocialLoginConfiguration], application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool
    {
        configure(using: configurations)
        return self.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}


// MARK: - Static functions
extension GASocialLogin
{
    
    /// Static API for GASocialLoginService configure(using configurations:, application:, didFinishLaunchingWithOptions launchOptions:) -> Bool
    @discardableResult public static func configure(using configurations: [GASocialLoginConfiguration], application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool
    {
        shared.configure(using: configurations)
        return shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    /// Static API for GASocialLoginService application(: UIApplication, launchOptions: [UIApplicationLaunchOptionsKey : Any]?) -> Bool
    @discardableResult public static func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool
    {
        return shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    /// Static API for GASocialLoginService application(:, open: , options:) -> Bool
    @discardableResult public static func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool
    {
        return shared.application(app, open: url, options: options)
    }
    
    /// Static API for shared.configure(using: configurations)
    public static func configure(using configurations: GASocialLoginConfiguration...)
    {
        shared.configure(using: configurations)
    }
    
    /// Static API for shared.configure(using: configurations)
    public static func configure(using configurations: [GASocialLoginConfiguration])
    {
        shared.configure(using: configurations)
    }
}

// MARK: - GASocialLoginService
extension GASocialLogin: GASocialLoginService
{
    
    /// Pass the call to every to all services and return false if one of them return false
    ///
    /// - Parameters:
    ///   - application: UIApplication object
    ///   - launchOptions: [UIApplicationLaunchOptionsKey : Any]?
    /// - Returns: return false only if one of services return false
    @discardableResult public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool
    {
        var returnValue = true
        services.keys.forEach { (key) in
            
            guard let service = services[key] else { return }
            
            guard let value = service.application?(application, didFinishLaunchingWithOptions: launchOptions) else
            {
                return
            }
            
            guard !value else { return }
            
            returnValue = false
            
        }

        return returnValue
    }
    
    
    /// Pss the call to every to all services and return false if one of them return false
    ///
    /// - Parameters:
    ///   - app: UIApplication object
    ///   - url: URL
    ///   - options: [UIApplicationOpenURLOptionsKey : Any]
    /// - Returns: return false only if one of services return false
    @discardableResult public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool
    {
        var returnValue = true
        services.keys.forEach { (key) in
            
            guard let service = services[key] else { return }
            
            guard let value = service.application?(app, open: url, options: options) else
            {
                return
            }
            
            guard !value else { return }
            
            returnValue = false
            
        }
        
        return returnValue
    }
}


