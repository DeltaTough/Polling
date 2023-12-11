//
//  PollingTests.swift
//  PollingTests
//
//  Created by Dimitrios Tsoumanis on 11/12/2023.
//

import ComposableArchitecture
import XCTest
@testable import Polling

final class PollingTests: XCTestCase {
    
    let clock = TestClock()
    
    @MainActor
    func testGetPolling() async throws {
        let store = TestStore(
            initialState: PollingFeature.State(pollings: [Polling(id: 1, question: "What is your favourite food?")])
        ) {
            PollingFeature()
          } withDependencies: {
            $0.continuousClock = clock
        }
        
        await store.send(PollingFeature.Action.getPolling)
        
        await clock.advance(by: .seconds(2))
        
        await store.receive(PollingFeature.Action.pollingResponse(.success(.mock))) {
            $0.pollings = .mock
        }
    }
    
    @MainActor
    func testNextTapped() async throws {
        let store = TestStore(
            initialState: PollingFeature.State(pollings: PollingResponse.mock.polling, 
                                               polling: PollingResponse.mock.polling.first)
        ) {
            PollingFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }
                
        await store.send(PollingFeature.Action.nextTapped)
        
        await clock.advance()
        
        await store.receive(.pollChanged(PollingFeature.State.mock.polling!)) {
            $0.polling = PollingFeature.State.mock.polling
        }
    }
}
