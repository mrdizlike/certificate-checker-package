//
//  CertificateParser.swift
//  CertificateChecker
//
//  Created by Виктор on 06.08.2023.
//

import Foundation
import UIKit
import X509

class CertificateParser: NSObject, URLSessionDelegate {
    var certificatesInfo: [CertificateInfo] = []
    var viewController: CertificateParserViewController!
    var certificateExtensionReader: CertificateExtensionsReader = CertificateExtensionsReader()
    
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
                    let data = SecCertificateCopyData(certificate) as Data
                    let pemCode = convertToPEM(data: data)
                    
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
        
        let subjectInfo = CertificateUtils.parseSubject(subject: certificate.subject.description)
        let issuerInfo = CertificateUtils.parseSubject(subject: certificate.issuer.description)
        
        certificateExtensionReader.setNames(certificate: certificate)

        let info = CertificateInfo(
            subjectCN: subjectInfo["CN"] ?? "",
            subjectC: subjectInfo["C"] ?? "",
            subjectL: subjectInfo["L"] ?? "",
            subjectO: subjectInfo["O"] ?? "",
            subjectOU: subjectInfo["OU"] ?? "",
            email: subjectInfo["1"] ?? "",
            issuerCN: issuerInfo["CN"] ?? "",
            issuerC: issuerInfo["C"] ?? "",
            issuerO: issuerInfo["O"] ?? "",
            issuerOU: issuerInfo["OU"] ?? "",
            validityBefore: CertificateUtils.formatUTC(certificate.notValidBefore),
            validityAfter: CertificateUtils.formatUTC(certificate.notValidAfter),
            validFor: CertificateUtils.calculateTime(currentDate: certificate.notValidBefore, targetDate: certificate.notValidAfter),
            willExpireIn: CertificateUtils.calculateTime(currentDate: Date(), targetDate: certificate.notValidAfter),
            signatureAlgorithm: CertificateUtils.formatAlgorithmType(from: certificate.signature.description) ?? "",
            signature: certificate.signatureAlgorithm.description.replacingOccurrences(of: "SignatureAlgorithm.", with: ""),
            serialNumber: certificate.serialNumber.description,
            version: certificate.version.description,
            certificateExtInfo: certificateExtensionReader.certificateExtInfo,
            sha256FingerPrint: "",
            sha1FingerPrint: ""
        )

        print(certificate)
        
        return info
    }
    
    func showCertificatesBranch() {
        DispatchQueue.main.async { // Работаем в основном потоке
            let availableCertificatesVC = ViewAvailableCertificates()
            availableCertificatesVC.certificates = self.certificatesInfo
            self.viewController.addChild(availableCertificatesVC)
            self.viewController.view.addSubview(availableCertificatesVC.view)
            availableCertificatesVC.didMove(toParent: self.viewController)
            self.viewController.activityIndicator.stopAnimating() // Скрываем плашку загрузки
        }
    }
    
    func showCertificateFile() {
        DispatchQueue.main.async {
            let detailsVC = ViewCertificateDetails()
            detailsVC.certificate = self.certificatesInfo.first
            self.viewController.addChild(detailsVC)
            self.viewController.view.addSubview(detailsVC.view)
            detailsVC.didMove(toParent: self.viewController)
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
}
