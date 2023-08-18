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
    
    public init(url: URL) {
        super.init(nibName: nil, bundle: nil)
        
        parser.parseCertificateFromFile(url: url)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

