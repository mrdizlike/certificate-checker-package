//
//  File.swift
//  
//
//  Created by Виктор on 30.08.2023.
//

import Foundation
import X509

class CertificateExtensionsReader {
    var oidStrings: [String: String] = [
        "2.5.29.14": "Subject Key Identifier",
        "2.5.29.15": "KeyUsage",
        "2.5.29.17": "Subject Alternative Name",
        "2.5.29.19": "Basic Constraints",
        "2.5.29.32": "Certificate Policies",
        "2.5.29.35": "Authority Key Identifier",
        "2.5.29.37": "External KeyUsage",
        "1.3.6.1.5.5.7.1.1": "Authority Access"
    ]
    var certificateExtInfo: [CertificateExtensionStruct] = []
    
    func setNames(certificate: Certificate) {
        
        let certificateExtension: Certificate.Extensions = certificate.extensions
        let keyUsageBasic: KeyUsage? = try? certificateExtension.keyUsage
        let subjectAlternativeNames: SubjectAlternativeNames? = try? certificateExtension.subjectAlternativeNames
        let keyUsageExtended: ExtendedKeyUsage? = try? certificateExtension.extendedKeyUsage
        let basicConstraints: BasicConstraints? = try? certificateExtension.basicConstraints
        let subjectKeyId: SubjectKeyIdentifier? = try? certificateExtension.subjectKeyIdentifier
        let authorityKeyId: AuthorityKeyIdentifier? = try? certificateExtension.authorityKeyIdentifier
        let certificateAuthority: AuthorityInformationAccess? = try? certificateExtension.authorityInformationAccess
        let basicConstraintsInfo = CertificateUtils.parseSubject(subject: basicConstraints?.description ?? "")
        
        for extensionInfo in certificate.extensions {
            var info: CertificateExtensionStruct
            let oidString = "\(extensionInfo.oid)"
            
            if let name = oidStrings[oidString] {
                let value: String
                
                switch oidString {
                case "2.5.29.14":
                    value = "\(subjectKeyId?.description ?? "")".uppercased()
                case "2.5.29.15":
                    value = "Used: \(CertificateUtils.formatKeyUsage(keyUsageBasic ?? KeyUsage()))"
                case "2.5.29.17":
                    value = "\(subjectAlternativeNames?.description ?? "")"
                case "2.5.29.19":
                    value = "Certification: \(CertificateUtils.formatBoolean(from: basicConstraintsInfo["CA"] ?? ""))"
                case "2.5.29.35":
                    value = "\(authorityKeyId?.description ?? "")".uppercased()
                case "2.5.29.37":
                    value = "Used: \(CertificateUtils.formatExtendedKeyUsage(keyUsageExtended?.description ?? ""))"
                case "1.3.6.1.5.5.7.1.1":
                    value = "\(certificateAuthority?.description ?? "")"
                default:
                    value = String(bytes: extensionInfo.value, encoding: .ascii) ?? ""
                }
                
                info = CertificateExtensionStruct(oid: oidString, critical: extensionInfo.critical, value: value)
            } else {
                info = CertificateExtensionStruct(oid: oidString, critical: extensionInfo.critical, value: String(bytes: extensionInfo.value, encoding: .ascii) ?? "")
            }
            
            certificateExtInfo.append(info)
        }
    }
}
