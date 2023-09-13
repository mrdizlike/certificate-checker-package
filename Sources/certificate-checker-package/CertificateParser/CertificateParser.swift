//
//  CertificateParser.swift
//  CertificateChecker
//
//  Created by Виктор on 06.08.2023.
//

import Foundation
import UIKit
import X509
import CryptoKit

class CertificateParser: NSObject, URLSessionDelegate {
    var certificatesInfo: [CertificateInfo] = []
    var viewController: CertificateParserViewController!
    var certificateExtensionReader: CertificateExtensionsReader = CertificateExtensionsReader()
    
    var modulus: String = ""
    var blockSize: String = ""
    var keySize: String = ""
    var decimalValue: String = ""
    var signatureHex: String = ""
    var _SHA256FingerPrint: SHA256Digest?
    var _SHA1FingerPrint: Insecure.SHA1Digest?
    
    // Парсим сертификат по ссылке из интернета
    func parseCertificateFromURL(url: URL) {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: url) { [weak self] (data, response, error) in
            // Если есть ошибка, показываем alert
            if let _ = error {
                self?.showErrorAlert()
            }
            
            // Останавливаем индикатор активности после завершения запроса
            DispatchQueue.main.async {
                self?.viewController.activityIndicator.stopAnimating()
            }
        }


