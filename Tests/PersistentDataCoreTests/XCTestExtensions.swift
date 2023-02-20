//
// XCTestExtensions.swift
// Copyright (c) 2022 Nemlig.com. All rights reserved.
//

import Foundation
import XCTest

extension XCTestCase {
    private var skipFailingCITests: Bool { true }

    public func skipTest() throws {
        try XCTSkipIf(skipFailingCITests, "fails on CI")
    }

    public func expectFailure(_ isStrict: Bool = false) {
        let options = XCTExpectedFailure.Options()
        options.isStrict = isStrict

        XCTExpectFailure("Investigate failure.", options: options)
    }

    public func expectation(name: String = #function) -> XCTestExpectation {
        expectation(description: name)
    }
}
