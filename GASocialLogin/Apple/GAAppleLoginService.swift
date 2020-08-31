//
//  GAAppleLoginService.swift
//  GASocialLogin
//
//  Created by arkadi yoskovitz on 07/07/2020.
//

import Foundation
import AuthenticationServices

public typealias GAAppleUserCredential = ASAuthorizationAppleIDCredential

/// The results of log in with google
///
/// - success: log in and get user data successd
/// - error: the error from apple
public enum GAAppleSignInResult
{
    case success(GAAppleUserCredential)
    case error(Error)
}

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

extension GASocialLogin
{
    public typealias GAAppleCompletion = (GAAppleSignInResult) -> Void
    public typealias GAAppleAuthorizedCompletion = (Bool,Error?) -> Void
    
    public class GAAppleLoginService: NSObject
    {
        // MARK: - Properties
        static let serviceKey       = "GASocialLogin.GAAppleLoginService"
        var presentingViewContoller : UIViewController?
        var appleCompletion         : GAAppleCompletion?
        var appleIDProvider         : ASAuthorizationAppleIDProvider
        var authorizationController : ASAuthorizationController?
        var currentUser             : GAAppleUserCredential?
        
        
        /// Default permissions if user do not give any permissions
        public static let defaultAuthorizationScopeKeys = [
            ASAuthorization.Scope.fullName,
            ASAuthorization.Scope.email
        ]
        
        // MARK: - Object life cycle
        public override init()
        {
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
        public func loginWithApple(authorizationScopeKeys: [ASAuthorization.Scope], viewController: UIViewController? = nil, with completion: @escaping GAAppleCompletion)
        {
            authorizationController = nil
            presentingViewContoller = viewController
            appleCompletion         = completion
            
            let request = appleIDProvider.createRequest()
            request.requestedScopes = authorizationScopeKeys
            
            let authorizationController         = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate    = self
            
            if viewController != nil {
                
                authorizationController.presentationContextProvider = self
            }
            
            authorizationController.performRequests()
            
            self.authorizationController = authorizationController
        }
        
        
        
        public func checkForExistingAppleUser(viewController: UIViewController?, completion: @escaping GAAppleCompletion)
        {
            authorizationController = nil
            presentingViewContoller = viewController
            appleCompletion         = completion
            
            let requests = [appleIDProvider.createRequest(),
                            ASAuthorizationPasswordProvider().createRequest()]
            
            
            // Create an authorization controller with the given requests.
            let authorizationController = ASAuthorizationController(authorizationRequests: requests)
            
            authorizationController.delegate = self
            
            if viewController != nil {
                
                authorizationController.presentationContextProvider = self
            }
            
            authorizationController.performRequests()
            
            self.authorizationController = authorizationController
        }
        
        func checkForUserIsAuthorized(completion: @escaping GAAppleAuthorizedCompletion)  {
            
            appleIDProvider.getCredentialState(forUserID: loadUserIdentifier()) { (credentialState, error) in
                
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
        
        // MARK: - Private
        private func saveUserIdentifier(_ userIdentifier: String)
        {
            
        }
        
        private func loadUserIdentifier() -> String
        {
            return "";
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension GASocialLogin.GAAppleLoginService: ASAuthorizationControllerPresentationContextProviding {
    
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
     
        guard let window = presentingViewContoller?.view.window else {
            
            fatalError("apple presentationContextProvider should not be assin to this class if ther are no view controller")
        }
        
        return window
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension GASocialLogin.GAAppleLoginService: ASAuthorizationControllerDelegate {
 
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization)
    {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
                
            currentUser = appleIDCredential
            saveUserIdentifier(appleIDCredential.user)
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
extension GASocialLogin.GAAppleLoginService: GASocialLoginService
{
   
}
