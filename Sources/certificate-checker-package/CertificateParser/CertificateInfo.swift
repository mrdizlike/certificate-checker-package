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
    //MARK: ISSUER
    let issuerCN: String //Издатель сертификата
    let issuerC: String //Страна издателя
    let issuerO: String //Организация издателя
    let issuerOU: String //Организационный союз
    //MARK: VALIDITY PERIOD
    let validityBefore: Date //Дата ДО
    let validityAfter: Date //Дата ПОСЛЕ
    //MARK: KEY USAGE
    let keyUsage: ExtendedKeyUsage? // Использование ключа
    //MARK: PUBLIC KEY
    let signatureAlgorithm: Certificate.SignatureAlgorithm //Алгоритм подписи
    let signature: Certificate.Signature //Подпись сертификата
    //MARK: KEY IDENTIFIER
    let subjectKeyId: SubjectKeyIdentifier? //Идентификатор ключа владельца сертификата
    let authorityKeyId: AuthorityKeyIdentifier? //Идентификатор ключа издателя сертификата
    //MARK: METADATA
    let serialNumber: Certificate.SerialNumber //Серийный номер сертификата
    let certificateAuthority: AuthorityInformationAccess? //Доступ к информации издателя сертификата
    let version: Certificate.Version //Версия сертификата
}

