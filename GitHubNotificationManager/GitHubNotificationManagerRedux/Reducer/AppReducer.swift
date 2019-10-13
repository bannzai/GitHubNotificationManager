//
//  AppReducer.swift
//  GitHubNotificationManager
//
//  Created by Yudai Hirose on 2019/10/13.
//  Copyright © 2019 bannzai. All rights reserved.
//

import Foundation

public let appReducer: Reducer<AppState> = { state, action in
    var state = state
    state.watchingListState = watchingListReducer(state.watchingListState, action)
    return state
}
