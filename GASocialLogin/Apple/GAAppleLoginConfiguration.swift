//
//  GAAppleLoginConfiguration.swift
//  Bolts
//
//  Created by arkadi yoskovitz on 07/07/2020.
//

import Foundation

@available(iOS 13.0, *)
public struct GAAppleLoginConfiguration
{
    let userIdentifier: String?
    
    public init(userIdentifier: String? = nil)
    {
        self.userIdentifier = userIdentifier
    }
}

//// MARK: - GASocialLoginConfiguration
@available(iOS 13.0, *)
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
