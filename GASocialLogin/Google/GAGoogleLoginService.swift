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
    public typealias GAGoogleCompletion = (GAGoogleResult) -> Void
    public typealias GAGoogleWillDispatchBlock = (GAGoogleSignInMetaData?, Error?) -> Void
    
    public class GAGoogleLoginService: NSObject
    {
        // MARK: - Property
        private weak var parentViewController   : UIViewController? // the current present view controller
        private var googleCompletion            : GAGoogleCompletion? // log in call back
        private var googleWillDispatchBlock     : GAGoogleWillDispatchBlock? // block to handle signinWillDispatch
        public var saveLastLoginUser            : Bool // allow auto save last loged in user
        
        public var currentGoogleUser            : GAGoogleUser? // current Google user for log in with google
        
        public static var clientIdentifier      : String = "" // must e set with the client identifier in google developer web site
        
        public static var shard = GAGoogleLoginService()
        
        // MARK: - Object life cycle
        public override init()
        {
            self.saveLastLoginUser = false
            super.init()
        }
        
        // MARK: - Public API Application Handler
        public func handleApplication(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool
        {
            let sourceApplicationValue = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String
            let        annotationValue = options[UIApplicationOpenURLOptionsKey.annotation]
            
            return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplicationValue, annotation: annotationValue)
        }
        
        // MARK: - Public API Method
        /// Call to google signIn and implement the delagte and uiDelegate
        ///
        /// - Parameters:
        ///   - clientIdentifier: the client identifier in google developer web site
        ///   - viewController: the current present view controller
        ///   - willDispatchHandler: block to handle signinWillDispatch
        ///   - successHandler: log in results call back
        public func loginWithGmail(forClientIdentifier clientIdentifier: String = clientIdentifier, viewController: UIViewController, willDispatchHandler: GAGoogleWillDispatchBlock? = nil, successHandler:@escaping GAGoogleCompletion)
        {
            
            parentViewController    = viewController
            googleCompletion        = successHandler
            googleWillDispatchBlock = willDispatchHandler
            
            GAGoogleLoginService.clientIdentifier = clientIdentifier
            
            let googleSignIn = GIDSignIn.sharedInstance()
            googleSignIn?.shouldFetchBasicProfile = true
            googleSignIn?.delegate = self
            googleSignIn?.uiDelegate = self
            googleSignIn?.clientID = clientIdentifier
            googleSignIn?.signIn()
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
        case user = "come.GASocialLogin.GAGoogleLoginService.user"
        
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
