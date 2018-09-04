//
//  GAGoogleLoginService.swift
//  GASocialLogin
//
//  Created by ido meirov on 04/09/2018.
//

import Foundation
import FBSDKLoginKit

public enum GAFacebookResult
{
    case success(GAFacebookProfile)
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
            super.init()
        }
        
        
        // MARK: - Public API HandleApplication
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
            
            let params = ["fields" : fields]
            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: params)
            
            _ = graphRequest?.start { [weak self] (connection, result, error) in
                
                guard let strongSelf = self else { return }
                
                guard let userData = result as? [String : String] else { strongSelf.handelError(for: error, with: completion) ; return }
                
                strongSelf.generateFacebookProfile(with: loginResult, from: userData, with: completion)
            }
        }
        
        private func generateFacebookProfile(with loginResult: FBSDKLoginManagerLoginResult, from userData: [String : String], with completion: @escaping GAFacebookCompletion)
        {
            let facebookId  = userData[FacebookKeys.id.description]
            let email       = userData[FacebookKeys.email.description]
            let firstName   = userData[FacebookKeys.firstName.description]
            let lastName    = userData[FacebookKeys.lastName.description]
            
            let facebookToken = loginResult.token.tokenString as String
            
            print("FACEBOOK: GRAPH REQUEST: SUCCESS")
            let profile = GAFacebookProfile(facebookId: facebookId, facebookToken: facebookToken,
                                             firstName: firstName, lastName: lastName, email: email)
            
            currentFacebookProfile = profile
            
            completion(.success(profile))
        }
        
        private func handelError(for error: Error?, with completion: @escaping GAFacebookCompletion)
        {
            currentFacebookProfile = nil
            guard let error = error else { completion(.unknownError) ; return }
            completion(.error(error))
        }

    }
}
