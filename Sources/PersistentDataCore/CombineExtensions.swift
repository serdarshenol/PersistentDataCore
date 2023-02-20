//
// CombineExtensions.swift
// Copyright (c) 2022 Nemlig.com. All rights reserved.
//

import Combine
import Foundation

extension Publisher {
    public func ignoreError() -> AnyPublisher<Self.Output, Never> {
        self.catch { _ in
            Empty<Self.Output, Never>(completeImmediately: false)
        }
        .eraseToAnyPublisher()
    }
}
