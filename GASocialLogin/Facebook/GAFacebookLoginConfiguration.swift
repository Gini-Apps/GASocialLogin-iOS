//
//  GAFacebookLoginConfiguration.swift
//  Bolts
//
//  Created by ido meirov on 06/09/2018.
//

import Foundation

public struct GAFacebookLoginConfiguration
{
    let facebookURLScheme   : String
    let saveLastLoginToken  : Bool
    
    public init(facebookURLScheme: String, saveLastLoginToken: Bool = false)
    {
        self.facebookURLScheme  = facebookURLScheme
        self.saveLastLoginToken = saveLastLoginToken
    }
}

// MARK: - GASocialLoginConfiguration
extension GAFacebookLoginConfiguration: GASocialLoginConfiguration
{
    public var service: GASocialLoginService {
        
        return GASocialLogin.GAFacebookLoginService(facebookURLScheme: facebookURLScheme, saveLastLoginToken: saveLastLoginToken)
    }
    
    public var serviceName: String
    {
        return GASocialLogin.GAFacebookLoginService.serviceKey
    }
}

