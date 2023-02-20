//
// CacheRepositoryProtocol.swift
// Copyright (c) 2022 Nemlig.com. All rights reserved.
//

import Combine
import Foundation

public protocol CacheRepositoryProtocol {
    func getCacheEntry(id: String) -> AnyPublisher<CacheEntry?, Never>
    func addCacheEntry(cacheEntry: CacheEntry)
}
