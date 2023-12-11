//
//  PollingAnswear.swift
//  Polling
//
//  Created by Dimitrios Tsoumanis on 11/12/2023.
//

import Foundation

public struct PollingAnswer: Encodable, Equatable, Identifiable {
    public let id: Int
    public let answer: String
}

