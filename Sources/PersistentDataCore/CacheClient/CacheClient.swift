//
// CacheClient.swift
// Copyright (c) 2022 Nemlig.com. All rights reserved.
//

import Accelerate
import Combine
import Foundation
import RealmSwift

final class CacheClient: CacheClientProtocol {
    typealias DBObjectType = CacheEntryObject
    typealias EntryType = CacheEntry

    private let maxEntry: Int
    private let realmClient: RealmClientProtocol
    private let dispatchQueue = DispatchQueue(label: "com.nemlig.cache-entry.db", qos: .userInteractive)
    private var subscriptions = Set<AnyCancellable>()

    init(realmClient: RealmClientProtocol,
         maxEntry: Int) {
        self.realmClient = realmClient
        self.maxEntry = maxEntry
    }

    func addCacheEntry(cacheEntry entry: EntryType) {
        dispatchQueue.async {
            autoreleasepool {
                try? self.realmClient.write(self.map(entry: entry))
            }
        }

        getCacheEntries()
            .sink(receiveValue: { [weak self] entries in
                while entries.count > self?.maxEntry ?? 0 {
                    try? self?.realmClient.delete(entries[entries.count - 1])
                }
            })
            .store(in: &subscriptions)
    }

    func getCacheEntry(id: String) -> AnyPublisher<EntryType?, Never> {
        getCacheEntries()
            .map { [weak self] entries in
                if let entry = entries.first(where: { $0.id == id }) {
                    if entry.expirationDate < Date() {
                        print("Cache expired with ID: \(id)")
                        try? self?.realmClient.delete(entry)
                        return nil
                    }
                    try? self?.realmClient.write(entry)
                    return self?.map(entry: entry)
                } else {
                    return nil
                }
            }
            .ignoreError()
            .eraseToAnyPublisher()
    }

    func clear() {
        realmClient.deleteAll()
    }

    private func getCacheEntries() -> AnyPublisher<[DBObjectType], Never> {
        realmClient.readAll(DBObjectType.self)
            .ignoreError()
            .eraseToAnyPublisher()
    }

    private func map(entry: DBObjectType) -> EntryType {
        .init(id: entry.id,
              url: entry.url,
              statusCode: entry.statusCode,
              responseData: entry.responseData,
              expirationDate: entry.expirationDate)
    }

    private func map(entry: EntryType) -> DBObjectType {
        .init(id: entry.id,
              url: entry.url,
              statusCode: entry.statusCode,
              responseData: entry.responseData,
              expirationDate: entry.expirationDate)
    }
}
