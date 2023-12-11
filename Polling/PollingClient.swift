//
//  PollingClient.swift
//  Polling
//
//  Created by Dimitrios Tsoumanis on 11/12/2023.
//

import ComposableArchitecture
import Foundation

struct PollingClient {
    var getPolling: @Sendable () async throws -> [Polling]
    var submitQuestion: @Sendable (Int, String) async throws -> Bool
    
    struct Failure: Error {}
}

extension PollingClient: DependencyKey {
    static let liveValue = Self(
        getPolling: {
            let data = try await URLSession.shared.data(from: URL(string: "https://xm-assignment.web.app/questions")!).0
            return try JSONDecoder().decode([Polling].self, from: data)
        },
        submitQuestion: { id, answer in
            var request = URLRequest(url: URL(string: "https://xm-assignment.web.app/question/submit")!)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = "{\n\"id\": \(id),\n\"answer\": \"\(answer)\"\n}".data(using: .utf8)
            let response = try await URLSession.shared.data(for: request).1
            guard let httpResponse = (response as? HTTPURLResponse) else {
                throw Failure()
            }
            let isSuccess = (200 ..< 300 ~= httpResponse.statusCode)
            return isSuccess
        }
    )
}

extension DependencyValues {
  var pollingClient: PollingClient {
    get { self[PollingClient.self] }
    set { self[PollingClient.self] = newValue }
  }
}

extension PollingClient: TestDependencyKey {
  static let testValue = Self(
    getPolling: unimplemented("\(Self.self).polling"),
    submitQuestion: unimplemented("\(Self.self).question")
  )
}

// MARK: - Mock data

extension PollingResponse {
    static let mock = Self(
        polling: [Polling(id: 1, question: "What is your favourite team?"),
                  Polling(id: 2, question: "What is your favourite ice cream?"),
                  Polling(id: 3, question: "What is your favourite food?")
                 ]
    )
}
