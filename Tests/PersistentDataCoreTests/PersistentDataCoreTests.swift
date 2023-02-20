//
// PersistentDataCoreTests.swift
// Copyright (c) 2022 Nemlig.com. All rights reserved.
//

@testable import PersistentDataCore
import RealmSwift
import XCTest

final class PersistentDataCoreTests: XCTestCase {
    var sut: RealmClient!
    private var configuration: Realm.Configuration {
        var config = Realm.Configuration(objectTypes: [TestObject.self, TestObjectList.self])
        config.maximumNumberOfActiveVersions = 6
        return config
    }

    override func setUpWithError() throws {
        sut = .init(configuration: configuration)
    }

    override func tearDownWithError() throws {
        sut.deleteAll()
        sut = nil
    }

    func testWrite() throws {
        sut.write(randomTestObject())
    }

    func testWriteLargeEntry() throws {
        let list = TestObjectList()
        for _ in 0..<10_000 {
            list.objects.append(randomTestObject())
        }
        self.measure {
            sut.write(list)
        }
    }

    func testWritePerformance() throws {
        try skipTest()
        self.measure {
            for _ in 0..<1000 {
                sut.write(randomTestObject())
            }
        }
    }

    func testWriteOnQueue() throws {
        expectFailure()
        let testQueue = DispatchQueue(label: "test queue", qos: .userInteractive)

        sut = .init(configuration: configuration)
        var results = 0

        let exp = expectation(description: "wait for write updates")
        exp.expectedFulfillmentCount = 20

        let sub = sut.observe(TestObject.self)
            .receive(on: testQueue)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    XCTFail("unexpected: \(error)")
                case .finished:
                    XCTFail("unexpected: .finished")
                }
            } receiveValue: { value in
                print("received: \(value.count)")
                results += 1
                exp.fulfill()
            }

        // When

        for _ in 0..<20 {
            testQueue.sync { [self] in
                self.sut.write(randomTestObject())
            }
        }

        // Then
        wait(for: [exp], timeout: 10.0)
        XCTAssertEqual(results, 20)
        sub.cancel()
    }

    func testReadPerformance() throws {
        expectFailure()

        let input = randomTestObject()
        sut.write(input)
        var testObject: TestObject?
        measure {
            for _ in 0..<10_000 {
                XCTAssertNoThrow(testObject = try? sut.read(TestObject.self))
            }
        }
        XCTAssertEqual(testObject, input)
    }

    func testWriteObservePerformance() throws {
        expectFailure()
        var results = [Int]()

        let exp = expectation(description: "wait for write updates")
        exp.expectedFulfillmentCount = 1000
        exp.assertForOverFulfill = false

        let sub = sut.observe(TestObject.self)
            .map(\.count)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    XCTFail("unexpected: \(error)")
                case .finished:
                    XCTFail("unexpected: .finished")
                }
            } receiveValue: { value in
                results.append(value)
                exp.fulfill()
            }

        measure {
            for _ in 0..<100 {
                sut.write(randomTestObject())
            }
        }

        wait(for: [exp], timeout: 10.0)
        XCTAssertEqual(results.count, 1000)
        sub.cancel()
    }

    private func randomTestObject() -> TestObject {
        .init(id: UUID().uuidString,
              url: "www.nemlig.com",
              text: "some text",
              subtext: "long text",
              info: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
    }
}
