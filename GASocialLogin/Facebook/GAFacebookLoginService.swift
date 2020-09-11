//
//  GAFacebookLoginService.swift
//  GASocialLogin
//
//  Created by ido meirov on 04/09/2018.
//

import Foundation
import FBSDKLoginKit

public typealias GAFacebookUserData = [String : Any]
public typealias GAFacebookToken    = AccessToken


/// Login result
///
/// - success: log in and get user data successd
/// - error: the error from facebook sdk
/// - missingPermissions: no Permissions
/// - unknownError: unknown error
/// - cancelled: user prass on cancel
public enum GAFacebookResult
{
    case success(GAFacebookProfile, GAFacebookUserData)
    case error(Error)
    case missingPermissions
    case unknownError
    case cancelled
}


/// Base user model
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
    public var facebookLoginService: GAFacebookLoginService?
    {
        guard let service = services[GAFacebookLoginService.serviceKey] as? GAFacebookLoginService else
        {
            assertionFailure("You did not pass GAFacebookLoginConfiguration in the GASocialLogin configure method")
            debugPrint("you did not pass GAFacebookLoginConfiguration in the GASocialLogin configure method")
            return nil
        }
        
        return service
    }
}

extension GASocialLogin
{
    public typealias GAFacebookCompletion = (GAFacebookResult) -> Void
    public typealias GAFacebookAccessTokenValidationCompletion = (Bool, Error?) -> Void
    
    public class GAFacebookLoginService: NSObject
    {
        // MARK: - Properties
        static let serviceKey                           = "GASocialLogin.GAFacebookLoginService"
        public private(set) var currentFacebookProfile  : GAFacebookProfile? // the current Facebook user loged in Profile
        public var saveLastLoginToken                   : Bool // should auto save user token (default value is false)
        public let facebookURLScheme                    : String
        
        /// Facebook manager
        public let loginManager : LoginManager = {
            
            let manager = LoginManager()
            return manager
        }()
        
        
        /// Default permissions if user do not give any permissions
        public static let defaultPermissionsKeys = [
            "email",
            "public_profile"
        ]
        
        
        /// Default fields for graph request if user do not give any fields
        public static let defaultUserFields = "id, name, email, first_name, last_name"
        
        // MARK: - Enum
        /// User base metadata keys
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
        public init(facebookURLScheme: String, saveLastLoginToken: Bool = false)
        {
            self.saveLastLoginToken = saveLastLoginToken
            self.facebookURLScheme  = facebookURLScheme
            super.init()
        }
        
        // MARK: - Public API Login
        
        /// Impalement facebook logIn withReadPermissions and then call to use FBSDKGraphRequest to get user base data
        ///
        /// - Parameters:
        ///   - permissions: the permissions for faacebook log in (default value is defaultPermissionsKeys)
        ///   - fields: the fields for facebook FBSDKGraphRequest (default value is defaultUserFields)
        ///   - viewController: the current present view controller
        ///   - completion: the call back with the results
        public func loginUser(byPermissions permissions: [String] = defaultPermissionsKeys, byFields fields: String = defaultUserFields,from viewController: UIViewController, with completion: @escaping GAFacebookCompletion)
        {
            loginManager.logIn(permissions: permissions, from: viewController) { [weak self] (result, error) in
                
                guard let strongSelf = self else { return }
                guard let result = result   else { strongSelf.handelError(for: error, with: completion) ; return }
                
                switch result.isCancelled {
                case true:
                    print("FACEBOOK LOGIN: CANCELLED")
                    self?.currentFacebookProfile = nil
                    completion(.cancelled)
                    
                case false:
                    print("FACEBOOK LOGIN: SUCCESS - PERMISSIONS: \(String(describing: result.grantedPermissions))")
                    guard result.grantedPermissions.count == permissions.count else { completion(.missingPermissions); return }
                    strongSelf.getUserInfo(byFields: fields, loginResult: result, completion: completion)
                }
            }
        }
        
        
        /// Check ig given token is validate using facebook graph request
        /// GET https://graph.accountkit.com/v1.3/me/?access_token=<access_token>.
        ///
        /// - Parameters:
        ///   - token: the token to check (default value is FBSDKAccessToken.current().tokenString)
        ///   - completion: the completion handler return true if get data from facebook
        public func checkAccessTokenValidation(token: String = AccessToken.current?.tokenString ?? "", completion: GAFacebookAccessTokenValidationCompletion?)
        {
            let params = ["access_token" : token]
            let graphRequest = GraphRequest(graphPath: "me", parameters: params)
            
            _ = graphRequest.start(completionHandler: { (connection, result, error) in
                
                if let error = error
                {
                    completion?(false, error)
                    return
                }
                
                guard result != nil else
                {
                    completion?(false, nil)
                    return
                    
                }
                
                completion?(true, nil)
            })
        }
        
        
        /// Impalement facebook logOut
        public func logOut()
        {
            loginManager.logOut()
        }
        
        /// MARK: - Private
        
