//
//  HUDPublishser.swift
//  GitHubNotificationManager
//
//  Created by Yudai.Hirose on 2019/06/07.
//  Copyright © 2019 bannzai. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

final public class HUDPublisher: BindableObject {
    public let didChange = PassthroughSubject<Output, Failure>()
    
    public typealias Output = HUDAppearanceType
    public typealias Failure = Never
    
    private var canceller: Cancellable?
    deinit {
        canceller?.cancel()
    }
    
    var state: HUDAppearanceType = .hide {
        didSet { didChange.send(state) }
    }
    
    func show() {
        state = .show
    }
    
    func hide() {
        state = .hide
    }
}
