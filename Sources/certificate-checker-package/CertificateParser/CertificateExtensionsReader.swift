//
//  File.swift
//  
//
//  Created by Виктор on 30.08.2023.
//

import Foundation
import X509
import SwiftASN1

class CertificateExtensionsReader {
    var certificateExtension: Certificate.Extensions? = nil
    var oidStrings: [String: String] = [
        "2.5.29.14": LocalizationSystem.subjectKeyIdentifier,
        "2.5.29.15": LocalizationSystem.keyUsage,
        "2.5.29.17": LocalizationSystem.subjectAlternativeName,
        "2.5.29.19": LocalizationSystem.basicConstraints,
        "2.5.29.31": LocalizationSystem.cRLDistributionPoints,
        "2.5.29.32": LocalizationSystem.certificatePolicies,
        "2.5.29.35": LocalizationSystem.authorityKeyIdentifier,
        "2.5.29.37": LocalizationSystem.externalKeyUsage,
        "1.3.6.1.5.5.7.1.1": LocalizationSystem.authorityAccess,
        "1.3.6.1.4.1.11129.2.4.2": LocalizationSystem.OID,
        "1.2.840.113635.100.6.1.2": LocalizationSystem.appleDeveloperCertificate,
        "1.2.840.113635.100.6.1.12": LocalizationSystem.unknownOID
    ]
    
    //форматируем и при необходимости декодируем значение OID сертификата
    func decodeExtensionValue(oid: String, value: Data) -> String {
        let hexString = value.hexEncodedString
        let keyUsageBasic: KeyUsage? = try? certificateExtension?.keyUsage
        let subjectAlternativeNames: SubjectAlternativeNames? = try? certificateExtension?.subjectAlternativeNames
        let keyUsageExtended: ExtendedKeyUsage? = try? certificateExtension?.extendedKeyUsage
        let basicConstraints: BasicConstraints? = try? certificateExtension?.basicConstraints
        let subjectKeyId: SubjectKeyIdentifier? = try? certificateExtension?.subjectKeyIdentifier
        let authorityKeyId: AuthorityKeyIdentifier? = try? certificateExtension?.authorityKeyIdentifier
        let certificateAuthority: AuthorityInformationAccess? = try? certificateExtension?.authorityInformationAccess
        let basicConstraintsInfo = CertificateUtils.parseSubject(subject: basicConstraints?.description ?? "")
        
        switch oid {
        case "2.5.29.14":
            return subjectKeyId?.description ?? ""
        case "2.5.29.15":
            return CertificateUtils.formatKeyUsage(keyUsageBasic ?? KeyUsage())
        case "2.5.29.17":
            return subjectAlternativeNames?.description ?? ""
        case "2.5.29.19":
            return CertificateUtils.formatBoolean(from: basicConstraintsInfo["CA"] ?? "")
        case "2.5.29.31":
            let decodedString = String(data: value, encoding: .ascii) ?? hexString
            let urls = decodedString.extractURLs()
            if let firstURL = urls.first {
                return firstURL.absoluteString
            }
            return String(data: value, encoding: .utf8) ?? hexString
        case "2.5.29.32":
            let decodedString = String(data: value, encoding: .ascii) ?? hexString
            let urls = decodedString.extractURLs()
            if let firstURL = urls.first {
                return firstURL.absoluteString
            }
            return String(data: value, encoding: .utf8) ?? hexString
        case "2.5.29.35":
            return authorityKeyId?.description.replacingOccurrences(of: "keyID: ", with: "") ?? ""
        case "2.5.29.37":
            return keyUsageExtended?.description ?? ""
        case "1.2.840.113635.100.6.1.2":
            return hexString
        case "1.2.840.113635.100.6.1.12":
            return hexString
        case "1.3.6.1.5.5.7.1.1":
            return certificateAuthority?.description ?? ""
        case "1.3.6.1.4.1.11129.2.4.2":
            return hexString.uppercased()
        default:
            print("\(LocalizationSystem.unknownOID) : \(oid)")
        }
        return hexString
    }
    
    // Находим расширения, преобразовываем все в человеческий вид и возвращаем массив с готовыми расширениями
    func setNames(certificate: Certificate) -> [CertificateExtensionStruct] {
        var certificateExtInfo: [CertificateExtensionStruct] = []
        certificateExtension = certificate.extensions
        
        for extensionInfo in certificate.extensions {
            var info: CertificateExtensionStruct
            let oidString = "\(extensionInfo.oid)"
            
            if let name = oidStrings[oidString] {
                let dataValue = Data(extensionInfo.value)
                let value: String = decodeExtensionValue(oid: oidString, value: dataValue)
                
                info = CertificateExtensionStruct(oid: oidString, critical: extensionInfo.critical, value: value)
            } else {
                info = CertificateExtensionStruct(oid: oidString, critical: extensionInfo.critical, value: String(bytes: extensionInfo.value, encoding: .ascii) ?? "")
            }
            
            certificateExtInfo.append(info)
        }
        return certificateExtInfo
    }
}
