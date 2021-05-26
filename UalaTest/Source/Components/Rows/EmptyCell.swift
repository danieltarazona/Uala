//
//  EmptyCell.swift
//  UalaTest
//
//  Created by Daniel Tarazona on 5/25/21.
//

import UIKit

class EmptyCell: UITableViewCell {

    var view = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUp()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUp() {
        selectionStyle = .none
    }
}
