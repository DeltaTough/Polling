//
//  PollingApp.swift
//  Polling
//
//  Created by Dimitrios Tsoumanis on 11/12/2023.
//

import ComposableArchitecture
import SwiftUI

@main
struct PollingApp: App {
    var body: some Scene { 
        WindowGroup {
            PollingHomeView(store: Store(initialState: PollingHomeFeature.State()) {
                PollingHomeFeature()._printChanges()
            })
        }
    }
}
