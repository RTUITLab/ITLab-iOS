//
//  OAuthITLabPKCE.swift
//  ITLab
//
//  Created by Mikhail Ivanov on 01.03.2021.
//

import Foundation
import CommonCrypto

class OAuthITLabPKCE {
    
    private var codeVerifier: String?
    public let codeChallengeMethod = "S256"
    
    open func generateCodeVerifier() -> String? {
        var buffer = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
        codeVerifier = Data(buffer).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .trimmingCharacters(in: .whitespaces)
        
        return codeVerifier
    }
    
    
    open func codeChallenge() -> String? {
        guard let verifier = codeVerifier, let data = verifier.data(using: .utf8) else { return nil }
        var buffer = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &buffer)
        }
        let hash = Data(buffer)
        let challenge = hash.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .trimmingCharacters(in: .whitespaces)
        return challenge
    }
}