        /// Call to FBSDKGraphRequest.start by given fields
        ///
        /// - Parameters:
        ///   - fields: fields for facebook FBSDKGraphRequest
        ///   - loginResult: the result of the login as FBSDKLoginManagerLoginResult
        ///   - completion: the call back with the results
        private func getUserInfo(byFields fields: String, loginResult: LoginManagerLoginResult, completion: @escaping GAFacebookCompletion)
        {
            guard AccessToken.current != nil else {
                print("FACEBOOK: user not logged in: aborting action")
                currentFacebookProfile = nil
                completion(.unknownError)
                return
            }
            
            let params = ["fields" : fields]
            let graphRequest = GraphRequest(graphPath: "me", parameters: params)
            
            _ = graphRequest.start { [weak self] (connection, result, error) in
                
                guard let strongSelf = self else { return }
                
                guard let userData = result as? GAFacebookUserData else { strongSelf.handelError(for: error, with: completion) ; return }
                
                strongSelf.generateFacebookProfile(with: loginResult, from: userData, with: completion)
            }
        }
        
        private func generateFacebookProfile(with loginResult: LoginManagerLoginResult, from userData: GAFacebookUserData, with completion: @escaping GAFacebookCompletion)
        {
            let facebookId  = userData[FacebookKeys.id.description] as? String
            let email       = userData[FacebookKeys.email.description] as? String
            let firstName   = userData[FacebookKeys.firstName.description] as? String
            let lastName    = userData[FacebookKeys.lastName.description] as? String
            
            let facebookToken = loginResult.token?.tokenString
            
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
    // MARK: - Properties
    
    /// Return the current FBSDKAccessToken if nil return the lastLogInToken
    public var logInToken: AccessToken?
    {
        guard let currentToken = AccessToken.current else { return nil }
        
        return currentToken
    }
    
    /// Return the logInToken permissions
    public var currentTokenPermissions: Set<String>?
    {
        guard let currentToken = logInToken else { return nil }
        let permissions = currentToken.permissions
        guard !permissions.isEmpty  else { return nil }
        return  permissions
    }
}

// NS_REFINED_FOR_SWIFT https://github.com/facebook/facebook-objc-sdk/blob/master/CHANGELOG.md?fbclid=IwAR2b60RVH772cxH8CMuRZT55hrk1LjDB7cehUksPu3sFqd-mXf5VqyT6MtY#swift-developers
// Certain values have been annotated with NS_REFINED_FOR_SWIFT and can be customized via either:
// * The Facebook SDK in Swift (Beta)
// * Implementing custom extensions
// Custom extensions
public extension AccessToken {
    var permissions: Set<String> {
        return Set(__permissions)
    }
}


// MARK: -  GASocialLoginService
extension GASocialLogin.GAFacebookLoginService: GASocialLoginService
{
    // MARK: - Public API Application Handler
    
    ///
    /// Call this method from the [UIApplicationDelegate application:didFinishLaunchingWithOptions:] method
    ///  of the AppDelegate for your app. It should be invoked for the proper use of the Facebook SDK.
    ///  As part of SDK initialization basic auto logging of app events will occur, this can be
    ///  controlled via 'FacebookAutoLogAppEventsEnabled' key in the project info plist file.
    ///
    /// - Parameters:
    ///   - application   The application as passed to [UIApplicationDelegate application:didFinishLaunchingWithOptions:].
    ///   - launchOptions The launchOptions as passed to [UIApplicationDelegate application:didFinishLaunchingWithOptions:].
    ///
    /// - returns YES if the url was intended for the Facebook SDK, NO if not.
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool
    {
        return ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    /// Call this method from the [UIApplicationDelegate application:openURL:sourceApplication:annotation:] method
    /// of the AppDelegate for your app. It should be invoked for the proper processing of responses during interaction
    /// with the native Facebook app or Safari as part of SSO authorization flow or Facebook dialogs.
    ///
    /// - Parameters:
    ///   - application The application as passed to [UIApplicationDelegate application:openURL:sourceApplication:annotation:].
    ///   - url The URL as passed to [UIApplicationDelegate application:openURL:sourceApplication:annotation:].
    ///   - sourceApplication The sourceApplication as passed to [UIApplicationDelegate application:openURL:sourceApplication:annotation:].
    ///   - annotation The annotation as passed to [UIApplicationDelegate application:openURL:sourceApplication:annotation:].
    ///
    /// - returns YES if the url was intended for the Facebook SDK, NO if not.
    public func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool
    {
        return ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    /// Call this method from the [UIApplicationDelegate application:openURL:options:] method
    /// of the AppDelegate for your app. It should be invoked for the proper processing of responses during interaction
    /// with the native Facebook app or Safari as part of SSO authorization flow or Facebook dialogs.
    ///
    /// - Parameters:
    ///   - application The application as passed to [UIApplicationDelegate application:openURL:options:].
    ///   - url The URL as passed to [UIApplicationDelegate application:openURL:options:].
    ///   - options The options dictionary as passed to [UIApplicationDelegate application:openURL:options:].
    ///
    /// - Returns: YES if the url was intended for the Facebook SDK, NO if not.
    public func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool
    {
        let sourceApplicationValue = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
        let        annotationValue = options[UIApplication.OpenURLOptionsKey.annotation]        as? String
        
        guard url.scheme == facebookURLScheme else { return true }
        
        return ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplicationValue, annotation: annotationValue)
    }
}
