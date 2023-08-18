# certificate-checker

## Overview

**certificate-checker** will allow you to view certificate details

## Usage
```swift
    //Create certificate from URL (WEB or local file)
    var certificate = CertificateParserViewController(url: URL(string: "apple.com")!)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(certificate.view)
    }
```

## Enjoy!
