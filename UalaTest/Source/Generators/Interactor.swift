//
//  Interactor.swift
//
//  Created by Daniel Tarazona on 5/25/21.
//  Copyright © 2021 Daniel Tarazona. All rights reserved.
//

import Foundation
import UIKit

let requestManager = RequestManager()

class RequestObject<T: Codable> {
    var uri: String
    var page: NSNumber?
    var itemsPerPage: NSNumber?
    var totalCount: NSNumber?
    var additionalQuery: String?

    required init() {
        self.uri = ""
    }
    
    init(
        uri: String,
        page: NSNumber?,
        itemsPerPage: NSNumber?,
        totalCount: NSNumber?,
        additionalQuery: String?
    ) {
        self.uri = uri
        self.page = page
        self.itemsPerPage = itemsPerPage
        self.totalCount = totalCount
        self.additionalQuery = additionalQuery
    }
}

class Interactor<
    Response: Codable,
    Request: RequestObject<Response>,
    TableView: UITableView,
    Header: UITableViewHeaderFooterView,
    Cell: UITableViewCell,
    Category: Hashable & CaseIterable,
    EmptyCell: UITableViewCell
> {
    
    typealias ReuseIdentifier = String

    var isLoading: Bool = false
    var withActivityIndicator: Bool = false
    var loadingView: UIView?
    var loadingIdentifier: Int?

    var items: [Response] = []
    var request: Request = Request()
    var response: Response?
    var category: Category?
    var categories: [Category?: Response?]
    var categoriesOrder: [Int: [Category: Response]]?

    var reuseIdentifiers: [Category?: ReuseIdentifier]
    var reuseIdentifier: ReuseIdentifier?
    var previousPageLink: String?

    var viewContoller: UIViewController!
    var tableView: UITableView!
    var headerView: UITableViewHeaderFooterView!
    var reusableCell: UITableViewCell!

    required init(UIViewController: UIViewController, UITableView: UITableView) {
        viewContoller = UIViewController
        tableView = UITableView

        category = Category.allCases.first
        categories = [Category?: Response?]()
        reuseIdentifiers = [Category: ReuseIdentifier]()
        reuseIdentifier = "\(Cell.self)"

        setup()
    }

    func load(completion: (() -> Void)? = nil) {
        loading(with: true)
        
        self.request(object: request) { response, _ in
            if let response = response {
                self.response = response
            }
            self.finish()
        }
    }

    func reload() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.tableView.reloadData()
            self?.tableView.setContentOffset(.zero, animated: true)
        }
    }

    func setup() {
        tableView.separatorStyle = .none
        registerCells()
    }

    func setReuseIdentifier(for category: Category, _ id: String = "\(Cell.self)") {
        reuseIdentifiers[category] = id
    }

    func getReuseIdentifier(for category: Category, indexPath: IndexPath) -> String {
        return reuseIdentifiers[category] ?? reuseIdentifier ?? ""
    }

    func registerCells(_ identifier: String = "\(Cell.self)") {
        tableView.register(
            Header.self,
            forHeaderFooterViewReuseIdentifier: "\(Header.self)"
        )

        tableView.register(EmptyCell.self, forCellReuseIdentifier: "\(EmptyCell.self)")

        headerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: "\(Header.self)"
        ) as? Header

        if let path = Bundle.main.path(forResource: identifier, ofType: "nib"),
            FileManager.default.fileExists(atPath: path) {
            let uiNib = UINib(nibName: identifier, bundle: .main)
            tableView.register(uiNib, forCellReuseIdentifier: identifier)
        } else {
            tableView.register(Cell.self, forCellReuseIdentifier: identifier)
        }
    }

    func loading(with activityIndicator: Bool = false) {
        isLoading = true
    }

    func finish() {
        isLoading = false
        reload()
    }

    func loadMore() {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfRows() -> Int {
        if items.count > 1 {
            return items.count
        }
        return 1
    }

    func cellEmpty() -> EmptyCell? {
        return tableView.dequeueReusableCell(
            withIdentifier: "\(EmptyCell.self)"
        ) as? EmptyCell
    }

    func isEmpty() -> Bool {
        return items.isEmpty
    }

    func getItem(at indexPath: IndexPath?) -> Response? {
        if let indexPath = indexPath, !items.isEmpty {
            return items[indexPath.row]
        }
        return nil
    }

    func cellRowAt(indexPath: IndexPath) -> Cell {
        if let category = category {
            let cellIdentifier = reuseIdentifiers[category]

            if let cell = tableView.dequeueReusableCell(
                withIdentifier: cellIdentifier ?? reuseIdentifier ?? ""
            ) as? Cell {
                reusableCell = cell
                cell.selectionStyle = .none
                return cell
            }
        }
        return Cell()
    }
}

// MARK: - Extensions

extension Interactor {

    func request(
        object: RequestObject<Response>,
        completion: ((_ response: Response?, _ error: Error?) -> Void)? = nil
    ) {

        func unwrap<T>(_ anyT: T) -> Any {
            let mirror = Mirror(reflecting: anyT)
            guard mirror.displayStyle == .optional, let first = mirror.children.first else {
                return anyT
            }
            return first.value
        }

        var uri = object.uri

        let objectMirror = Mirror(reflecting: object)

        for (property, values) in objectMirror.children {
            if let property = property {
                if case Optional<Any>.none = values { } else {
                    if let arrayValue = values as? [Any] {
                        for value in arrayValue {
                            uri.append("?\(property)=\(unwrap(value))")
                        }
                    } else {
                        uri.append("?\(property)=\((unwrap(values)))")
                    }
                }
            }
        }

        for (property, values) in objectMirror.superclassMirror!.children {
            if let property = property {
                if case Optional<Any>.none = values { } else {
                    if property == "uri" { } else {
                        uri.append("?\(property)=\((unwrap(values)))")
                    }
                }
            }
        }
        
        print(uri)

        requestManager.task(endpoint: uri, type: response) { response, error in
            if let response: Response = response as? Response {
                completion?(response, nil)
            }
        }
    }
}

