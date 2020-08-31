//
//  GAAppleLoginConfiguration.swift
//  Bolts
//
//  Created by arkadi yoskovitz on 07/07/2020.
//

import Foundation

public struct GAAppleLoginConfiguration
{

}

//// MARK: - GASocialLoginConfiguration
extension GAAppleLoginConfiguration: GASocialLoginConfiguration
{
    public var service: GASocialLoginService {

        return GASocialLogin.GAAppleLoginService()
    }

    public var serviceName: String
    {
        return GASocialLogin.GAAppleLoginService.serviceKey
    }
}
