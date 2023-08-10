//
//  CertificateParser.swift
//  CertificateChecker
//
//  Created by Виктор on 06.08.2023.
//

import Foundation
import X509

public class CertificateParser: NSObject, URLSessionDelegate {
    var certificatesInfo: [CertificateInfo] = []
    var vc: ViewController!
    
    // Парсим сертификат по ссылке из интернета
    func parseCertificateFromURL(url: URL) {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: url)
        task.resume() //Запускаем сессию
    }
    
    // Парсим сертификат из файла
    func parseCertificateFromFile(url: URL) {
        do {
            certificatesInfo.removeAll()
            
            let data = try Data(contentsOf: url)
            // Создаем SecCertificate из данных
            guard let certificate = SecCertificateCreateWithData(nil, data as CFData) else {
                print("Error creating certificate from data")
                return
            }
            let derData = SecCertificateCopyData(certificate) as Data
            let pemCode = convertToPEM(data: derData)
            
            if let certificateInfo = parseCertificateInfo(pem: pemCode) {
                certificatesInfo.append(certificateInfo)
                vc.updateCertificatesInfo(certificates: certificatesInfo) //Обновляем массив с данными
                vc.showCertificates()
            }
        } catch {
            print("Error loading certificate from file: \(error)")
        }
    }

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        certificatesInfo.removeAll()
        
        if let serverTrust = challenge.protectionSpace.serverTrust { // serverTrust - содержит информацию о сертификате и цепочке доверия.
            let certCount = SecTrustGetCertificateCount(serverTrust)
                for i in 0 ..< certCount { // Достаем цепочку сертификатов, от root до самого сайта
                    if let certificate = SecTrustGetCertificateAtIndex(serverTrust, i) {
                    let data = SecCertificateCopyData(certificate) as Data
                    let pemCode = convertToPEM(data: data)
                    
                    if let certificateInfo = parseCertificateInfo(pem: pemCode) { // После того как получили данные, заносим их в массив данных
                        certificatesInfo.append(certificateInfo)
                    }
                }
            }
        }
        completionHandler(.performDefaultHandling, nil) // Завершение сессии
        
        vc.updateCertificatesInfo(certificates: certificatesInfo) // Обновляем массив с данными
        vc.showCertificates()
    }

    func convertToPEM(data: Data) -> String {
        let base64Encoded = data.base64EncodedString(options: []) // Преобразовываем строку в base64
        var pemString = "-----BEGIN CERTIFICATE-----\n"
        // Форматируем код, разделяя на строки по 64 символа
        for i in stride(from: 0, to: base64Encoded.count, by: 64) {
            let start = base64Encoded.index(base64Encoded.startIndex, offsetBy: i)
            let end = base64Encoded.index(start, offsetBy: min(64, base64Encoded.count - i))
            let line = String(base64Encoded[start..<end])
            pemString += line + "\n"
        }
        pemString += "-----END CERTIFICATE-----\n"
        
        return pemString
    }
    
    func parseCertificateInfo(pem: String) -> CertificateInfo? {
        guard let certificate = try? Certificate(pemEncoded: pem) else {
            print("Error!")
            return nil
        }

        let keyUsage: ExtendedKeyUsage? = try? certificate.extensions.extendedKeyUsage
        let subjectKeyId: SubjectKeyIdentifier? = try? certificate.extensions.subjectKeyIdentifier
        let authorityKeyId: AuthorityKeyIdentifier? = try? certificate.extensions.authorityKeyIdentifier
        let certificateAuthority: AuthorityInformationAccess? = try? certificate.extensions.authorityInformationAccess
        
        
        let subjectInfo = parseSubject(subject: certificate.subject.description)
        let issuerInfo = parseSubject(subject: certificate.issuer.description)
        
        let info = CertificateInfo(
            subjectCN: subjectInfo["CN"] ?? "",
            subjectC: subjectInfo["C"] ?? "",
            subjectL: subjectInfo["L"] ?? "",
            subjectO: subjectInfo["O"] ?? "",
            subjectOU: subjectInfo["OU"] ?? "",
            issuerCN: issuerInfo["CN"] ?? "",
            issuerC: issuerInfo["C"] ?? "",
            issuerO: issuerInfo["O"] ?? "",
            issuerOU: issuerInfo["OU"] ?? "",
            validityBefore: certificate.notValidBefore,
            validityAfter: certificate.notValidAfter,
            keyUsage: keyUsage ?? nil,
            signatureAlgorithm: certificate.signatureAlgorithm,
            signature: certificate.signature,
            subjectKeyId: subjectKeyId ?? nil,
            authorityKeyId: authorityKeyId ?? nil,
            serialNumber: certificate.serialNumber,
            certificateAuthority: certificateAuthority ?? nil,
            version: certificate.version
            
        )
        
        return info
    }
}

// Парсим subject и issuer чтобы по человечески присвоить их переменным
func parseSubject(subject: String) -> [String: String] {
    var parsedInfo: [String: String] = [:]
    
    let components = subject.split(separator: ",")
    for component in components {
        let keyValue = component.split(separator: "=", maxSplits: 1)
        if keyValue.count == 2 {
            let key = keyValue[0].trimmingCharacters(in: .whitespaces)
            let value = keyValue[1].trimmingCharacters(in: .whitespaces)
            parsedInfo[key] = value
        }
    }
    
    return parsedInfo
}
