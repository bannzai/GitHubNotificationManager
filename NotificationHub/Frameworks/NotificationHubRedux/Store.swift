//
//  Store.swift
//  NotificationHub
//
//  Created by Yudai Hirose on 2019/10/13.
//  Copyright © 2019 bannzai. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

final public class Store<State: ReduxState>: ObservableObject {
    @Published public var state: State
    let objectDidChange = PassthroughSubject<Void, Never>()
    var canceller: Set<AnyCancellable> = []

    private var dispatchFunction: DispatchFunction!
    private let reducer: Reducer<State>

    public init(
        reducer: @escaping Reducer<State>,
        middlewares: [Middleware<State>],
        initialState state: State
    ) {
        self.reducer = reducer
        self.state = state
        
        self.dispatchFunction = middlewares
            .reversed()
            .reduce(
                { [unowned self] action in self.dispatchReduce(action: action) },
                { dispatchFunction, middleware in middleware(dispatcher(), lazyGetState())(dispatchFunction) }
        )
    }
    
    private func lazyGetState() -> () -> State? {
        return { [weak self] in
            self?.state
        }
    }
    
    private func dispatcher() -> (Action) -> Void {
        return { [weak self] action in
            self?.dispatch(action: action)
        }
    }
    
    public func dispatch(action: Action) {
        if Thread.isMainThread {
            self.dispatchFunction(action)
            return
        }
        DispatchQueue.main.async {
            self.dispatchFunction(action)
        }
    }
    
    private func dispatchReduce(action: Action) {
        state = reducer(state, action)
        objectDidChange.send()
    }
}

extension Store: Canceller { }

extension Store where State == AppState {
    public func restore() {
        guard let state = try? Coder<AppState>().read() else {
            return
        }
        dispatch(action: RestoreAction(watching: state.watchingListState))
    }
    
    func saveState() {
        DispatchQueue.global().async {
            let coder = Coder<AppState>()
            do {
                try coder.write(for: self.state)
                print("[INFO] Succesfully save state")
            } catch {
                print("[ERROR] " + error.localizedDescription)
            }
        }
    }
}

