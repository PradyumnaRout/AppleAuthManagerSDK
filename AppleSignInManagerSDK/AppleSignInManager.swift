//
//  AppleSignInManager.swift
//  AppleSignInModule
//
//  Created by Antigravity on 2026-07-29.
//

import AuthenticationServices
import Foundation

/// A helper class managing the Apple Sign-In authentication flow.
/// Designed as a reusable component for use in an iOS Application or packaged within an `xcframework`.
public class AppleSignInManager: NSObject {
    
    // MARK: - Properties
    
    /// The stored completion handler for the active sign-in request.
    private var completion: ((Result<AppleSignInUser, Error>) -> Void)?
    
    /// A reference to the active controller to prevent it from being deallocated during the flow.
    private var authorizationController: ASAuthorizationController?
    
    /// The window context to present the sign-in modal sheet.
    private weak var presentationAnchor: ASPresentationAnchor?
    
    // MARK: - Initializer
    
    /// Public initializer to instantiate the helper from other modules or applications.
    public override init() {
        super.init()
    }
    
    // MARK: - Public Interface
    
    /// Initiates the Apple Sign-In flow.
    /// - Parameters:
    ///   - presentationAnchor: The window (`UIWindow`) on which the authorization sheet should be presented.
    ///                         If nil, the manager attempts to find the active key window.
    ///   - completion: Callback executed when the authentication completes or fails.
    public func startSignIn(
        presentationAnchor: ASPresentationAnchor? = nil,
        completion: @escaping (Result<AppleSignInUser, Error>) -> Void
    ) {
        self.completion = completion
        self.presentationAnchor = presentationAnchor
        
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        
        // Retain the controller for the duration of the request
        self.authorizationController = controller
        
        controller.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleSignInManager: ASAuthorizationControllerDelegate {
    
    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        defer {
            cleanUp()
        }
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            completion?(.failure(AppleSignInError.invalidCredential))
            return
        }
        
        let user = AppleSignInUser(
            userId: appleIDCredential.user,
            firstName: appleIDCredential.fullName?.givenName,
            lastName: appleIDCredential.fullName?.familyName,
            email: appleIDCredential.email,
            identityToken: appleIDCredential.identityToken,
            authorizationCode: appleIDCredential.authorizationCode,
            fullName: appleIDCredential.fullName
        )
        
        completion?(.success(user))
    }
    
    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        defer {
            cleanUp()
        }
        
        if let authError = error as? ASAuthorizationError, authError.code == .canceled {
            completion?(.failure(AppleSignInError.cancelled))
        } else {
            completion?(.failure(AppleSignInError.unknown(error)))
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleSignInManager: ASAuthorizationControllerPresentationContextProviding {
    
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let anchor = presentationAnchor {
            return anchor
        }
        
        // Fallback to searching for the active window in standard iOS applications if no anchor was passed.
        #if canImport(UIKit)
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        
        if let window = keyWindow {
            return window
        }
        #endif
        
        // Return a dummy/empty anchor if all else fails (will cause OS default presentation/fallback behavior)
        return ASPresentationAnchor()
    }
}

// MARK: - Helper Methods

private extension AppleSignInManager {
    
    /// Cleans up state after completion of the flow.
    func cleanUp() {
        self.completion = nil
        self.authorizationController = nil
        self.presentationAnchor = nil
    }
}
