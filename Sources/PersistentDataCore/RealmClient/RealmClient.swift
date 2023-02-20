//
// RealmClient.swift
// Copyright (c) 2022 Nemlig.com. All rights reserved.
//

import Combine
import Foundation
import RealmSwift

public final class RealmClient: RealmClientProtocol {
    private func realm() throws -> Realm { // NOTE: instance must not be shared across multiple Threads
        try Realm(configuration: configuration)
    }

    private let configuration: Realm.Configuration

    public init(configuration: Realm.Configuration = .init()) {
        self.configuration = configuration
    }

    /// NOTE: instances of entries read and written to `RealmClient` can NOT be shared across threads else an exception is thrown.
    public func read<T>(_ type: T.Type) throws -> T where T: DBReadable {
        defer { print("\(type): ") }
        guard let type = type as? Object.Type else { throw DatabaseError.unhandledType }

        let object: T = try read(objectType: type)
        return object
    }

    /// NOTE: instances of entries read and written to `RealmClient` can NOT be shared across threads else an exception is thrown.
    public func readAll<T>(_ type: T.Type) -> AnyPublisher<[T], DatabaseError> where T: DBStorable, T: Decodable {
        defer { print("\(type): ") }
        guard let objectType = type as? Object.Type else {
            return Fail(error: DatabaseError.unhandledType).eraseToAnyPublisher()
        }

        guard let objects: [T] = try? readAll(objectType: objectType) else { return Fail(error: DatabaseError.unhandledType).eraseToAnyPublisher() }

        return Just(objects)
            .setFailureType(to: DatabaseError.self)
            .eraseToAnyPublisher()
    }

    /// NOTE: instances of entries read and written to `RealmClient` can NOT be shared across threads else an exception is thrown.
    public func write<T>(_ entry: T) where T: DBWritable {
        defer { print("\(type(of: entry))") }
        guard let object = entry as? Object else {
            preconditionFailure("invalid type: \(T.self) is not an 'Object'")
        }

        write(object: object)
    }

    /// observe all object of `type`; each time an entry of `type` changes a collection of all etries is emitted
    /// - NOTE: must be called from a thread with run loop, else it asserts; PLus, when using '.subscribe(on:)'  scheduler must use same Thread  on which this  function is called
    public func observe<T>(_ type: T.Type, predicate: NSPredicate) -> AnyPublisher<[T], DatabaseError> where T: DBReadable {
        guard let objectType = type as? Object.Type else {
            return Fail(error: DatabaseError.unhandledType).eraseToAnyPublisher()
        }

        return Just((objectType, predicate))
            .subscribe(on: DispatchQueue.main) // TODO: use custom background worker with run loop; https://academy.realm.io/posts/realm-notifications-on-background-threads-with-swift/
            .tryMap { objectType, predicate in
                (objectType, predicate, try self.realm())
            }.flatMap { objectType, predicate, realm in
                realm.objects(objectType)
                    .filter(predicate)
                    .collectionPublisher
                    .map(\.elements)
            }
            .tryMap { $0.compactMap { $0 as? T } }
            .mapError { _ in
                DatabaseError.unhandledType
            }
            .eraseToAnyPublisher()
    }

    public func deleteAll() {
        autoreleasepool {
            do {
                let realm = try realm()
                try realm.write {
                    realm.deleteAll()
                }
            } catch {
                print("Could not write to Realm, error: \(error)")
            }
        }
    }

    public func delete<T>(_ entry: T) where T: DBWritable {
        defer { print("\(type(of: entry))") }
        guard let object = entry as? Object else {
            preconditionFailure("invalid type: \(T.self) is not an 'Object'")
        }

        delete(object: object)
    }

    private func delete(object: Object) {
        autoreleasepool {
            do {
                let realm = try realm()
                try realm.write {
                    realm.delete(object)
                }
            } catch {
                print("Could not delete Realm object, error: \(error)")
            }
        }
    }

    private func read<T>(objectType: Object.Type) throws -> T where T: DBReadable {
        guard let object = try realm().objects(objectType).first as? T else { throw DatabaseError.noEntry }
        return object
    }

    private func readAll<T>(objectType: Object.Type) throws -> [T] where T: DBReadable {
        guard let objects = try realm()
            .objects(objectType)
            .toArray(ofType: objectType) as? [T] else { throw DatabaseError.noEntry }
        return objects
    }

    private func write(object: Object) {
        autoreleasepool {
            do {
                let realm = try realm()
                try realm.write {
                    realm.add(object, update: .modified)
                }
            } catch {
                print("Could not write to Realm, error: \(error)")
            }
        }
    }
}
