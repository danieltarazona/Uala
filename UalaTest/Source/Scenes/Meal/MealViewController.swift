//
//  MealViewController.swift
//  UalaTest
//
//  Created by Daniel Tarazona on 5/25/21.
//

import Foundation
import UIKit

class MealViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var interactor: Interactor<
        Meal,
        MealRequest,
        UITableView,
        UITableViewHeaderFooterView,
        TableCellView<Meal>,
        MealCategory,
        EmptyCell
    >!

    override func viewDidLoad() {
        interactor = Interactor(
            UIViewController: self,
            UITableView: tableView
        )
        
        textField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        interactor.load()
    }
}

extension MealViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return interactor.numberOfSections()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 256
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return interactor.numberOfRows()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            if let headerView = interactor.headerView {
                return headerView
            }
        }
        return nil
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if interactor.isEmpty() {
            let cell = interactor.cellEmpty() ?? EmptyCell()
            return cell
        }

        if let _ = interactor.getItem(at: indexPath) {
            let cell = interactor.cellRowAt(indexPath: indexPath)
            return cell
        }
        return UITableViewCell()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        interactor.request.s = textField.text ?? ""
        interactor.load()
    }
}

