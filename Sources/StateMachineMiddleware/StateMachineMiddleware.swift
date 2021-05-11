import SwiftRex

public class StateMachineMiddleware<InputActionType, OutputActionType, StateType>: MiddlewareProtocol {
    private var rules: [StateMachineRule] = []

    public func handle(action: InputActionType, from dispatcher: ActionSource, state: @escaping GetState<StateType>) -> IO<OutputActionType> {
        let stateBefore = state()
        return IO { [weak self] output in
            guard let self = self else { return }
            let stateAfter = state()

            self.rules.filter {
                $0.evaluateBefore(stateBefore) && $0.evaluateAfter(stateAfter)
            }.forEach {
                output.dispatch($0.dispatchAction)
            }
        }
    }

    public func when<Substate: Equatable>(
        _ statePath: KeyPath<StateType, Substate>,
        from: StateValue<Substate>,
        to: StateValue<Substate>,
        dispatch action: OutputActionType
    ) -> StateMachineMiddleware {
        rules.append(
            StateMachineRule(
                evaluateBefore: { previousState in
                    guard case let .some(expectedValue) = from else { return true }
                    return previousState[keyPath: statePath] == expectedValue
                },
                evaluateAfter: { newState in
                    guard case let .some(expectedValue) = from else { return true }
                    return newState[keyPath: statePath] == expectedValue
                },
                dispatchAction: action
            )
        )
        return self
    }


    private struct StateMachineRule {
        let evaluateBefore: (StateType) -> Bool
        let evaluateAfter: (StateType) -> Bool
        let dispatchAction: OutputActionType
    }
}

public enum StateValue<State> {
    case some(State)
    case anything
}
