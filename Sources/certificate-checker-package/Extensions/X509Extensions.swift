//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import Foundation
import SwiftASN1
import X509

extension ASN1ObjectIdentifier.NameAttributes {
    static let userID: ASN1ObjectIdentifier = [0, 9, 2342, 19_200_300, 100, 1, 1]
    static let emailAddress: ASN1ObjectIdentifier = [1, 2, 840, 113549, 1, 9, 1]
}

extension DistinguishedName {
    var userID: String? {
        self.stringAttribute(oid: ASN1ObjectIdentifier.NameAttributes.userID)
    }
    
    var emailAddress: String? {
        self.stringAttribute(oid: ASN1ObjectIdentifier.NameAttributes.emailAddress)
    }

    var commonName: String? {
        self.stringAttribute(oid: ASN1ObjectIdentifier.NameAttributes.commonName)
    }

    var organizationalUnitName: String? {
        self.stringAttribute(oid: ASN1ObjectIdentifier.NameAttributes.organizationalUnitName)
    }

    var organizationName: String? {
        self.stringAttribute(oid: ASN1ObjectIdentifier.NameAttributes.organizationName)
    }
    
    var countryName: String? {
        self.stringAttribute(oid: ASN1ObjectIdentifier.NameAttributes.countryName)
    }
    
    var localityName: String? {
        self.stringAttribute(oid: ASN1ObjectIdentifier.NameAttributes.localityName)
    }
    
    var stateOrProvinceName: String? {
        self.stringAttribute(oid: ASN1ObjectIdentifier.NameAttributes.stateOrProvinceName)
    }

    private func stringAttribute(oid: ASN1ObjectIdentifier) -> String? {
        for relativeDistinguishedName in self {
            for attribute in relativeDistinguishedName where attribute.type == oid {
                if let stringValue = attribute.stringValue {
                    return stringValue
                }
            }
        }
        return nil
    }
}

extension RelativeDistinguishedName.Attribute {
    fileprivate var stringValue: String? {
        let asn1StringBytes: ArraySlice<UInt8>?
        do {
            asn1StringBytes = try ASN1PrintableString(asn1Any: self.value).bytes
        } catch {
            asn1StringBytes = try? ASN1UTF8String(asn1Any: self.value).bytes
        }

        guard let asn1StringBytes,
              let stringValue = String(bytes: asn1StringBytes, encoding: .utf8)
        else {
            return nil
        }
        return stringValue
    }
}

extension Certificate.Version {
    public var number: String {
        switch self {
        case .v1:
            return "1"
        case .v3:
            return "3"
        default:
            return "unknown"
        }
    }
}

// Преобразовываем данные в hex
extension Data {
    var hexEncodedString: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

extension String {
    //Ищем все URL-адреса в строке
    func extractURLs() -> [URL] {
        var urls: [URL] = []
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector?.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
        
        for match in matches! {
            if let matchURL = match.url {
                urls.append(matchURL)
            }
        }
        return urls
    }
}
