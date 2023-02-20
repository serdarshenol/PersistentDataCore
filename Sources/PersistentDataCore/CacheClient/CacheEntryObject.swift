//
// CacheEntryObject.swift
// Copyright (c) 2022 Nemlig.com. All rights reserved.
//

import Foundation
import RealmSwift

public final class CacheEntryObject: Object, DBStorable, Codable {
    @Persisted(primaryKey: true) public var id: String
    @Persisted public var url: String = ""
    @Persisted public var statusCode: Int = 0
    @Persisted public var responseData: Data = .init()
    @Persisted public var expirationDate: Date = .init()

    public convenience init(id: String,
                            url: String,
                            statusCode: Int,
                            responseData: Data,
                            expirationDate: Date) {
        self.init()
        self.id = id
        self.url = url
        self.statusCode = statusCode
        self.responseData = responseData
        self.expirationDate = expirationDate
    }
}
