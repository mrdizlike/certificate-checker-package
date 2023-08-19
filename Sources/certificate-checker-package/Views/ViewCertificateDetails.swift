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
                Section(title: "SUBJECT", rows: [
                    Row(title: "Common Name", value: certificate?.subjectCN),
                    Row(title: "Country", value: certificate?.subjectC),
                    Row(title: "Organization", value: certificate?.subjectO),
                    Row(title: "State", value: certificate?.subjectL),
                    Row(title: "Organizational Unit", value: certificate?.subjectOU)
                ]),
                Section(title: "ISSUER", rows: [
                    Row(title: "Common Name", value: certificate?.issuerCN),
                    Row(title: "Country", value: certificate?.issuerC),
                    Row(title: "Organization", value: certificate?.issuerO),
                    Row(title: "Organizational Unit", value: certificate?.issuerOU)
                ]),
                Section(title: "VALIDITY PERIOD", rows: [
                    Row(title: "Validity Before", value: "\(certificate!.validityBefore)"),
                    Row(title: "Validity After", value: "\(certificate!.validityAfter)"),
                    Row(title: "Valid For", value: "\(certificate!.validFor)"),
                    Row(title: "Will Expire In", value: "\(certificate!.willExpireIn)")
                ]),
                Section(title: "KEY USAGE", rows: [
                    Row(title: "Basic", value: certificate?.keyUsageBasic),
                    Row(title: "Extended", value: certificate?.keyUsageExtended)
                ]),
                Section(title: "PUBLIC KEY", rows: [
                    Row(title: "Signature Algorithm", value: certificate?.signatureAlgorithm),
                    Row(title: "Signature", value: certificate?.signature)
                ]),
                Section(title: "KEY IDENTIFIER", rows: [
                    Row(title: "Subject", value: certificate?.subjectKeyId),
                    Row(title: "Authority", value: certificate?.authorityKeyId)
                ]),
                Section(title: "METADATA", rows: [
                    Row(title: "Serial Number", value: certificate?.serialNumber),
                    Row(title: "Certificate Authority", value: certificate?.certificateAuthority),
                    Row(title: "Version", value: certificate?.version)
                ])
            ]
        
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CustomCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
    }
}
