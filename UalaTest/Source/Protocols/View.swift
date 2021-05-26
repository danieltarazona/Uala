//
//  View.swift
//  UalaTest
//
//  Created by Daniel Tarazona on 5/25/21.
//

import Foundation
import UIKit

typealias UIViewControllerLoadable = UIViewController & Loadable

protocol Loadable {
    func start()
    func finish()
}
