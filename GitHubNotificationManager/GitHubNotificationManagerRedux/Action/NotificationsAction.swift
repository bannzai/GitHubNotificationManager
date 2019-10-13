//
//  NotificationsAction.swift
//  GitHubNotificationManager
//
//  Created by Yudai Hirose on 2019/10/13.
//  Copyright © 2019 bannzai. All rights reserved.
//

import Foundation
import GitHubNotificationManagerNetwork
import Combine

struct CreateNotifications: Action {
    let watching: WatchingElement
}
struct SetNotificationList: Action {
    let watchingId: WatchingElement.ID?
    let elements: [NotificationElement]
}

func appState(_ state: ReduxState?) -> AppState {
    state as! AppState
}

struct ChangeNotificationPage: Action {
    let page: Int
}

struct NotificationsFetchAction: AsyncAction {
    var canceller: Canceller
    var watchingId: WatchingElement.ID?
    
    func async(state: ReduxState?, dispatch: @escaping DispatchFunction) {
        dispatch(NetworkRequestAction.start)
        
        guard let state = appState(state)
            .notificationPageState
            .notificationsStatuses
            .first(where: { $0.watching?.id == watchingId })
            else {
                return
        }
        
        let mapper: ([NotificationElement]) -> SetNotificationList = {
            SetNotificationList.init(watchingId: self.watchingId, elements: $0)
        }
        
        GitHubAPI
            .request(request: NotificationsRequest(page: state.nextFetchPage, notificationsUrl: state))
            .map(mapper)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    dispatch(ReceiveNetworkRequestError.init(error: error))
                }
                dispatch(NetworkRequestAction.finished)
            }, receiveValue: { values in
                dispatch(values)
            })
            .store(in: &canceller.canceller)
    }
}
