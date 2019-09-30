//
//  NotificationRequest.swift
//  GitHubNotificationManager
//
//  Created by Yudai.Hirose on 2019/06/05.
//  Copyright © 2019 bannzai. All rights reserved.
//

import Foundation

public struct NotificationsRequest: GitHubAPIRequest {
    public var path: URLPathConvertible { ["notifications"] }
    public var method: HTTPMethod { .GET }
    public typealias Response = [NotificationElement]
    public var query: Query? { ["all": true, "page": page, "per_page": Self.perPage] }
    
    public static let perPage = 100
    private let page: Int
    public init(page: Int) {
        self.page = page
    }
}

