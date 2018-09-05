//
//  GAFacebookLoginService.swift
//  GASocialLogin
//
//  Created by ido meirov on 04/09/2018.
//

import Foundation
import FBSDKLoginKit

public typealias GAFacebookUserData = [String : Any]
public typealias GAFacebookToken    = FBSDKAccessToken

public enum GAFacebookResult
{
    case success(GAFacebookProfile, GAFacebookUserData)
    case error(Error)
    case missingPermissions
    case unknownError
    case cancelled
}

public struct GAFacebookProfile
{
    public let facebookId   : String?
    public let facebookToken: String?
    public let firstName    : String?
    public let lastName     : String?
    public let email        : String?
}

extension GASocialLogin
{
    public typealias GAFacebookCompletion = (GAFacebookResult) -> Void
    
    public class GAFacebookLoginService: NSObject
    {
        // MARK: - Properties
        public static var shard                         = GAFacebookLoginService()
        public private(set) var currentFacebookProfile  : GAFacebookProfile?
        public var saveLastLoginToken                   : Bool
        
        
        public let loginManager : FBSDKLoginManager = {
            
            let manager = FBSDKLoginManager()
            return manager
        }()
        
        public static let defaultPermissionsKeys = [
            "email",
            "public_profile"
        ]
        
        public static let defaultUserFields = "id, name, email, first_name, last_name"
        
        // MARK: - Enume
        private enum FacebookKeys : String , CustomStringConvertible
        {
            case id            = "id"
            case email         = "email"
            case publicProfile = "public_profile"
            case firstName     = "first_name"
            case lastName      = "last_name"
            case name          = "name"
            
            var description : String { return rawValue }
        }
        
        // MARK: - Object life cycle
        public override init()
        {
            self.saveLastLoginToken = false
            super.init()
        }
        
        
        // MARK: - Public API Application Handler
        public func handleApplication(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool
        {
            let sourceApplicationValue = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String
            let        annotationValue = options[UIApplicationOpenURLOptionsKey.annotation]        as? String
            
            return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplicationValue, annotation: annotationValue)
        }
        
        public func hanleApplication(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?)
        {
            FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        }
        
        // MARK: - Public API Login
        public func loginUser(byPermissions permissions: [String] = defaultPermissionsKeys, byFields fields: String = defaultUserFields,from viewController: UIViewController, with completion: @escaping GAFacebookCompletion)
        {
            loginManager.logIn(withReadPermissions: permissions, from: viewController) { [weak self] (result, error) in
                
                guard let strongSelf = self else { return }
                guard let result = result   else { strongSelf.handelError(for: error, with: completion) ; return }
                
                switch result.isCancelled {
                case true:
                    print("FACEBOOK LOGIN: CANCELLED")
                    self?.currentFacebookProfile = nil
                    completion(.cancelled)
                    
                case false:
                    print("FACEBOOK LOGIN: SUCCESS - PERMISSIONS: \(result.grantedPermissions)")
                    
                    strongSelf.getUserInfo(byFields: fields, loginResult: result, completion: completion)
                }
            }
        }

        /// MARK: - Private
        private func getUserInfo(byFields fields: String, loginResult: FBSDKLoginManagerLoginResult, completion: @escaping GAFacebookCompletion)
        {
            guard FBSDKAccessToken.current() != nil else {
                print("FACEBOOK: user not logged in: aborting action")
                currentFacebookProfile = nil
                completion(.unknownError)
                return
            }
            
            updateLastLoginToken(FBSDKAccessToken.current())
            
            let params = ["fields" : fields]
            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: params)
            
            _ = graphRequest?.start { [weak self] (connection, result, error) in
                
                guard let strongSelf = self else { return }
                
                guard let userData = result as? GAFacebookUserData else { strongSelf.handelError(for: error, with: completion) ; return }
                
                strongSelf.generateFacebookProfile(with: loginResult, from: userData, with: completion)
            }
        }
        
        private func generateFacebookProfile(with loginResult: FBSDKLoginManagerLoginResult, from userData: GAFacebookUserData, with completion: @escaping GAFacebookCompletion)
        {
            let facebookId  = userData[FacebookKeys.id.description] as? String
            let email       = userData[FacebookKeys.email.description] as? String
            let firstName   = userData[FacebookKeys.firstName.description] as? String
            let lastName    = userData[FacebookKeys.lastName.description] as? String
            
            let facebookToken = loginResult.token.tokenString as String
            
            print("FACEBOOK: GRAPH REQUEST: SUCCESS")
            let profile = GAFacebookProfile(facebookId: facebookId, facebookToken: facebookToken,
                                             firstName: firstName, lastName: lastName, email: email)
            
            currentFacebookProfile = profile
            
            completion(.success(profile, userData))
        }
        
        private func handelError(for error: Error?, with completion: @escaping GAFacebookCompletion)
        {
            currentFacebookProfile = nil
            guard let error = error else { completion(.unknownError) ; return }
            completion(.error(error))
        }
    }
}

// MARK: - Login Token
extension GASocialLogin.GAFacebookLoginService
{
    // MARK: - Enum
    private enum UserDefaultsKeys: String, CustomStringConvertible
    {
        case token = "come.GASocialLogin.GAFacebookLoginService.token"
        
        var description : String { return rawValue }
    }
    
    // MARK: - Properties
    public var logInToken: GAFacebookToken?
    {
        guard let currentToken  = FBSDKAccessToken.current() else { return lastLogInToken }
        
        return currentToken
    }
    
    public var lastLogInToken: GAFacebookToken?
    {
        guard let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.token.description) else { return nil }
        let object = NSKeyedUnarchiver.unarchiveObject(with: data)
        return  object as? GAFacebookToken
    }
    
    public var currentTokenPermissions: Set<String>?
    {
        guard let currentToken  = FBSDKAccessToken.current()                else { return nil }
        guard let permissions   = currentToken.permissions as? Set<String>  else { return nil }
        return  permissions
    }
    
    // MARK: - Method
    public func cleanLastLogInToken()
    {
        let userDefaults = UserDefaults.standard
        
        userDefaults.set(nil, forKey: UserDefaultsKeys.token.description)
        
        userDefaults.synchronize()
    }
    
    private func updateLastLoginToken(_ token: GAFacebookToken)
    {
        guard saveLastLoginToken else
        {
            cleanLastLogInToken()
            return
        }
        
        let userDefaults = UserDefaults.standard
        
        let data = NSKeyedArchiver.archivedData(withRootObject: token)
        
        userDefaults.set(data, forKey: UserDefaultsKeys.token.description)
        
        userDefaults.synchronize()
    }
}
