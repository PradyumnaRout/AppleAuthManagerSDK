//
//  AppleSignInUser.swift
//  AppleSignInModule
//
//  Created by Antigravity on 2026-07-29.
//

import Foundation

/// Represents the data retrieved from a successful Sign in with Apple operation.
public struct AppleSignInUser {
    /// The unique, persistent identifier for the user (specifically for this app/developer account).
    public let userId: String
    
    /// The user's first name, if available. Usually only populated on the very first sign-in.
    public let firstName: String?
    
    /// The user's last name, if available. Usually only populated on the very first sign-in.
    public let lastName: String?
    
    /// The user's email, if requested and available. Usually only populated on the very first sign-in.
    public let email: String?
    
    /// The JSON Web Token (JWT) that secures the user's identity.
    public let identityToken: Data?
    
    /// A short-lived authorization code used for server-side verification.
    public let authorizationCode: Data?
    
    /// The full person name components returned by the Apple ID Credential.
    public let fullName: PersonNameComponents?
    
    /// Public initializer required for visibility when compiled in another module / xcframework.
    public init(
        userId: String,
        firstName: String? = nil,
        lastName: String? = nil,
        email: String? = nil,
        identityToken: Data? = nil,
        authorizationCode: Data? = nil,
        fullName: PersonNameComponents? = nil
    ) {
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.identityToken = identityToken
        self.authorizationCode = authorizationCode
        self.fullName = fullName
    }
}

/// Custom error types for the Apple Sign-In flow.
public enum AppleSignInError: LocalizedError {
    /// The user cancelled the Sign in with Apple authorization flow.
    case cancelled
    
    /// The authorization credential returned was invalid or not of type `ASAuthorizationAppleIDCredential`.
    case invalidCredential
    
    /// An unknown or underlying system error occurred.
    case unknown(Error)
    
    public var errorDescription: String? {
        switch self {
        case .cancelled:
            return "The user cancelled the Sign in with Apple request."
        case .invalidCredential:
            return "The authorization credential is invalid or unsupported."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
