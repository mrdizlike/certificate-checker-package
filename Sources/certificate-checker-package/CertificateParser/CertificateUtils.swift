//
//  File.swift
//  
//
//  Created by Виктор on 30.08.2023.
//

import Foundation
import X509
import CryptoKit

class CertificateUtils {
    // Парсим subject и issuer чтобы по человечески присвоить их переменным
    static func parseSubject(subject: String) -> [String: String] {
        var oidStrings = [
            "emailAddress":"1.2.840.113549.1.9.1",
            "userID":"0.9.2342.19200300.100.1.1"
        ]
        var parsedInfo: [String: String] = [:]
        
        /*
        ([\w.]+) - захватывает последовательность символов, состоящих из букв, цифр и точек, что соответствует ключу,
        (.*?) - lazy совпадение с любыми символами,
        (?=(,[\w.]+=|$)) - группа ключа и значение завершаются либо запятой и началом следующего ключа, либо концом строки.
        */
        let pattern = #"([\w.]+)=(.*?)(?=(,[\w.]+=|$))"#
        
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let matches = regex.matches(in: subject, range: NSRange(subject.startIndex..., in: subject)) // Ищем совпадения
            
            for match in matches { // Перебираем совпадения
                if let keyRange = Range(match.range(at: 1), in: subject),
                   let valueRange = Range(match.range(at: 2), in: subject) {
                    var key = String(subject[keyRange])
                    var value = String(subject[valueRange])
                    
                    // Убираем экранирование символов запятой
                    key = key.replacingOccurrences(of: "\\,", with: ",")
                    value = value.replacingOccurrences(of: "\\,", with: ",")

                    if key == oidStrings["emailAddress"] {
                        value = decodeASN1String(value) ?? ""
                        print(value)
                    }
                    if key == oidStrings["userID"] {
                        parsedInfo[key] = value
                    }
                    
                    parsedInfo[key] = value
                }
            }
        }
        
        return parsedInfo
    }
    
    //Форматируем ссылку которую ввел пользователь, чтобы правильно обратиться к адресу
    static func formatURL(_ urlString: String) -> String {
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
    
    static func formatKeyUsage(_ key: KeyUsage) -> String {
        var description: String {
            var enabledUsages: [String] = []

            if key.digitalSignature {
                enabledUsages.append("Digital Signature")
            }
            if key.nonRepudiation {
                enabledUsages.append("Non Repudiation")
            }
            if key.keyEncipherment {
                enabledUsages.append("Key Encipherment")
            }
            if key.dataEncipherment {
                enabledUsages.append("Data Encipherment")
            }
            if key.keyAgreement {
                enabledUsages.append("Key Agreement")
            }
            if key.keyCertSign {
                enabledUsages.append("Key CertSign")
            }
            if key.cRLSign {
                enabledUsages.append("CRLSign")
            }
            if key.encipherOnly {
                enabledUsages.append("Encipher Only")
            }
            if key.decipherOnly {
                enabledUsages.append("Decipher Only")
            }

            return enabledUsages.joined(separator: ", ")
        }
        return description
    }
    
    static func formatExtendedKeyUsage(_ key: String) -> String {
        var description: String {
            var enabledUsages: [String] = []

            if key == "serverAuth" {
                enabledUsages.append("Server Auth")
            }
            if key == "clientAuth" {
                enabledUsages.append("Client Auth")
            }
            if key == "codeSigning" {
                enabledUsages.append("Code Signing")
            }
            if key == "emailProtection" {
                enabledUsages.append("Email Protection")
            }
            if key == "timeStamping" {
                enabledUsages.append("Time Stamping")
            }
            if key == "ocspSigning" {
                enabledUsages.append("OCSP Signing")
            }
            if key == "any" {
                enabledUsages.append("Any")
            }
            if key == "certificateTransparency" {
                enabledUsages.append("Certificate Transparency")
            }

            return enabledUsages.joined(separator: ", ")
        }
        return description
    }
    
    static func decodeASN1String(_ encodedString: String) -> String? {
        // Находим начало и конец массива байтов
        guard let openBracketIndex = encodedString.firstIndex(of: "["),
              let closeBracketIndex = encodedString.lastIndex(of: "]") else {
            return nil
        }

        // Извлекаем строку с байтами внутри квадратных скобок
        let byteString = encodedString[encodedString.index(after: openBracketIndex)..<closeBracketIndex]

        // Разделяем строку на числа, преобразуем их в UInt8 и создаем массив байтов
        let byteValues = byteString.split(separator: ",").compactMap { UInt8($0.trimmingCharacters(in: .whitespaces)) }
        
        // Преобразуем массив байтов в строку
        if let decodedData = String(bytes: byteValues, encoding: .ascii) {
            return decodedData
        }
        
        return nil
    }
    
    static func formatUTC(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.string(from: date)
    }
    
    static func calculateTime(currentDate: Date, targetDate: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: currentDate, to: targetDate)
        
        let years = components.year ?? 0
        let months = components.month ?? 0
        let days = components.day ?? 0
        
        if years != 0 {
            return String(format: LocalizationSystem.daysMonthsYearsCount, years, months, days)
        } else if months != 0{
            return String(format: LocalizationSystem.daysMonthsCount, months, days)
        } else if days > 0 {
            return String(format: LocalizationSystem.daysCount, days)
        } else {
            return "Expired"
        }
    }
    
    static func formatAlgorithmType(from string: String) -> String? {
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
    
    static func formatBoolean(from string: String) -> String {
        let formattedString = string.lowercased()

        if formattedString == "true" {
            return "Yes"
        } else {
            return "No"
        }
    }
    
    //Парсим hex значение SHA256
    static func parseSHA256Digest(digest: SHA256Digest?) -> String {
        if let sha256Digest = digest {
            return sha256Digest.map { String(format: "%02hhx", $0) }.joined(separator: " ")
        } else {
            return ""
        }
    }
    
    //Парсим hex значение SHA1
    static func parseSHA1Digest(digest: Insecure.SHA1Digest?) -> String {
        if let sha1Digest = digest {
            return sha1Digest.map { String(format: "%02hhx", $0) }.joined(separator: " ")
        } else {
            return ""
        }
    }
    
    static func formatSignatureAlgorithm(_ signatureAlgorithm: String) -> String {
        var description: String {
            var algorithm: String = ""

            if signatureAlgorithm == "SignatureAlgorithm.sha1WithRSAEncryption" {
                algorithm = "SHA-1 With RSA Encryption"
            }
            if signatureAlgorithm == "SignatureAlgorithm.sha256WithRSAEncryption" {
                algorithm = "SHA-256 With RSA Encryption"
            }
            if signatureAlgorithm == "SignatureAlgorithm.sha384WithRSAEncryption" {
                algorithm = "SHA-384 With RSA Encryption"
            }
            if signatureAlgorithm == "SignatureAlgorithm.sha512WithRSAEncryption" {
                algorithm = "SHA-512 With RSA Encryption"
            }
            if signatureAlgorithm == "SignatureAlgorithm.ecdsaWithSHA256" {
                algorithm = "SHA-1 With ECDSA Encryption"
            }
            if signatureAlgorithm == "SignatureAlgorithm.ecdsaWithSHA384" {
                algorithm = "SHA-384 With ECDSA Encryption"
            }
            if signatureAlgorithm == "SignatureAlgorithm.ecdsaWithSHA512" {
                algorithm = "SHA-512 With ECDSA Encryption"
            }

            return algorithm
        }
        return description
    }
}
