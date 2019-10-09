//
//  PageView.swift
//  GitHubNotificationManager
//
//  Created by Yudai.Hirose on 2019/09/30.
//  Copyright © 2019 bannzai. All rights reserved.
//

import UIKit
import SwiftUI

struct PageViewDataContainer<Page: View, IDObject: Identifiable>: Identifiable, View {
    let object: IDObject
    let view: Page
    
    typealias ID = IDObject.ID
    var id: ID { object.id }
    
    var body: some View { view }
}

struct PageView<Page: View>: View {
    var viewControllers: [UIHostingController<Page>]
    var currentPage: Binding<Int>

    init(views: [Page], page: Binding<Int>) {
        self.viewControllers = views.map { UIHostingController(rootView: $0) }
        self.currentPage = page
    }

    var body: some View {
        PageViewController(
            viewControllers: viewControllers,
            currentPage: currentPage
        )
    }
}

#if DEBUG
struct PageView_Preview: PreviewProvider {
    @State static var currentPage: Int = 0
    static var previews: some View {
        PageView(views: [EmptyView()], page: $currentPage)
    }
}
#endif
