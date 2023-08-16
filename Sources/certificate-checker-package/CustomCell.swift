//
//  CustomCell.swift
//
//
//  Created by Виктор on 16.08.2023.
//

import UIKit

class CustomCell: UITableViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    var sideBySideConstraints: [NSLayoutConstraint] = []
    var stackedConstraints: [NSLayoutConstraint] = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(infoLabel)
        
        // Дефолтные constraints
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            
            infoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            infoLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
        
        // Constraints для side-by-side расположения
        sideBySideConstraints = [
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: infoLabel.leadingAnchor, constant: -10),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            infoLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5)
        ]
        
        // Constraints для stacked расположения
        stackedConstraints = [
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            titleLabel.bottomAnchor.constraint(equalTo: infoLabel.topAnchor, constant: -5),
            infoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15)
        ]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let text = infoLabel.text, text.count > 25 {
            NSLayoutConstraint.deactivate(sideBySideConstraints)
            NSLayoutConstraint.activate(stackedConstraints)
            infoLabel.textAlignment = .left
        } else {
            NSLayoutConstraint.deactivate(stackedConstraints)
            NSLayoutConstraint.activate(sideBySideConstraints)
        }
    }
}
