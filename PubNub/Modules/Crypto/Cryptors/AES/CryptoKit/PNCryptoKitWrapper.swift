import Foundation
import CryptoKit

/// Objective-C visible wrapper; uses supported Swift/Objective-C interoperability.
@objc(PNCryptoKitWrapper)
public final class PNCryptoKitWrapper: NSObject {
    /// Decrypt data sealed with AES-256-GCM.
    ///
    /// - Parameters:
    ///   - key: Symmetric key, 32 bytes long (AES-256).
    ///   - nonce: Nonce used during encryption, 12 bytes long.
    ///   - tag: Authentication tag produced during encryption, 16 bytes long.
    ///   - ciphertext: Encrypted data to decrypt.
    /// - Returns: Decrypted (plaintext) data.
    /// - Throws: An error if `key`, `nonce` or `tag` has an unexpected length, or if the authentication tag can't be
    ///   verified (wrong key, or nonce, tag or ciphertext has been modified).
    @objc(decryptWithKey:nonce:tag:ciphertext:error:)
    public static func decrypt(key: Data, nonce: Data, tag: Data, ciphertext: Data) throws -> Data {
        guard key.count == 32, nonce.count == 12, tag.count == 16 else {
            throw NSError(domain: "PNCryptoKitWrapper", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid AES-GCM key or metadata length"])
        }
        let nonce = try AES.GCM.Nonce(data: nonce)
        let box = try AES.GCM.SealedBox(nonce: nonce, ciphertext: ciphertext,
                                        tag: tag)
        return try AES.GCM.open(box, using: SymmetricKey(data: key))
    }
}
