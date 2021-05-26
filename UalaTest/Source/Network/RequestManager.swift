//
//  RequestManager.swift
//  UalaTest
//
//  Created by Daniel Tarazona on 5/25/21.
//

import Foundation

class RequestManager {
    private let session = URLSession.shared
    
    let requestURL = "https://www.themealdb.com/api/json/v1/1/"
    
    func task<T: Codable>(endpoint: String, type: T, completion: (@escaping (T?, Error?) -> Void )) {
        let requestURL = requestURL.appending("/\(endpoint)")
        if let url = URL(string: requestURL) {
            _ = session.codableTask(with: url, type: type) { data, response, error in
                let response = response as? HTTPURLResponse
                if error == nil {
                    if let data = data, let response = response, response.statusCode == 200 {
                        DispatchQueue.main.async {
                            completion(data, nil)
                        }
                    }
                } else {
                    completion(nil, error)
                }
            }
        }
    }
    
    func getImage(_ path: String, completion: (@escaping (Data?) -> Void )) {
        if let url = URL(string: path) {
            session.dataTask(with: url) { (data, response, error) in
                let response = response as? HTTPURLResponse
                if error == nil {
                    if let data = data, let response = response, response.statusCode == 200 {
                        DispatchQueue.main.async {
                            completion(data)
                        }
                    }
                } else {
                    print(error?.localizedDescription ?? "")
                }
            }.resume()
        }
    }
    
}
