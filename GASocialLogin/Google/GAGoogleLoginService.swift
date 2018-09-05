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
        private weak var parentViewController   : UIViewController?
        private var googleCompletion            : GAGoogleCompletion?
        private var googleWillDispatchBlock     : GAGoogleWillDispatchBlock?
        public var saveLastLoginUser            : Bool
        
        public var currentGoogleUser            : GAGoogleUser?
        
        public static var clientIdentifier     : String = ""
        {
            didSet
            {
                GIDSignIn.sharedInstance().clientID = clientIdentifier
            }
        }
        
        public static var shard = GAGoogleLoginService()
        
        // MARK: - Object life cycle
        public override init()
        {
            self.saveLastLoginUser = false
            super.init()
        }
        
        // MARK: - Method
        public func loginWithGmail(forClientIdentifier clientIdentifier: String = clientIdentifier, viewController: UIViewController, willDispatchHandler: GAGoogleWillDispatchBlock? = nil, successHandler:@escaping GAGoogleCompletion)
        {
            
            parentViewController    = viewController
            googleCompletion        = successHandler
            googleWillDispatchBlock = willDispatchHandler
            
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
    public var lastLoginUser: GAGoogleUser?
    {
        guard let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.user.description) else { return nil }
        let object = NSKeyedUnarchiver.unarchiveObject(with: data)
        return  object as? GAGoogleUser
    }
    
    // MARK: - Method
    public func cleanLastLogInToken()
    {
        let userDefaults = UserDefaults.standard
        
        userDefaults.set(nil, forKey: UserDefaultsKeys.user.description)
        
        userDefaults.synchronize()
    }
    
    func updateLastLoginUser(_ user: GAGoogleUser)
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
            print("Error      : \(error.localizedDescription)")
            googleCompletion?(.error(error))
            
            cleanBlocks()
            
            return
        }
        
//        logger.debug("UserId     : \(user.userID)")
//        logger.debug("Token      : \(user.authentication.idToken)")
//        logger.debug("FullName   : \(user.profile.name)")
//        logger.debug("GivenName  : \(user.profile.givenName)")
//        logger.debug("Family Name: \(user.profile.familyName)")
//        logger.debug("EmailId    : \(user.profile.email)")
        
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
