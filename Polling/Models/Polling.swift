//
//  Polling.swift
//  Polling
//
//  Created by Dimitrios Tsoumanis on 11/12/2023.
//

import Foundation

public struct Polling: Decodable, Equatable, Identifiable, Sendable, Hashable {
    public let id: Int
    public let question: String
}

public extension Polling {
    static var mock: Self {
        .init(id: 1, question: "What is your favourite food?")
    }
}

public extension Array where Element == Polling {
    static var mock: [Polling] {
        [.mock]
    }
}
