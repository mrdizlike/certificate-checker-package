//
//  File.swift
//  
//
//  Created by Виктор on 17.08.2023.
//

import Foundation
import UIKit

public class CertificateParserViewController: UIViewController {
    private lazy var parser: CertificateParser = {
        $0.viewController = self
        return $0
    }(CertificateParser())
    
    var activityIndicator: UIActivityIndicatorView!
    var localizationName = "Localizable"
    
    public init(url: URL) {
        super.init(nibName: nil, bundle: nil)
        
        activityIndicatorInit()
        view.frame = CGRect(x: 0, y: 10, width: view.frame.width, height: view.frame.height)
        parser.parseCertificateFromFile(url: url)
    }

    func activityIndicatorInit() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

