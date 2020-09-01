//
//  GAAppleLoginConfiguration.swift
//  Bolts
//
//  Created by arkadi yoskovitz on 07/07/2020.
//

import Foundation

public struct GAAppleLoginConfiguration
{
    let userIdentifier: String?
    
    public init(userIdentifier: String? = nil)
    {
        self.userIdentifier = userIdentifier
    }
}

//// MARK: - GASocialLoginConfiguration
extension GAAppleLoginConfiguration: GASocialLoginConfiguration
{
    public var service: GASocialLoginService {

        return GASocialLogin.GAAppleLoginService(userIdentifier: userIdentifier)
    }

    public var serviceName: String
    {
        return GASocialLogin.GAAppleLoginService.serviceKey
    }
}
