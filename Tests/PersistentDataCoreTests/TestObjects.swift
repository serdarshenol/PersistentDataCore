//
// TestObjects.swift
// Copyright (c) 2022 Nemlig.com. All rights reserved.
//

@testable import PersistentDataCore
import RealmSwift
import XCTest

final class TestObjectList: Object, DBStorable, Codable {
    @objc dynamic var id = "945849594598"
    var objects = List<TestObject>()
    override static func primaryKey() -> String? { "id" }
}

final class TestObject: Object, DBStorable, Codable {
    @objc dynamic var id: String = ""
    @objc dynamic var url: String = ""
    @objc dynamic var text: String = ""
    @objc dynamic var subtext: String = ""
    @objc dynamic var info: String = ""

    override static func primaryKey() -> String? { "id" }

    convenience init(id: String,
                     url: String,
                     text: String,
                     subtext: String,
                     info: String) {
        self.init()
        self.id = id
        self.url = url
        self.text = text
        self.subtext = subtext
        self.info = info
    }
}
