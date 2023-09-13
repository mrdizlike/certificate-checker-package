//
//  ViewCertificateDetails.swift
//  certificate-checker
//
//  Created by Виктор on 08.08.2023.
//

import UIKit

class ViewCertificateDetails: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private lazy var tableView: UITableView = {
        $0.delegate = self
        $0.dataSource = self
        $0.tableFooterView = UIView(
            frame:
                CGRect(
                    origin: .zero,
                    size: CGSize(width: 0, height: 100)
                )
        )
        $0.allowsSelection = false
        $0.register(CustomCell.self, forCellReuseIdentifier: "cell")
        return $0
    }(UITableView(frame: .zero, style: .grouped))
    
    var certificate: CertificateInfo?
    var certificateExtensionReader: CertificateExtensionsReader = CertificateExtensionsReader()
    var sections: [Section] = []
    var extensionSections: [Section] = []
    
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
        self.navigationController?.navigationBar.backgroundColor = .white
        
        // Делаем по секции на каждое найденное расширение сертификата
        for extensionInfo in certificate!.certificateExtInfo {
            let extensionSection = Section(title: (certificateExtensionReader.oidStrings[extensionInfo.oid] ?? "Unknown Extension "), rows: [
                Row(title: LocalizationSystem.value, value: extensionInfo.value),
                Row(title: LocalizationSystem.critical, value: CertificateUtils.formatBoolean(from: extensionInfo.critical.description))
            ])
            extensionSections.append(extensionSection)
        }
        
        sections = [
            Section(title: LocalizationSystem.subject, rows: [
                Row(title: LocalizationSystem.userID, value: certificate?.userID),
                Row(title: LocalizationSystem.commonName, value: certificate?.subjectCN),
                Row(title: LocalizationSystem.organizationalUnit, value: certificate?.subjectOU),
                Row(title: LocalizationSystem.organization, value: certificate?.subjectO),
                Row(title: LocalizationSystem.country, value: certificate?.subjectC),
                Row(title: LocalizationSystem.state, value: certificate?.subjectS),
                Row(title: LocalizationSystem.location, value: certificate?.subjectL),
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
            Section(title: LocalizationSystem.serialNumber, rows: [
                Row(title: LocalizationSystem.serialNumber, value: certificate?.serialNumber)].filter { row in
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
                Row(title: LocalizationSystem.modulus, value: certificate?.modulus),
                Row(title: LocalizationSystem.decimal, value: certificate?.decimalValue),
                Row(title: LocalizationSystem.blockSize, value: certificate?.blockSize),
                Row(title: LocalizationSystem.keySize, value: certificate?.keySize)
                ].filter { row in
                    return checkField(row.value) != "none"
                }),
            Section(title: LocalizationSystem.signature, rows: [
                Row(title: LocalizationSystem.signature, value: certificate?.signature),
                Row(title: LocalizationSystem.signature, value: certificate?.signatureHex)
            ]),
            Section(title: LocalizationSystem.fingerPrints, rows: [
                Row(title: LocalizationSystem.sha256, value: certificate?.sha256FingerPrint),
                Row(title: LocalizationSystem.sha1, value: certificate?.sha1FingerPrint)
            ]),
            Section(title: "", rows: [
                Row(title: LocalizationSystem.version, value: certificate?.version)
            ])
            ] + extensionSections
        
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
