//
//  Network.swift
//  UalaTest
//
//  Created by Daniel Tarazona on 5/25/21.
//

import Foundation
import UIKit

protocol URLSessionDataTaskProtocol { func resume() }

protocol URLSessionProtocol {
    func dataTask<T: Codable>(
        with request: URLRequest,
        type: T.Type,
        completionHandler: @escaping (T?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol
    
    func dataTask<T: Codable>(
        with url: URL,  type: T.Type, completionHandler: @escaping (T?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTaskProtocol
}