        task.resume() //Запускаем сессию
    }
    
    // Парсим сертификат из файла
    func parseCertificateFromFile(url: URL) {
        do {
            certificatesInfo.removeAll()
            viewController.activityIndicator.startAnimating() // Показываем плашку загрузки
            
            let data = try Data(contentsOf: url)
            // Создаем SecCertificate из данных
            guard let certificate = SecCertificateCreateWithData(nil, data as CFData) else {
                showErrorAlert()
                print("Error creating certificate from data")
                return
            }
            let derData = SecCertificateCopyData(certificate) as Data
            let pemCode = convertToPEM(data: derData)
            let key = SecCertificateCopyKey(certificate)
            
            parseSecKey(key: String("\(key)")) // Парсим значения ключа
            _SHA256FingerPrint = SHA256.hash(data: derData) // Парсим отпечаток SHA-256
            _SHA1FingerPrint = Insecure.SHA1.hash(data: derData) // Парсим отпечаток SHA-1
            signatureHex = parseHexSignature(derData: derData) //Парсим значение подписи
            
            if let certificateInfo = parseCertificateInfo(pem: pemCode) {
                certificatesInfo.append(certificateInfo)
                showCertificateFile()
            }
        } catch {
            //Не получается получить локальный файл, пробуем подключиться к серверу по ссылке
            let formattedURL = URL(string: CertificateUtils.formatURL(url.absoluteString))!
            parseCertificateFromURL(url: formattedURL)
            print("Error loading certificate from file, trying WEB")
        }
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        certificatesInfo.removeAll()
        
        if let serverTrust = challenge.protectionSpace.serverTrust { // serverTrust - содержит информацию о сертификате и цепочке доверия.
            let certCount = SecTrustGetCertificateCount(serverTrust)
            for i in 0 ..< certCount { // Достаем цепочку сертификатов, от root до самого сайта
                if let certificate = SecTrustGetCertificateAtIndex(serverTrust, i) {
                    let derData = SecCertificateCopyData(certificate) as Data
                    let pemCode = convertToPEM(data: derData)
                    let key = SecCertificateCopyKey(certificate)
                    
                    parseSecKey(key: String("\(key)")) // Парсим значения ключа
                    _SHA256FingerPrint = SHA256.hash(data: derData) // Парсим отпечаток SHA-256
                    _SHA1FingerPrint = Insecure.SHA1.hash(data: derData) // Парсим отпечаток SHA-1
                    signatureHex = parseHexSignature(derData: derData) //Парсим значение подписи
                    
                    if let certificateInfo = parseCertificateInfo(pem: pemCode) { // После того как получили данные, заносим их в массив данных
                        certificatesInfo.append(certificateInfo)
                    }
                }
            }
        }
        completionHandler(.performDefaultHandling, nil) // Завершение сессии
        
        showCertificatesBranch()
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

        let info = CertificateInfo(
            userID: certificate.subject.userID ?? "none",
            subjectCN: certificate.subject.commonName ?? "",
            subjectC: certificate.subject.countryName ?? "",
            subjectL: certificate.subject.localityName ?? "",
            subjectS: certificate.subject.stateOrProvinceName ?? "",
            subjectO: certificate.subject.organizationName ?? "",
            subjectOU: certificate.subject.organizationalUnitName ?? "",
            email: certificate.subject.emailAddress ?? "",
            issuerCN: certificate.issuer.commonName ?? "",
            issuerC: certificate.issuer.countryName ?? "",
            issuerO: certificate.issuer.organizationName ?? "",
            issuerOU: certificate.issuer.organizationalUnitName ?? "",
            validityBefore: CertificateUtils.formatUTC(certificate.notValidBefore),
            validityAfter: CertificateUtils.formatUTC(certificate.notValidAfter),
            validFor: CertificateUtils.calculateTime(currentDate: certificate.notValidBefore, targetDate: certificate.notValidAfter),
            willExpireIn: CertificateUtils.calculateTime(currentDate: Date(), targetDate: certificate.notValidAfter),
            signatureAlgorithm: CertificateUtils.formatAlgorithmType(from: certificate.signature.description) ?? "",
            modulus: modulus.lowercased(),
            keySize: keySize,
            blockSize: blockSize,
            decimalValue: decimalValue,
            signature: CertificateUtils.formatSignatureAlgorithm(certificate.signatureAlgorithm.description),
            signatureHex: signatureHex,
            serialNumber: certificate.serialNumber.description.uppercased(),
            version: certificate.version.number,
            certificateExtInfo: certificateExtensionReader.setNames(certificate: certificate),
            sha256FingerPrint: CertificateUtils.parseSHA256Digest(digest: _SHA256FingerPrint),
            sha1FingerPrint: CertificateUtils.parseSHA1Digest(digest: _SHA1FingerPrint)
        )

        return info
    }
    
    func showCertificatesBranch() {
        DispatchQueue.main.async { // Работаем в основном потоке
            let availableCertificatesVC = ViewAvailableCertificates()
            availableCertificatesVC.certificates = self.certificatesInfo
            self.checkNavigationAndPush(viewController: availableCertificatesVC)
            
            if self.viewController.title == nil{
                self.viewController.title = "Certificate Details"
            }
            
            if availableCertificatesVC.title == nil {
                availableCertificatesVC.title = self.viewController.title
            }
            
            self.viewController.activityIndicator.stopAnimating() // Скрываем плашку загрузки
        }
    }
    
    func showCertificateFile() {
        DispatchQueue.main.async {
            let detailsVC = ViewCertificateDetails()
            detailsVC.certificate = self.certificatesInfo.first
            self.checkNavigationAndPush(viewController: detailsVC)
            
            if self.viewController.title == nil {
                self.viewController.title = self.certificatesInfo.first?.subjectCN
            }
            
            if detailsVC.title == nil {
                detailsVC.title = self.certificatesInfo.first?.subjectCN
            }
            
            self.viewController.activityIndicator.stopAnimating() // Скрываем плашку загрузки
        }
    }
    
    func showErrorAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: LocalizationSystem.error, message: LocalizationSystem.errorDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: LocalizationSystem.ok, style: .default, handler: nil))
            self.viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    //Смотрим UINavigationController, если его нет, то создаем обертку
    func checkNavigationAndPush(viewController: UIViewController) {
        if self.viewController.navigationController == nil {
            let navController = UINavigationController(rootViewController: viewController)
            self.viewController.addChild(navController)
            self.viewController.view.addSubview(navController.view)
            navController.didMove(toParent: self.viewController)
        } else {
            self.viewController.addChild(viewController)
            self.viewController.view.addSubview(viewController.view)
            viewController.didMove(toParent: self.viewController)
        }
    }
    
    //Парсим данные из публичного ключа
    func parseSecKey(key: String) {
        
        // Регулярные выражения для нахождения значений
        let exponentRegex = try! NSRegularExpression(pattern: "exponent: \\{hex: (\\w+), decimal: (\\w+)", options: [])
        let modulusRegex = try! NSRegularExpression(pattern: "modulus: (\\w+)", options: [])
        let blockSizeRegex = try! NSRegularExpression(pattern: "(\\d+) bits \\(block size: (\\d+)", options: [])

        // Извлекаем значения modulus, exponent и block size с помощью регулярных выражений
        if let exponentMatch = exponentRegex.firstMatch(in: key, options: [], range: NSRange(location: 0, length: key.count)) {
            if let decimalRange = Range(exponentMatch.range(at: 2), in: key) {
                decimalValue = String(key[decimalRange])
            }
        }

        if let modulusMatch = modulusRegex.firstMatch(in: key, options: [], range: NSRange(location: 0, length: key.count)) {
            if let modulusRange = Range(modulusMatch.range(at: 1), in: key) {
                modulus = String(key[modulusRange])
                
                modulus = modulus.enumerated().map { (index, char) in
                    index % 2 == 0 ? "\(char)" : "\(char) "
                }.joined() //Добавляем пробелы каждые две строки
            }
        }

        if let blockSizeMatch = blockSizeRegex.firstMatch(in: key, options: [], range: NSRange(location: 0, length: key.count)) {
            if let bitsRange = Range(blockSizeMatch.range(at: 1), in: key){
                keySize = String(key[bitsRange])
            }
            
            if let blockSizeRange = Range(blockSizeMatch.range(at: 2), in: key) {
                blockSize = String(key[blockSizeRange])
            }
        }
    }
    
    // Парсим значение подписи
    func parseHexSignature(derData: Data) -> String {
        if blockSize == "256" {
            let signatureData = derData.suffix(256)
            return signatureData.map { String(format: "%02x", $0) }.joined(separator: " ")
        }
        if blockSize == "384" {
            let signatureData = derData.suffix(384)
            return signatureData.map { String(format: "%02x", $0) }.joined(separator: " ")
        }
        if blockSize == "512" {
            let signatureData = derData.suffix(512)
            return signatureData.map { String(format: "%02x", $0) }.joined(separator: " ")
        }
        return ""
    }
}
