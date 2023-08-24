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
        return sections[section].rows.filter { checkField($0.value) != "none" }.count
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
                Row(title: LocalizationSystem.commonName, value: certificate?.subjectCN),
                Row(title: LocalizationSystem.country, value: certificate?.subjectC),
                Row(title: LocalizationSystem.organization, value: certificate?.subjectO),
                Row(title: LocalizationSystem.state, value: certificate?.subjectL),
                Row(title: LocalizationSystem.organizationalUnit, value: certificate?.subjectOU)
                ]),
            Section(title: LocalizationSystem.issuer, rows: [
                Row(title: LocalizationSystem.commonName, value: certificate?.issuerCN),
                Row(title: LocalizationSystem.country, value: certificate?.issuerC),
                Row(title: LocalizationSystem.organization, value: certificate?.issuerO),
                Row(title: LocalizationSystem.organizationalUnit, value: certificate?.issuerOU)
                ]),
            Section(title: LocalizationSystem.validityPeriod, rows: [
                Row(title: LocalizationSystem.validityBefore, value: "\(certificate!.validityBefore)"),
                Row(title: LocalizationSystem.validityAfter, value: "\(certificate!.validityAfter)"),
                Row(title: LocalizationSystem.validFor, value: "\(certificate!.validFor)"),
                Row(title: LocalizationSystem.willExpireIn, value: "\(certificate!.willExpireIn)")
                ]),
            Section(title: LocalizationSystem.keyUsage, rows: [
                Row(title: LocalizationSystem.basic, value: certificate?.keyUsageBasic),
                Row(title: LocalizationSystem.extended, value: certificate?.keyUsageExtended)
                ]),
            Section(title: LocalizationSystem.publicKey, rows: [
                Row(title: LocalizationSystem.signatureAlgorithm, value: certificate?.signatureAlgorithm),
                Row(title: LocalizationSystem.signature, value: certificate?.signature)
                ]),
            Section(title: LocalizationSystem.keyIdentifier, rows: [
                Row(title: LocalizationSystem.subjectKeyId, value: certificate?.subjectKeyId),
                Row(title: LocalizationSystem.authorityKeyId, value: certificate?.authorityKeyId)
                ]),
            Section(title: LocalizationSystem.metadata, rows: [
                Row(title: LocalizationSystem.serialNumber, value: certificate?.serialNumber),
                Row(title: LocalizationSystem.certificateAuthority, value: certificate?.certificateAuthority),
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
