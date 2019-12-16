//
//  ImageCell.swift
//  kimjongchan
//
//  Created by Jaycee on 2019/12/11.
//  Copyright © 2019 Jaycee. All rights reserved.
//

import Foundation
import Alamofire


protocol APIProtocol {
    static func products(_ pageNumber: Int) -> DataRequest
    static func productDetails(_ id: Int) -> DataRequest
}

struct API: APIProtocol {
    
    // MARK: - API Addresses
    fileprivate enum Address: String {
        case products = "products/"
        
        private var baseURL: String { return "https://2jt4kq01ij.execute-api.ap-northeast-2.amazonaws.com/prod/" }
        
        var url: URL {
            return URL(string: baseURL.appending(rawValue))!
        }
    }
    
    // MARK: - API Endpoint Requests
    static func products(_ pageNumber: Int) -> DataRequest {
        let url = URL(string: API.Address.products.url.absoluteString + "?page=\(pageNumber)") ?? URL.init(fileURLWithPath: "")
        return request(url: url, method: .get, parameters: [:])
    }
    
    static func productDetails(_ id: Int) -> DataRequest {
        let url = URL(string: API.Address.products.url.absoluteString + "\(id)") ?? URL.init(fileURLWithPath: "")
        return request(url: url, method: .get, parameters: [:])
    }
    
    // MARK: - Generic Request
    static private func request(url: URLConvertible, method:HTTPMethod, parameters: [String: Any] = [:]) -> DataRequest {
        return Alamofire.request(url,
                                 method: .get,
                                 parameters: Parameters(),
                                 encoding: URLEncoding.httpBody)
    }
    
}
