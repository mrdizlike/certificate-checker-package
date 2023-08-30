//
//  CertificateInfo.swift
//  CertificateChecker
//
//  Created by Виктор on 06.08.2023.
//

import Foundation
import X509

struct CertificateInfo {
    //MARK: SUBJECT
    let subjectCN: String //Владелец сертификата
    let subjectC: String //Страна владельца
    let subjectL: String //Город/штат владельца
    let subjectO: String //Организация владельца
    let subjectOU: String //Организационный союз
    let email: String //Почта
    //MARK: ISSUER
    let issuerCN: String //Издатель сертификата
    let issuerC: String //Страна издателя
    let issuerO: String //Организация издателя
    let issuerOU: String //Организационный союз
    //MARK: VALIDITY PERIOD
    let validityBefore: String //Дата ДО
    let validityAfter: String //Дата ПОСЛЕ
    let validFor: String //Работает ДО
    let willExpireIn: String //Сколько уже работает
    //MARK: PUBLIC KEY
    let signatureAlgorithm: String //Алгоритм подписи
    let signature: String //Подпись сертификата
    //MARK: METADATA
    let serialNumber: String //Серийный номер сертификата
    let version: String //Версия сертификата
    let certificateExtInfo: [CertificateExtensionStruct]
    let sha256FingerPrint: String
    let sha1FingerPrint: String
}

