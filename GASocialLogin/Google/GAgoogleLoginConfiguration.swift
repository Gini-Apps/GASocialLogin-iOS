//
//  GAgoogleLoginConfiguration.swift
//  GASocialLogin
//
//  Created by ido meirov on 06/09/2018.
//

import Foundation

public struct GAGoogleLoginConfiguration
{
    let clientIdentifier    : String
    let saveLastLoginUser   : Bool
    
    public init(clientIdentifier: String, saveLastLoginUser: Bool = false)
    {
        self.clientIdentifier   = clientIdentifier
        self.saveLastLoginUser  = saveLastLoginUser
    }
}

extension GAGoogleLoginConfiguration: GASocialLoginConfiguration
{
    public var service: GASocialLoginService
    {
        return GASocialLogin.GAGoogleLoginService(clientIdentifier: clientIdentifier, saveLastLoginUser: saveLastLoginUser)
    }
    
    public var serviceName: String
    {
        return GASocialLogin.GAGoogleLoginService.serviceKey
    }
    
    
}
