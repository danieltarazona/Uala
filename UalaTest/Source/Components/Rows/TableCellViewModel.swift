//
//  TableCellViewModel.swift
//  UalaTest
//
//  Created by Daniel Tarazona on 5/25/21.
//

import UIKit
import SnapKit

struct TableCellViewModel {
    var title: String
    var action: (() -> Void)?

    init(title: String, action: (() -> Void)? = nil) {
        self.title = title
        self.action = action
    }
}

class TableCellView<T: Codable>: UITableViewCell {

    let cellIdentifier = "TableCellView"

    var viewModel: TableCellViewModel? {
        didSet {
            guard let _ = viewModel else { return }
        }
    }

    private lazy var mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        return view
    }()

    private lazy var stackView = UIStackView(
        axis: .vertical,
        subviews: []
    ).autolayout()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        mainView.addSubview(stackView)

        addSubview(mainView)

        mainView.anchorToView(self, insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))

        mainView.snp.makeConstraints { (make) in
            make.height.equalTo(360)
            make.width.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
        }
    }
}

