//
//  PollingFeature.swift
//  Polling
//
//  Created by Dimitrios Tsoumanis on 11/12/2023.
//

import ComposableArchitecture

struct PollingFeature: Reducer {
    struct State: Equatable {
        var answearsSubmitted: IdentifiedArrayOf<PollingAnswer> = []
        var answear = ""
        var pollings: [Polling] = []
        var polling: Polling?
        var isLoading = false
        var showAlert = false
        var callSuccessful = false
        
        public init(
            pollings: [Polling] = [],
            polling: Polling? = nil
        ) {
            self.pollings = pollings
            self.polling = polling
        }
    }
    
    enum Action: Equatable {
        case pollingResponse(TaskResult<[Polling]>)
        case getPolling
        case submitAnswear(TaskResult<Bool>)
        case submitButtonTapped(Polling)
        case answearChanged(String)
        case showAlertCompleted
        case onSuccessfulSubmission(Polling)
        case previousTapped
        case nextTapped
        case pollChanged(Polling)
    }
    
    @Dependency(\.pollingClient) var surveyClient
    @Dependency(\.continuousClock) var clock
    private enum CancelID { case submit, clock }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .pollingResponse(.failure):
                state.isLoading = false
                state.pollings = []
                state.polling = nil
                return .none
            case let .pollingResponse(.success(pollings)):
                state.isLoading = false
                state.pollings = pollings
                state.polling = pollings.first
                return .none
            case .getPolling:
                state.isLoading = true
                return .run { send in
                    await send(
                        .pollingResponse(
                            TaskResult {
                                try await self.surveyClient.getPolling()
                            })
                    )
                }
            case let .submitButtonTapped(survey):
                guard !state.answear.isEmpty else {
                    return .none
                }
                return .run { [answear = state.answear] send in
                    await send(.submitAnswear(
                        TaskResult {
                            let isSuccess = try await self.surveyClient.submitQuestion(survey.id, answear)
                            if isSuccess {
                                await send(.onSuccessfulSubmission(survey))
                            }
                            return isSuccess
                        })
                    )
                }
                .cancellable(id: CancelID.submit)
            case .submitAnswear(.failure):
                return .none
            case let .submitAnswear(.success(isSuccess)):
                state.showAlert = true
                state.callSuccessful = isSuccess
                return .run { send in
                    try await self.clock.sleep(for: .seconds(2))
                    await send(.showAlertCompleted)
                }
                .cancellable(id: CancelID.clock)
            case let .answearChanged(answear):
                state.answear = answear
                return .none
            case .showAlertCompleted:
                state.showAlert = false
                return .none
            case let .onSuccessfulSubmission(survey):
                if !state.answearsSubmitted.map({ $0.id }).contains(survey.id),
                   var question = state.pollings.first(where: { $0.id == survey.id })?.question {
                    if question.last == "?" {
                        question.removeLast()
                    }
                    let string = question.components(separatedBy: " ")
                    state.answearsSubmitted.append(
                        PollingAnswer(
                            id: survey.id,
                            answer: "My favourite \(string.last ?? "") is \(state.answear)")
                    )
                }
                return .none
            case .previousTapped:
                if let survey = state.polling,
                   let currentIndex = state.pollings.firstIndex(of: survey) {
                    state.polling = state.pollings[state.pollings.index(before: currentIndex)]
                }
                state.answear = ""
                return .none
            case .nextTapped:
                if let survey = state.polling,
                   let currentIndex = state.pollings.firstIndex(of: survey) {
                    state.polling = state.pollings[state.pollings.index(after: currentIndex)]
                }
                state.answear = ""
                return .none
            case let .pollChanged(polling):
                state.polling = polling
                return .none
            }
        }
    }
}


extension PollingFeature.State {
    static let mock = Self(
        polling: Polling(id: 2, question: "What is your favourite ice cream?")
    )
}
