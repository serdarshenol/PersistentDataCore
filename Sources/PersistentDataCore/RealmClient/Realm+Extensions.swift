//
// Realm+Extensions.swift
// Copyright (c) 2022 Nemlig.com. All rights reserved.
//

import Combine
import Foundation
import RealmSwift

extension Realm.Configuration {
    static var cacheEntry: Realm.Configuration {
        var config = Realm.Configuration(
            fileURL: try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("cache-entry"),
            deleteRealmIfMigrationNeeded: true,
            objectTypes: [CacheClient.DBObjectType.self]
        )

        #if DEBUG
        config.maximumNumberOfActiveVersions = 40
        #else
        config.maximumNumberOfActiveVersions = 64
        #endif
        return config
    }
}

extension Realm {
    public static func createAsPublisher(createOnQueue: DispatchQueue,
                                         configuration: Realm.Configuration) -> AnyPublisher<Realm, Swift.Error> {
        Just(true)
            .subscribe(on: createOnQueue)
            .tryMap { _ in
                try Realm(configuration: configuration)
            }
            .eraseToAnyPublisher()
    }
}

extension Results {
    func toArray<T>(ofType _: T.Type) -> [T] {
        self.compactMap { $0 as? T }
    }
}
