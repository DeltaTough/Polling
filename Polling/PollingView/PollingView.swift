//
//  PollingView.swift
//  Polling
//
//  Created by Dimitrios Tsoumanis on 11/12/2023.
//

import ComposableArchitecture
import SwiftUI

struct PollingView: View {
    let store: StoreOf<PollingFeature>
    
    public init(store: StoreOf<PollingFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                if viewStore.isLoading {
                    ProgressView()
                } else if let polling = viewStore.polling {
                    TabView {
                        ZStack(alignment: .top) {
                            withAnimation(.easeIn(duration: 0.1)) {
                                Text("Questions submitted: \(viewStore.answearsSubmitted.count)")
                                    .padding(.leading, 20)
                                    .background(.gray)
                                    .frame(width: UIScreen.main.bounds.width, height: 100)
                                    .offset(y: -300)
                            }
                            .opacity(viewStore.showAlert ? 0 : 1)
                            withAnimation(.easeIn(duration: 0.1)) {
                                HStack {
                                    Text(viewStore.callSuccessful ? "Success": "Failure!")
                                        .font(.title)
                                        .padding(.leading, 20)
                                    Spacer()
                                    if !viewStore.callSuccessful {
                                        Button {
                                            viewStore.send(.submitButtonTapped(polling))
                                        } label: {
                                            Text("Retry")
                                        }
                                        .padding(.trailing, 20)
                                    }
                                }
                                .frame(width: UIScreen.main.bounds.width, height: 100)
                                .background(viewStore.callSuccessful ? .green : .red)
                                .transition(.asymmetric(insertion: .scale, removal: .opacity))
                                .offset(y: -280)
                            }
                            .opacity(viewStore.showAlert ? 1 : 0)
                            PollingDetailView(
                                polling: polling,
                                viewStore: viewStore
                            )
                        }
                        .navigationTitle(
                            Text("Question \(polling.id)/\(viewStore.pollings.count)")
                        )
                        .toolbar {
                            ToolbarItemGroup(placement: .primaryAction) {
                                Button("Previous") {
                                    viewStore.send(.previousTapped)
                                }
                                .opacity(viewStore.pollings.first == polling ? 0.6 : 1)
                                .disabled(viewStore.pollings.first == polling)
                                
                                Button("Next") {
                                    viewStore.send(.nextTapped)
                                }
                                .opacity(viewStore.pollings.last == polling ? 0.6 : 1)
                                .disabled(viewStore.pollings.last == polling)
                            }
                        }
                    }
                    .tabViewStyle(.page)
                }
            }
            .task {
                if viewStore.pollings.isEmpty {
                    viewStore.send(.getPolling)
                }
            }
        }
    }
}

struct PollingView_Previews: PreviewProvider {
    static var previews: some View {
        PollingView(
            store: Store(initialState: PollingFeature.State()) {
                PollingFeature()
            }
        )
    }
}
