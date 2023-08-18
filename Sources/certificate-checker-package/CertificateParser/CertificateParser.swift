//
//  CertificateParser.swift
//  CertificateChecker
//
//  Created by Виктор on 06.08.2023.
//

import Foundation
import UIKit
import X509

public class CertificateParser: NSObject, URLSessionDelegate {
    var certificatesInfo: [CertificateInfo] = []
    public var viewController: UIViewController!
    
    // Парсим сертификат по ссылке из интернета
    public func parseCertificateFromURL(url: URL) {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: url)

        task.resume() //Запускаем сессию
    }
    
    // Парсим сертификат из файла
    public func parseCertificateFromFile(url: URL) {
        do {
            certificatesInfo.removeAll()
            
            let data = try Data(contentsOf: url)
            // Создаем SecCertificate из данных
            guard let certificate = SecCertificateCreateWithData(nil, data as CFData) else {
                showErrorAlert()
                print("Error creating certificate from data")
                return
            }
            let derData = SecCertificateCopyData(certificate) as Data
            let pemCode = convertToPEM(data: derData)
            
            if let certificateInfo = parseCertificateInfo(pem: pemCode) {
                certificatesInfo.append(certificateInfo)
                showCertificates()
            }
        } catch {
            //Не получается получить локальный файл, пробуем подключиться к серверу по ссылке
            var formattedURL = URL(string: formatURL(url.absoluteString))!
            parseCertificateFromURL(url: formattedURL)
            print("Error loading certificate from file, trying WEB")
        }
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
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
        
        showCertificates()
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
            showErrorAlert()
            print("Error!")
            return nil
        }
        
        let keyUsageBasic: KeyUsage? = try? certificate.extensions.keyUsage
        let keyUsageExtended: ExtendedKeyUsage? = try? certificate.extensions.extendedKeyUsage
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
            validityBefore: formatUTC(certificate.notValidBefore),
            validityAfter: formatUTC(certificate.notValidAfter),
            validFor: calculateTime(currentDate: certificate.notValidBefore, targetDate: certificate.notValidAfter),
            willExpireIn: calculateTime(currentDate: Date(), targetDate: certificate.notValidAfter),
            keyUsageBasic: keyUsageBasic?.description ?? "",
            keyUsageExtended: keyUsageExtended?.description ?? "",
            signatureAlgorithm: formatAlgorithmType(from: certificate.signature.description) ?? "",
            signature: certificate.signatureAlgorithm.description.replacingOccurrences(of: "SignatureAlgorithm.", with: ""),
            subjectKeyId: subjectKeyId?.description ?? "",
            authorityKeyId: authorityKeyId?.description ?? "",
            serialNumber: certificate.serialNumber.description,
            certificateAuthority: certificateAuthority?.description ?? "",
            version: certificate.version.description 
            
        )
        
        return info
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
    
    //Форматируем ссылку которую ввел пользователь, чтобы правильно обратиться к адресу
    func formatURL(_ urlString: String) -> String {
        // Проверяем, начинается ли URL с https://www.
        if urlString.hasPrefix("https://www.") {
            return urlString
        }
        
        // Если URL начинается с www., добавляем https://
        if urlString.hasPrefix("www.") {
            return "https://" + urlString
        }
        
        // Если URL не содержит www., добавляем https://www.
        if !urlString.contains("www.") && !urlString.contains("http://") && !urlString.contains("https://") {
            return "https://www." + urlString
        }
        
        // В противном случае возвращаем исходный URL
        return urlString
    }
    
    func formatUTC(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.string(from: date)
    }
    
    func calculateTime(currentDate: Date, targetDate: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: currentDate, to: targetDate)
        
        let years = components.year ?? 0
        let months = components.month ?? 0
        let days = components.day ?? 0
        
        if years != 0 {
            return "\(years) years \(months) months \(days) days"
        } else if months != 0{
            return "\(months) months \(days) days"
        } else {
            return "\(days)"
        }
    }
    
    func formatAlgorithmType(from string: String) -> String? {
        //Используется алгоритм ECDSA
        if string.hasPrefix("ecdsa") {
            return "ECDSA"
        }
        
        //Используется алгоритм RSA
        if string.hasPrefix("rsa") {
            return "RSA"
        }
        return nil
    }
    
    func showCertificates() {
        DispatchQueue.main.async { // Работаем в основном потоке
            let availableCertificatesVC = ViewAvailableCertificates()
            availableCertificatesVC.certificates = self.certificatesInfo
            self.viewController.present(availableCertificatesVC, animated: true)
        }
    }
    
    func showErrorAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Ошибка", message: "Неизвестная ошибка", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.viewController.present(alert, animated: true, completion: nil)
        }
    }

}
