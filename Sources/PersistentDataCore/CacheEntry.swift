//
// CacheEntry.swift
// Copyright (c) 2022 Nemlig.com. All rights reserved.
//

import Foundation

/**
 Designed to be used in core for creating entry for cache.
 */
public struct CacheEntry: Identifiable {
    public let id: String
    public let url: String
    public let statusCode: Int
    public let responseData: Data
    public let expirationDate: Date

    public init(id: String,
                url: String,
                statusCode: Int,
                responseData: Data,
                expirationDate: Date) {
        self.id = id
        self.url = url
        self.statusCode = statusCode
        self.responseData = responseData
        self.expirationDate = expirationDate
    }
}

public extension CacheEntry {
    static var mock: CacheEntry {
        let urlString = "https://live.nemligstatic.com/scommerce/images/groed-m-havre-abrikos-oeko.jpg?i=U7Po3wlx/5054927&w=250&h=250"

        return .init(id: "5054927",
                     url: urlString,
                     statusCode: 200,
                     responseData: urlString.data(using: .utf8) ?? .init(),
                     expirationDate: Date(timeIntervalSince1970: .zero))
    }
}
