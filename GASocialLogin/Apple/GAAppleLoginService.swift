//
//  GAAppleLoginService.swift
//  GASocialLogin
//
//  Created by arkadi yoskovitz on 07/07/2020.
//

import Foundation
import AuthenticationServices

@available(iOS 13.0, *)
public typealias GAAppleUserCredential  = ASAuthorizationAppleIDCredential
@available(iOS 13.0, *)
public typealias GAAuthorizationKeys    = ASAuthorization.Scope

/// The results of log in with Apple
///
/// - success: log in and get user data successd
/// - error: the error from apple
@available(iOS 13.0, *)
public enum GAAppleSignInResult
{
    case success(GAAppleUserCredential)
    case error(Error)
}

public enum GAAppleSignInError: Error
{
    case unknow
    case unAuthorized
}

@available(iOS 13.0, *)
extension GASocialLogin
{
    public var appleLoginService: GAAppleLoginService?
    {
        guard let service = services[GAAppleLoginService.serviceKey] as? GAAppleLoginService else
        {
            assertionFailure("You did not pass GAFacebookLoginConfiguration in the GASocialLogin configure method")
            debugPrint("you did not pass GAFacebookLoginConfiguration in the GASocialLogin configure method")
            return nil
        }
        
        return service
    }
}

@available(iOS 13.0, *)
extension GASocialLogin
{
    public typealias GAAppleSignInCompletion = (GAAppleSignInResult) -> Void
    public typealias GAAppleAuthorizedCompletion = (Bool,Error?) -> Void
    
    public class GAAppleLoginService: NSObject
    {
        // MARK: - Properties
        static let serviceKey       = "GASocialLogin.GAAppleLoginService"
        var presentingViewContoller : UIViewController?
        var appleCompletion         : GAAppleSignInCompletion?
        var appleIDProvider         : ASAuthorizationAppleIDProvider
        var authorizationController : ASAuthorizationController?
        var currentUser             : GAAppleUserCredential?
        
        public private(set)var userIdentifier: String?

        
        /// Default permissions if user do not give any permissions
        public static let defaultAuthorizationScopeKeys = [
            GAAuthorizationKeys.fullName,
            GAAuthorizationKeys.email
        ]
        
        // MARK: - Object life cycle
        public init(userIdentifier: String?)
        {
            self.userIdentifier = userIdentifier
            self.appleIDProvider = ASAuthorizationAppleIDProvider()
            super.init()
        }
        
        // MARK: - Public API Login
        
        /// Impalement apple logIn withAuthorizationScopeKeys
        ///
        /// - Parameters:
        ///   - authorizationScopeKeys: the Scope for apple log in (default value is defaultPermissionsKeys)
        ///   - viewController: the current present view controller
        ///   - completion: the call back with the results
        public func loginWithApple(authorizationScopeKeys: [GAAuthorizationKeys] = defaultAuthorizationScopeKeys, viewController: UIViewController? = nil, with completion: @escaping GAAppleSignInCompletion)
        {
            authorizationController = nil
            presentingViewContoller = viewController
            appleCompletion         = completion
            
            let request = appleIDProvider.createRequest()
            request.requestedScopes = authorizationScopeKeys
            
            let controller         = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate    = self
            
            if viewController != nil {
                
                controller.presentationContextProvider = self
            }
            
            controller.performRequests()
            
            authorizationController = controller
        }
        
        /// Call to signOut user, delete saved user data.
        public func signOut()
        {
            currentUser     = nil
            userIdentifier  = nil
        }
        
        /// Check if the given user id is authorized and return the result it in the call back
        /// - Parameter completion: the call back with the results
        public func silentLoginWithApple(completion: @escaping GAAppleAuthorizedCompletion)
        {
            guard let userIdentifier = userIdentifier else
            {
                completion(false, nil)
                return
            }
            
            appleIDProvider.getCredentialState(forUserID: userIdentifier) { (credentialState, error) in
                
                guard error == nil else {
                    
                    completion(false, error)
                    return
                }
            
                switch credentialState {
                case .authorized:
                    
                    completion(true, nil)
                    
                default:
                
                    completion(false, nil)
                }
            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
@available(iOS 13.0, *)
extension GASocialLogin.GAAppleLoginService: ASAuthorizationControllerPresentationContextProviding
{
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor
    {
        guard let vc = presentingViewContoller, vc.isViewLoaded else {
            fatalError("apple presentationContextProvider should not be assin to this class if ther are no view controller")
        }
        guard let window = vc.view.window else {
            fatalError("apple presentationContextProvider should not be assin to this class if ther are no view controller")
        }
        return window
    }
}

// MARK: - ASAuthorizationControllerDelegate
@available(iOS 13.0, *)
extension GASocialLogin.GAAppleLoginService: ASAuthorizationControllerDelegate
{
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization)
    {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
                
            currentUser = appleIDCredential
            userIdentifier = appleIDCredential.user
            appleCompletion?(.success(appleIDCredential))
            appleCompletion = nil
            
            break;
        
        case let passwordCredential as ASPasswordCredential:
        
            // TODO: find when this case is return from apple
            print("passwordCredential = \(passwordCredential)")
            break;
            
        default:
            break
        }
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error)
    {
        appleCompletion?(.error(error))
        appleCompletion = nil
    }
}


// MARK: -  GASocialLoginService
@available(iOS 13.0, *)
extension GASocialLogin.GAAppleLoginService: GASocialLoginService
{
   
}
