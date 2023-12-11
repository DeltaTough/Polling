//
//  PollingHomeScreen.swift
//  Polling
//
//  Created by Dimitrios Tsoumanis on 11/12/2023.
//

import ComposableArchitecture
import SwiftUI

struct PollingHomeView: View {
    let store: StoreOf<PollingHomeFeature>
    
    public init(store: StoreOf<PollingHomeFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            WithViewStore(store, observe: { $0 }) { viewStore in
                Button {
                    viewStore.send(.startPollingButtonTapped)
                } label: {
                    Text("Start Survey")
                }
                .navigationDestination(
                    store: self.store.scope(
                        state: \.$pollingPagerFeature, action: { .pollingPagerFeature($0) })) { store in
                            PollingView(store: store)
                        }
            }
        }
    }
}

