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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewController()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }

    //Количество строк в подзаголовках
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 5
        case 1:
            return 4
        case 2:
            return 2
        case 3:
            return 1
        case 4:
            return 2
        case 5:
            return 2
        case 6:
            return 3
        default:
            return 0
        }
    }

    //Подзаголовки
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "SUBJECT"
        case 1:
            return "ISSUER"
        case 2:
            return "VALIDITY PERIOD"
        case 3:
            return "KEY USAGE"
        case 4:
            return "PUBLIC KEY"
        case 5:
            return "KEY IDENTIFIER"
        case 6:
            return "METADATA"
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CustomCell(style: .subtitle, reuseIdentifier: "cell")
        
        guard let certificate = certificate else {
            return cell
        }
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "Common Name"
                cell.infoLabel.text = checkField(certificate.subjectCN)
            case 1:
                cell.titleLabel.text = "Country"
                cell.infoLabel.text = checkField(certificate.subjectC)
            case 2:
                cell.titleLabel.text = "Organization"
                cell.infoLabel.text = checkField(certificate.subjectO)
            case 3:
                cell.titleLabel.text = "State"
                cell.infoLabel.text = checkField(certificate.subjectL)
            case 4:
                cell.titleLabel.text = "Organizational Unit"
                cell.infoLabel.text = checkField(certificate.subjectOU)
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "Common Name"
                cell.infoLabel.text = checkField(certificate.issuerCN)
            case 1:
                cell.titleLabel.text = "Country"
                cell.infoLabel.text = checkField(certificate.issuerC)
            case 2:
                cell.titleLabel.text = "Organization"
                cell.infoLabel.text = checkField(certificate.issuerO)
            case 3:
                cell.titleLabel.text = "Organizational Unit"
                cell.infoLabel.text = checkField(certificate.issuerOU)
            default:
                break
            }
        case 2:
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "Validity Before"
                cell.infoLabel.text = "\(certificate.validityBefore)"
            case 1:
                cell.titleLabel.text = "Validity After"
                cell.infoLabel.text = "\(certificate.validityAfter)"
            default:
                break
            }
        case 3:
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "Key Usage"
                cell.infoLabel.text = checkField(certificate.keyUsage?.description)
            default:
                break
            }
        case 4:
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "Signature Algorithm"
                cell.infoLabel.text = checkField(certificate.signatureAlgorithm.description)
            case 1:
                cell.titleLabel.text = "Signature"
                cell.infoLabel.text = checkField(certificate.signature.description)
            default:
                break
            }
        case 5:
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "Subject keyID"
                cell.infoLabel.text = checkField(certificate.subjectKeyId?.description)
            case 1:
                cell.titleLabel.text = "Authority"
                cell.infoLabel.text = checkField(certificate.authorityKeyId?.description)
            default:
                break
            }
        case 6:
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "Serial Number"
                cell.infoLabel.text = checkField(certificate.serialNumber.description)
            case 1:
                cell.titleLabel.text = "Certificate Authority"
                cell.infoLabel.text = checkField(certificate.certificateAuthority?.description)
            case 2:
                cell.titleLabel.text = "Version"
                cell.infoLabel.text = checkField(certificate.version.description)
            default:
                break
            }
        default:
            break
        }
        
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
        
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CustomCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
    }
}
