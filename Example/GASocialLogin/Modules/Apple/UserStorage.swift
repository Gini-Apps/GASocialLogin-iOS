//
//  UserStorage.swift
//  GASocialLogin_Example
//
//  Created by Ido Meirov on 07/09/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import GASocialLogin

class UserStorage
{
    static let shared = UserStorage()
    
    private enum Keys: String {
        case appleUserID
    }
    
    // MARK: - Properties
    private let userDefaults: UserDefaults
    
    // MARK: ObjectLifeCycle
    init() {
        self.userDefaults = UserDefaults.standard
    }
    
    // MARK: Methods
    func saveAppleUser(_ user: GAAppleUserCredential)
    {
        let data: Data?
        do
        {
            data = try NSKeyedArchiver.archivedData(withRootObject: user, requiringSecureCoding: true)
        }
        catch let error
        {
            data = nil
            print(error)
        }

        userDefaults.set(data, forKey: Keys.appleUserID.rawValue)
        userDefaults.synchronize()
    }
    
    func bringAppleUser() -> GAAppleUserCredential?
    {
        
        guard let data = userDefaults.object(forKey: Keys.appleUserID.rawValue) as? Data else
        {
            return nil
        }
        
        let user: GAAppleUserCredential?
        do
        {
              user = try NSKeyedUnarchiver.unarchivedObject(ofClass: GAAppleUserCredential.self, from: data)
        }
        catch let error
        {
            user = nil
            print(error)
        }

        return user
    }
    
    func cleanAppleUser()
    {
        userDefaults.set(nil, forKey: Keys.appleUserID.rawValue)
        userDefaults.synchronize()
    }
}
