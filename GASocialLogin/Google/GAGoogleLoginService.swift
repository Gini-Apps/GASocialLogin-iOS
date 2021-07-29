//
//  GAGoogleLoginService.swift
//  GASocialLogin
//
//  Created by ido meirov on 05/09/2018.
//
// GoogleSignIn version 5.0.2

import Foundation
import GoogleSignIn

public typealias GAGoogleUser           = GIDGoogleUser
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
    enum GIDSignInMethod
    {
        case regular
        case silent
    }
    
    public typealias GAGoogleCompletion        = (GAGoogleResult) -> Void
    public typealias GAGoogleWillDispatchBlock = (GAGoogleSignInMetaData?, Error?) -> Void
    
    public class GAGoogleLoginService: NSObject
    {
        // MARK: - Property
        static let serviceKey                        = "GASocialLogin.GAGoogleLoginService"
        
        // MARK: - Property
        private var googleCompletion                 : GAGoogleCompletion? // log in call back
        private var googleWillDispatchBlock          : GAGoogleWillDispatchBlock? // block to handle signinWillDispatch
        private weak var parentViewController        : UIViewController? // the current present view controller
        public  let saveLastLoginUser                : Bool // allow auto save last loged in user
        private var googleSignIn                     : GIDSignIn // GIDSignIn singleton retriver
        {
            return GIDSignIn.sharedInstance
        }
        public  var currentGoogleUser                : GAGoogleUser? // current Google user for log in with google
        {
            return googleSignIn.currentUser
        }
        public  internal(set) var clientIdentifier   : String // must e set with the client identifier in google developer web site
        
        // MARK: - Object life cycle
        public init(clientIdentifier: String, saveLastLoginUser: Bool = false)
        {
            self.saveLastLoginUser  = saveLastLoginUser
            self.clientIdentifier   = clientIdentifier
            super.init()
        }
        
        
        // MARK: - Public API Method
        /// Call to google signIn and passing the result in the completion handler.
        ///
        /// - Parameters:
        ///   - viewController: the current present view controller
        ///   - willDispatchHandler: block to handle signinWillDispatch
        ///   - completion: log in results call back
        public func logInWithGmail(viewController: UIViewController, willDispatchHandler: GAGoogleWillDispatchBlock? = nil, completion: @escaping GAGoogleCompletion)
        {
            intiateSignInFlow(using: .regular, viewController: viewController, willDispatchHandler: willDispatchHandler, completion: completion)
        }
        
        // MARK: - Public API Method
        /// Call to google signInSilently and passing the result in the completion handler.
        /// Attempts to sign in a previously authenticated user without interaction.  The closure (completion) will be
        /// called at the end of this process indicating success or failure.
        ///
        /// - Parameters:
        ///   - viewController: the current present view controller
        ///   - willDispatchHandler: block to handle signinWillDispatch
        ///   - completion: log in results call back
        public func silentLoginWithGmail(viewController: UIViewController, willDispatchHandler: GAGoogleWillDispatchBlock? = nil, completion: @escaping GAGoogleCompletion)
        {
            intiateSignInFlow(using: .silent, viewController: viewController, willDispatchHandler: willDispatchHandler, completion: completion)
        }
        
        /// Call to google signOut, marks current user as being in the signed out state.
        public func signOut()
        {
            googleSignIn.signOut()
        }
        
        /// Call to google disconnect, disconnects the current user from the app and revokes previous authentication. If the operation
        /// succeeds, the OAuth 2.0 token is also removed from keychain.
        public func disconnect()
        {
            googleSignIn.disconnect()
        }
        
        // MARK: - Private API Method
        /// Call to google signInSilently/signIn ,
        /// Attempts to sign in a previously authenticated user without interaction.  The closure will be
        /// called at the end of this process indicating success or failure.
        ///
        /// - Parameters:
        ///   - method: the sign in method (silent,non-silent)
        ///   - viewController: the current present view controller
        ///   - willDispatchHandler: block to handle signinWillDispatch
        ///   - successHandler: log in results call back
        private func intiateSignInFlow(using method:GIDSignInMethod, viewController: UIViewController, willDispatchHandler: GAGoogleWillDispatchBlock? = nil, completion: @escaping GAGoogleCompletion)
        {
            parentViewController    = viewController
            googleCompletion        = completion
            googleWillDispatchBlock = willDispatchHandler
            //can be removed and used the strong reference or should i use the weak property?
            guard let parentViewController = parentViewController else
            {
                let userInfo    = [
                    NSLocalizedDescriptionKey : "\(#function) : viewController passed in was nil."
                ]
                let error       = NSError(domain: GAGoogleLoginService.serviceKey, code: 170, userInfo: userInfo)
                googleCompletion?(.error(error))
                return
            }
            
            switch method
            {
            case .regular:
                googleSignIn.signIn(with: GIDConfiguration(clientID: clientIdentifier), presenting: parentViewController) { [weak self] user, error in
                    
                    guard let strongSelf = self else
                    {
                        let userInfo    = [
                            NSLocalizedDescriptionKey : "\(#function) : Could not obtain \(GAGoogleLoginService.serviceKey) reference after signing in the user."
                        ]
                        let error       = NSError(domain: GAGoogleLoginService.serviceKey, code: 160, userInfo: userInfo)
                        completion(.error(error))
                        return
                    }
                    strongSelf.dispatchSignIn(user: user, error: error)
                }
            case .silent:
                googleSignIn.restorePreviousSignIn { [weak self] user, error in
                    
                    guard let strongSelf = self else
                    {
                        let userInfo = [
                            NSLocalizedDescriptionKey : "\(#function) : Could not obtain \(GAGoogleLoginService.serviceKey) reference after restoring previous signed in user."
                        ]
                        let error    = NSError(domain: GAGoogleLoginService.serviceKey, code: 150, userInfo: userInfo)
                        completion(.error(error))
                        return
                    }
                    strongSelf.dispatchSignIn(user: user, error: error)
                }
            }
        }
        
        private func dispatchSignIn(user: GIDGoogleUser?, error: Error?)
        {
            if let user = user
            {
                googleCompletion?(.success(user))
                
                cleanBlocks()
            }
            else
            {
                if let error = error
                {
                    googleCompletion?(.error(error))
                }
                else
                {
                    let userInfo = [
                        NSLocalizedDescriptionKey : "\(#function) : Both error and user were nil when trying to unwrapped"
                    ]
                    let error    = NSError(domain: GAGoogleLoginService.serviceKey, code: 404, userInfo: userInfo)
                    
                    googleCompletion?(.error(error))
                }
                cleanBlocks()
                debugPrint("Error in : \(#function)||\(error?.localizedDescription ?? " error was nil")")
            }
        }
        
        private func cleanBlocks()
        {
            googleCompletion        = nil
            googleWillDispatchBlock = nil
        }
    }
}

// MARK: - GASocialLoginService
extension GASocialLogin.GAGoogleLoginService: GASocialLoginService
{
    // MARK: - Public API Application Handler
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool
    {
        return true
    }
    
    public func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool
    {
        let replay = GIDSignIn.sharedInstance.handle(url)
        return replay
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool
    {
        let replay = GIDSignIn.sharedInstance.handle(url)
        return replay
    }
}
