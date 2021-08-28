//
//  ParsingManager.swift
//  OpenMarket
//
//  Created by Yongwoo Marco on 2021/08/19.
//

import Foundation

struct DecodingHandler {
    private let decoder = JSONDecoder()
    
    init() {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
}
