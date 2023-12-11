//
//  PollingDetailView.swift
//  Polling
//
//  Created by Dimitrios Tsoumanis on 11/12/2023.
//

import ComposableArchitecture
import SwiftUI

struct PollingDetailView: View {
    let polling: Polling
    let viewStore: ViewStore<PollingFeature.State, PollingFeature.Action>
    
    var body: some View {
        VStack(alignment: .center) {
            Text("\(polling.question)")
                .padding()
                .multilineTextAlignment(.center)
            if viewStore.answearsSubmitted.map({ $0.id }).contains(polling.id) {
                Text("\(viewStore.answearsSubmitted.first(where: { $0.id == polling.id })?.answer ?? "")")
                    .padding()
            }
            else {
                TextField(
                    "Type here for answear",
                    text: viewStore.binding(
                        get: \.answear,
                        send: { .answearChanged($0) }
                    )
                )
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
            }
            Button {
                viewStore.send(.submitButtonTapped(polling))
            } label: {
                Text(viewStore.answearsSubmitted.map({ $0.id }).contains(polling.id) ? "Already submitted" : "Submit")
            }
            .opacity((viewStore.answear.isEmpty || viewStore.answearsSubmitted.map({ $0.id }).contains(polling.id)) ? 0.6 : 1)
            .disabled(viewStore.answear.isEmpty || viewStore.answearsSubmitted.map({ $0.id }).contains(polling.id))
        }
    }
}
