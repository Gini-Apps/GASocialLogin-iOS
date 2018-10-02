//
//  GAGoogleLoginService.swift
//  GASocialLogin
//
//  Created by ido meirov on 05/09/2018.
//
// GoogleSignIn version 4.2.0

import Foundation
import GoogleSignIn

public typealias GAGoogleUser = GIDGoogleUser
public typealias GAGoogleSignInMetaData = GIDSignIn


/// The results of log in with google
///
/// - success: log in and get user data successd
/// - error: the error from google
public enum GAGoogleResult
{
    case success(GAGoogleUser)
    case error(Error)
}

extension GASocialLogin
{
    public var googleLoginService: GAGoogleLoginService?
    {
        guard let service = services[GAGoogleLoginService.serviceKey] as? GAGoogleLoginService else
        {
            assertionFailure("You did not pass GAGoogleLoginConfiguration in the GASocialLogin configure method")
            debugPrint("you did not pass GAGoogleLoginConfiguration in the GASocialLogin configure method")
            return nil
        }
        return service
    }
}

extension GASocialLogin
{
    public typealias GAGoogleCompletion = (GAGoogleResult) -> Void
    public typealias GAGoogleWillDispatchBlock = (GAGoogleSignInMetaData?, Error?) -> Void
    
    public class GAGoogleLoginService: NSObject
    {
        // MARK: - Property
        static let serviceKey                   = "GASocialLogin.GAGoogleLoginService"
        private weak var parentViewController   : UIViewController? // the current present view controller
        private var googleCompletion            : GAGoogleCompletion? // log in call back
        private var googleWillDispatchBlock     : GAGoogleWillDispatchBlock? // block to handle signinWillDispatch
        public var saveLastLoginUser            : Bool // allow auto save last loged in user
        
        public var currentGoogleUser            : GAGoogleUser? // current Google user for log in with google
        
        public var clientIdentifier             : String // must e set with the client identifier in google developer web site
        
        
        // MARK: - Object life cycle
        public init(clientIdentifier: String, saveLastLoginUser: Bool = false)
        {
            self.saveLastLoginUser  = saveLastLoginUser
            self.clientIdentifier   = clientIdentifier
            super.init()
        }
        
        // MARK: - Public API Method
        /// Call to google signIn and implement the delagte and uiDelegate
        ///
        /// - Parameters:
        ///   - viewController: the current present view controller
        ///   - willDispatchHandler: block to handle signinWillDispatch
        ///   - successHandler: log in results call back
        public func loginWithGmail(viewController: UIViewController, willDispatchHandler: GAGoogleWillDispatchBlock? = nil, successHandler:@escaping GAGoogleCompletion)
        {
            
            parentViewController    = viewController
            googleCompletion        = successHandler
            googleWillDispatchBlock = willDispatchHandler
            
            let googleSignIn = GIDSignIn.sharedInstance()
            googleSignIn?.shouldFetchBasicProfile = true
            googleSignIn?.delegate = self
            googleSignIn?.uiDelegate = self
            googleSignIn?.signIn()
        }
        
        // MARK: - Public API Method
        
        /// Call to google signInSilently and implement the delagte and uiDelegate,
        /// Attempts to sign in a previously authenticated user without interaction.  The delegate will be
        /// called at the end of this process indicating success or failure.
        ///
        /// - Parameters:
        ///   - viewController: the current present view controller
        ///   - willDispatchHandler: block to handle signinWillDispatch
        ///   - successHandler: log in results call back
        public func silentLoginWithGmail(viewController: UIViewController, willDispatchHandler: GAGoogleWillDispatchBlock? = nil, successHandler:@escaping GAGoogleCompletion)
        {
            parentViewController    = viewController
            googleCompletion        = successHandler
            googleWillDispatchBlock = willDispatchHandler
            
            let googleSignIn = GIDSignIn.sharedInstance()
            googleSignIn?.shouldFetchBasicProfile = true
            googleSignIn?.delegate = self
            googleSignIn?.uiDelegate = self
            googleSignIn?.signInSilently()
        }
        
