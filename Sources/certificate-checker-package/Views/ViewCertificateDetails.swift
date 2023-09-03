//
//  ViewCertificateDetails.swift
//  certificate-checker
//
//  Created by Виктор on 08.08.2023.
//

import UIKit

class ViewCertificateDetails: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var tableView: UITableView!
    var certificate: CertificateInfo?
    var certificateExtensionReader: CertificateExtensionsReader = CertificateExtensionsReader()
    var sections: [Section] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewController()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    //Количество строк в подзаголовках
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    //Подзаголовки
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CustomCell(style: .subtitle, reuseIdentifier: "cell")
        let row = sections[indexPath.section].rows[indexPath.row]
        cell.titleLabel.text = row.title
        cell.infoLabelSetup(withText: checkField(row.value))
        return cell
    }

    //Проверка на наличие информации в поле
    func checkField(_ value: String?) -> String {
        if let value = value, !value.isEmpty {
            return value
        } else {
            return "none"
        }
    }

    
    func setupViewController() {
        title = certificate?.subjectCN
        sections = [
            Section(title: LocalizationSystem.subject, rows: [
                Row(title: "userID", value: certificate?.userID),
                Row(title: LocalizationSystem.commonName, value: certificate?.subjectCN),
                Row(title: LocalizationSystem.organizationalUnit, value: certificate?.subjectOU),
                Row(title: LocalizationSystem.organization, value: certificate?.subjectO),
                Row(title: LocalizationSystem.country, value: certificate?.subjectC),
                Row(title: LocalizationSystem.state, value: certificate?.subjectL),
                Row(title: LocalizationSystem.email, value: certificate?.email)
                ].filter { row in
                    return checkField(row.value) != "none"
                }),
            Section(title: LocalizationSystem.issuer, rows: [
                Row(title: LocalizationSystem.commonName, value: certificate?.issuerCN),
                Row(title: LocalizationSystem.organizationalUnit, value: certificate?.issuerOU),
                Row(title: LocalizationSystem.organization, value: certificate?.issuerO),
                Row(title: LocalizationSystem.country, value: certificate?.issuerC)
                ].filter { row in
                    return checkField(row.value) != "none"
                }),
            Section(title: "Serial number", rows: [
                Row(title: "Serial number", value: certificate?.serialNumber)].filter { row in
                    return checkField(row.value) != "none"
                }),
            Section(title: LocalizationSystem.validityPeriod, rows: [
                Row(title: LocalizationSystem.validityBefore, value: "\(certificate!.validityBefore)"),
                Row(title: LocalizationSystem.validityAfter, value: "\(certificate!.validityAfter)"),
                Row(title: LocalizationSystem.validFor, value: "\(certificate!.validFor)"),
                Row(title: LocalizationSystem.willExpireIn, value: "\(certificate!.willExpireIn)")
                ].filter { row in
                    return checkField(row.value) != "none"
                }),
            Section(title: LocalizationSystem.publicKey, rows: [
                Row(title: LocalizationSystem.signatureAlgorithm, value: certificate?.signatureAlgorithm),
                Row(title: "Modulus", value: certificate?.modulus),
                Row(title: "Decimal", value: certificate?.decimalValue),
                Row(title: "Block size", value: certificate?.blockSize),
                Row(title: "Key size", value: certificate?.keySize)
                ].filter { row in
                    return checkField(row.value) != "none"
                }),
            Section(title: "Certificate Extensions", rows: certificate!.certificateExtInfo.map { extensionInfo in
                return Row(title: (certificateExtensionReader.oidStrings[extensionInfo.oid] ?? "Unknown Extension ") + " (\(extensionInfo.oid))" , value:
                            "\(extensionInfo.value) \nCritical: \(CertificateUtils.formatBoolean(from: extensionInfo.critical.description))"
                )
            }),
            Section(title: "Signature", rows: [
                Row(title: LocalizationSystem.signature, value: certificate?.signature),
                Row(title: "Signature", value: certificate?.signatureHex)
            ]),
            Section(title: "Fingerprints", rows: [
                Row(title: "SHA-256", value: certificate?.sha256FingerPrint),
                Row(title: "SHA-1", value: certificate?.sha1FingerPrint)
            ]),
            Section(title: "", rows: [
                Row(title: LocalizationSystem.version, value: certificate?.version)
            ])
            ]
        
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CustomCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
    }
}
