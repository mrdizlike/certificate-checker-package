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
                Section(title: NSLocalizedString("subject", bundle: .module, comment: ""), rows: [
                    Row(title: NSLocalizedString("common_name", bundle: .module, comment: ""), value: certificate?.subjectCN),
                    Row(title: NSLocalizedString("country", bundle: .module, comment: ""), value: certificate?.subjectC),
                    Row(title: NSLocalizedString("organization", bundle: .module, comment: ""), value: certificate?.subjectO),
                    Row(title: NSLocalizedString("state", bundle: .module, comment: ""), value: certificate?.subjectL),
                    Row(title: NSLocalizedString("organizational_unit", bundle: .module, comment: ""), value: certificate?.subjectOU)
                ]),
                Section(title: NSLocalizedString("issuer", bundle: .module, comment: ""), rows: [
                    Row(title: NSLocalizedString("common_name", bundle: .module, comment: ""), value: certificate?.issuerCN),
                    Row(title: NSLocalizedString("country", bundle: .module, comment: ""), value: certificate?.issuerC),
                    Row(title: NSLocalizedString("organization", bundle: .module, comment: ""), value: certificate?.issuerO),
                    Row(title: NSLocalizedString("organizational_unit", bundle: .module, comment: ""), value: certificate?.issuerOU)
                ]),
                Section(title: NSLocalizedString("validity_period", bundle: .module, comment: ""), rows: [
                    Row(title: NSLocalizedString("validity_before", bundle: .module, comment: ""), value: "\(certificate!.validityBefore)"),
                    Row(title: NSLocalizedString("validity_after", bundle: .module, comment: ""), value: "\(certificate!.validityAfter)"),
                    Row(title: NSLocalizedString("valid_for", bundle: .module, comment: ""), value: "\(certificate!.validFor)"),
                    Row(title: NSLocalizedString("will_expire_in", bundle: .module, comment: ""), value: "\(certificate!.willExpireIn)")
                ]),
                Section(title: NSLocalizedString("key_usage", bundle: .module, comment: ""), rows: [
                    Row(title: NSLocalizedString("basic", bundle: .module, comment: ""), value: certificate?.keyUsageBasic),
                    Row(title: NSLocalizedString("extended", bundle: .module, comment: ""), value: certificate?.keyUsageExtended)
                ]),
                Section(title: NSLocalizedString("public_key", bundle: .module, comment: ""), rows: [
                    Row(title: NSLocalizedString("signature_algorithm", bundle: .module, comment: ""), value: certificate?.signatureAlgorithm),
                    Row(title: NSLocalizedString("signature", bundle: .module, comment: ""), value: certificate?.signature)
                ]),
                Section(title: NSLocalizedString("key_identifier", bundle: .module, comment: ""), rows: [
                    Row(title: NSLocalizedString("subject_key_id", bundle: .module, comment: ""), value: certificate?.subjectKeyId),
                    Row(title: NSLocalizedString("authority_key_id", bundle: .module, comment: ""), value: certificate?.authorityKeyId)
                ]),
                Section(title: NSLocalizedString("metadata", bundle: .module, comment: ""), rows: [
                    Row(title: NSLocalizedString("serial_number", bundle: .module, comment: ""), value: certificate?.serialNumber),
                    Row(title: NSLocalizedString("certificate_authority", bundle: .module, comment: ""), value: certificate?.certificateAuthority),
                    Row(title: NSLocalizedString("version", bundle: .module, comment: ""), value: certificate?.version)
                ])
            ]
        
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CustomCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
    }
}
