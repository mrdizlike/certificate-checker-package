# Localization
You can create your own localization. Use LocalizationSystem structure and translate the strings into your language.

## Usage
1. Create .strings file with your localization, example:
```swift
    "subject" = "СУБЪЕКТ";
```
2. Use LocalizationSystem struct
```swift
    LocalizationSystem.subject = NSLocalizedString("subject", comment: "")
```

## Enjoy!
