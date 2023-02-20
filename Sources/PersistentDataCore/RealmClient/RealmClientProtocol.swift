//
// RealmClientProtocol.swift
// Copyright (c) 2022 Nemlig.com. All rights reserved.
//

import Combine
import Foundation
import RealmSwift

public protocol RealmClientProtocol: AnyObject {
    func read<T>(_ type: T.Type) throws -> T where T: DBReadable
    func readAll<T>(_ type: T.Type) -> AnyPublisher<[T], DatabaseError> where T: DBReadable
    func write<T>(_ entry: T) throws where T: DBWritable
    func observe<T>(_ type: T.Type, predicate: NSPredicate) -> AnyPublisher<[T], DatabaseError> where T: DBReadable
    func deleteAll()
    func delete<T>(_ entry: T) throws where T: DBWritable
}

public extension RealmClientProtocol {
    func observe<T>(_ type: T.Type, predicate: NSPredicate = .init(value: true)) -> AnyPublisher<[T], DatabaseError> where T: DBReadable {
        observe(type, predicate: predicate)
    }
}
