//
//  GASocialLoginConfiguration.swift
//  GASocialLogin
//
//  Created by ido meirov on 12/09/2018.
//

import Foundation


/// The base configuration properies
public protocol GASocialLoginConfiguration
{
    var service     : GASocialLoginService { get }
    var serviceName : String { get }
}