        /// Call to google signOut, marks current user as being in the signed out state.
        public func signOut()
        {
            let googleSignIn = GIDSignIn.sharedInstance()
            googleSignIn?.shouldFetchBasicProfile = true
            googleSignIn?.delegate = self
            googleSignIn?.uiDelegate = self
            googleSignIn?.signOut()
        }
        
        /// Call to google disconnect, disconnects the current user from the app and revokes previous authentication. If the operation
        /// succeeds, the OAuth 2.0 token is also removed from keychain.
        public func disconnect()
        {
            let googleSignIn = GIDSignIn.sharedInstance()
            googleSignIn?.shouldFetchBasicProfile = true
            googleSignIn?.delegate = self
            googleSignIn?.uiDelegate = self
            googleSignIn?.disconnect()
        }
        
        private func cleanBlocks()
        {
            googleCompletion        = nil
            googleWillDispatchBlock = nil
        }
    }
}

// MARK: Token
extension GASocialLogin.GAGoogleLoginService
{
    // MARK: - Enum
    private enum UserDefaultsKeys: String, CustomStringConvertible
    {
        case user = "com.GASocialLogin.GAGoogleLoginService.user"
        
        var description : String { return rawValue }
    }
    
    // MARK: - Properties
    
    /// Last saved log in user
    public var lastLoginUser: GAGoogleUser?
    {
        guard let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.user.description) else { return nil }
        let object = NSKeyedUnarchiver.unarchiveObject(with: data)
        return  object as? GAGoogleUser
    }
    
    // MARK: - Method
    
    /// Remove the last saved login user
    public func cleanLastLogInToken()
    {
        let userDefaults = UserDefaults.standard
        
        userDefaults.set(nil, forKey: UserDefaultsKeys.user.description)
        
        userDefaults.synchronize()
    }
    
    private func updateLastLoginUser(_ user: GAGoogleUser)
    {
        guard saveLastLoginUser else
        {
            cleanLastLogInToken()
            return
        }
        
        let userDefaults = UserDefaults.standard
        
        let data = NSKeyedArchiver.archivedData(withRootObject: user)
        
        userDefaults.set(data, forKey: UserDefaultsKeys.user.description)
        
        userDefaults.synchronize()
    }
}

// MARK: - GIDSignInDelegate
extension GASocialLogin.GAGoogleLoginService: GIDSignInDelegate
{
    //Login Success
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!)
    {
        
        guard error == nil else
        {
            print("Error: \(error.localizedDescription)")
            googleCompletion?(.error(error))
            
            cleanBlocks()
            
            return
        }
        
        currentGoogleUser = user
        googleCompletion?(.success(user))
        
        cleanBlocks()
    }
    
    //Login Fail
    public func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!, withError error: Error!)
    {
        print("Error: \(error.localizedDescription)")
        googleCompletion?(.error(error))
        cleanBlocks()
    }
}

// MARK: - GIDSignInUIDelegate
extension GASocialLogin.GAGoogleLoginService: GIDSignInUIDelegate
{
    public func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!)
    {
        parentViewController?.present(viewController, animated: false, completion: nil)
    }
    
    public func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!)
    {
        parentViewController?.dismiss(animated: false, completion: nil)
        parentViewController = nil
    }
    
    public func sign(inWillDispatch signIn: GIDSignIn!, error: Error!)
    {
        googleWillDispatchBlock?(signIn, error)
        
        googleWillDispatchBlock = nil
    }
}

// MARK: - GASocialLoginService
extension GASocialLogin.GAGoogleLoginService: GASocialLoginService
{
    // MARK: - Public API Application Handler
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool
    {
        GIDSignIn.sharedInstance()?.clientID = clientIdentifier
        return true
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool
    {
        let sourceApplicationValue = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String
        let        annotationValue = options[UIApplication.OpenURLOptionsKey.annotation]
        
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplicationValue, annotation: annotationValue)
    }

}
