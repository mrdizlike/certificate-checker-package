//
//  ViewAvailableCertificates.swift
//  certificate-checker
//
//  Created by Виктор on 09.08.2023.
//

import Foundation
import UIKit

class ViewAvailableCertificates: UIViewController, UITableViewDataSource, UITableViewDelegate, UIDocumentPickerDelegate {
    
    
    var tableView: UITableView!
    var certificates: [CertificateInfo] = [] // Данные сертификатов
    var selectedCertificate: CertificateInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewController()

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return certificates.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Certificates"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let certificate = certificates[indexPath.row]
        
        cell.textLabel?.text = "\(certificate.subjectCN)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCertificate = certificates[indexPath.row]
            
        let detailsVC = ViewCertificateDetails()
        detailsVC.certificate = selectedCertificate
        
        navigationController?.pushViewController(detailsVC, animated: true)
    }
    
    func setupViewController() {
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        tableView.reloadData()
    }
}
