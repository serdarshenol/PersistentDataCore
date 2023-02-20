//
// CacheClientProtocol.swift
// Copyright (c) 2022 Nemlig.com. All rights reserved.
//

import Combine
import Foundation

protocol CacheClientProtocol {
    func getCacheEntry(id: String) -> AnyPublisher<CacheClient.EntryType?, Never>
    func addCacheEntry(cacheEntry: CacheClient.EntryType)
    func clear()
}
