//
//  GASocialLogin.swift
//  Pods-GASocialLogin_Example
//
//  Created by ido meirov on 04/09/2018.
//

import Foundation

public protocol GASocialLoginConfiguration
{
    var service     : GASocialLoginService { get }
    var serviceName : String { get }
}

public protocol GASocialLoginService: UIApplicationDelegate
{
}


/// Interface struct
public class GASocialLogin: NSObject
{
    public let version = "1.0.1"
    
    public static let shard = GASocialLogin()
    
    var services = [String : GASocialLoginService]()
    
    public func configure(using configurations: GASocialLoginConfiguration...)
    {
        configure(using: configurations)
    }
    
    public func configure(using configurations: [GASocialLoginConfiguration])
    {
        configurations.forEach { (configuration) in
        
            services[configuration.serviceName] = configuration.service
        }
    }
}

// MARK: - GASocialLoginService
extension GASocialLogin: GASocialLoginService
{
    @discardableResult public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool
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
    
    @discardableResult public func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool
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


