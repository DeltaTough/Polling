//
//  PollingHomeFeature.swift
//  Polling
//
//  Created by Dimitrios Tsoumanis on 11/12/2023.
//

import Foundation
import ComposableArchitecture

@Reducer
struct PollingHomeFeature {
    struct State: Equatable {
        @PresentationState var pollingPagerFeature: PollingFeature.State?
    }
    
    enum Action: Equatable {
        case pollingPagerFeature(PresentationAction<PollingFeature.Action>)
        case startPollingButtonTapped
    }
            
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            
            switch action {
            case .startPollingButtonTapped:
                state.pollingPagerFeature = PollingFeature.State()
                return .none
            case .pollingPagerFeature:
                return .none
            }
        }
        .ifLet(\.$pollingPagerFeature, action: /Action.pollingPagerFeature) {
            PollingFeature()
        }
    }
}

