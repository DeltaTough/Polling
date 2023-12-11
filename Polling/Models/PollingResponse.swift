//
//  PollingResponse.swift
//  Polling
//
//  Created by Dimitrios Tsoumanis on 11/12/2023.
//

import Foundation

struct PollingResponse: Decodable, Equatable, Sendable {
    var polling: [Polling]
    
}
