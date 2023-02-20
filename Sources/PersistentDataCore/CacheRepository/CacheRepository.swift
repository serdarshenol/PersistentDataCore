//
// CacheRepository.swift
// Copyright (c) 2022 Nemlig.com. All rights reserved.
//

import Combine
import Foundation

final class CacheRepository: CacheRepositoryProtocol {
    private let cacheClient: CacheClientProtocol

    init(cacheClient: CacheClientProtocol) {
        self.cacheClient = cacheClient
    }

    func getCacheEntry(id: String) -> AnyPublisher<CacheEntry?, Never> {
        cacheClient.getCacheEntry(id: id)
    }

    func addCacheEntry(cacheEntry: CacheEntry) {
        cacheClient.addCacheEntry(cacheEntry: cacheEntry)
    }
}
