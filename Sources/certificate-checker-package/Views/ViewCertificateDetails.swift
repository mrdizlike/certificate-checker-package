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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        
        guard let certificate = certificate else {
            return cell
        }
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Common Name: \(checkField(certificate.subjectCN))"
            case 1:
                cell.textLabel?.text = "Country: \(checkField(certificate.subjectC))"
            case 2:
                cell.textLabel?.text = "Organization: \(checkField(certificate.subjectO))"
            case 3:
                cell.textLabel?.text = "State: \(checkField(certificate.subjectL))"
            case 4:
                cell.textLabel?.text = "Organizational Unit: \(checkField(certificate.subjectOU))"
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Common Name: \(checkField(certificate.issuerCN))"
            case 1:
                cell.textLabel?.text = "Country: \(checkField(certificate.issuerC))"
            case 2:
                cell.textLabel?.text = "Organization: \(checkField(certificate.issuerO))"
            case 3:
                cell.textLabel?.text = "Organizational Unit: \(checkField(certificate.issuerOU))"
            default:
                break
            }
        case 2:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Validity Before: \(certificate.validityBefore)"
            case 1:
                cell.textLabel?.text = "Validity After: \(certificate.validityAfter)"
            default:
                break
            }
        case 3:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Key Usage: \(checkField(certificate.keyUsage?.description))"
            default:
                break
            }
        case 4:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Signature Algorithm: \(checkField(certificate.signatureAlgorithm.description))"
            case 1:
                cell.textLabel?.text = "Signature: \(checkField(certificate.signature.description))"
            default:
                break
            }
        case 5:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Subject keyID: \(checkField(certificate.subjectKeyId?.description))"
            case 1:
                cell.textLabel?.text = "Authority: \(checkField(certificate.authorityKeyId?.description))"
            default:
                break
            }
        case 6:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Serial Number: \(checkField(certificate.serialNumber.description))"
            case 1:
                cell.textLabel?.text = "Certificate Authority: \(checkField(certificate.certificateAuthority?.description))"
            case 2:
                cell.textLabel?.text = "Version: \(checkField(certificate.version.description))"
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
    }
}
