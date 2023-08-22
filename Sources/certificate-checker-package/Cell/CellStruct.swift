//
//  CellStruct.swift
//
//
//  Created by Виктор on 21.08.2023.
//

import Foundation

struct Row {
    let title: String
    let value: String?
}

struct Section {
    let title: String
    let rows: [Row]
}
