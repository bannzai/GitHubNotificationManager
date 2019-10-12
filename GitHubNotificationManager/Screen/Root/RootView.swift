//
//  RootView.swift
//  GitHubNotificationManager
//
//  Created by Yudai.Hirose on 2019/06/06.
//  Copyright © 2019 bannzai. All rights reserved.
//

import SwiftUI
import GitHubNotificationManagerNetwork

struct RootView: View {
    @State private var selectedAddNotificationList: Bool = false
    @ObservedObject private var viewModel = RootViewModel()

    var body: some View {
        Group {
            if viewModel.isAuthorized {
                NavigationView {
                    PageView(views: pages, currentPage: $viewModel.currentPage)
                        .navigationBarTitle(Text(viewModel.title), displayMode: .inline)
                        .navigationBarItems(
                            trailing: Button(
                                action: {
                                    self.selectedAddNotificationList = true
                            }, label: {
                                Image(systemName: "text.badge.plus")
                                    .barButtonItems()
                            })
                    ).onAppear(perform: {
                        self.viewModel.fetchIfHasNotWatching()
                    }).alert(item: $viewModel.requestError) { (error) in
                        Alert(
                            title: Text("Fetched Error"),
                            message: Text(error.localizedDescription),
                            dismissButton: .default(Text("OK"))
                        )
                    }.sheet(isPresented: $selectedAddNotificationList) { () in
                        WatchingListView(watchings: self.viewModel.watchings)
                    }
                }
            } else {
                OAuthView(githubAccessToken: viewModel.githubAccessTokenBinder)
            }
        }
    }
    
    var pages: [AnyView] {
        if viewModel.isNotYetLoad {
            return []
        }
        
        let main = AnyView(NotificationListView().environmentObject(viewModel.allNotificationViewModel))
        let filtered = viewModel.activateNotificationViewModels.map {
            AnyView(NotificationListView().environmentObject($0))
        }
        return [main] + filtered
    }
}

#if DEBUG
struct RootView_Previews : PreviewProvider {
    static var previews: some View {
        ForEach(DeviceType.previewDevices, id: \.self) { device in
            RootView()
                .previewDevice(device.preview)
                .previewDisplayName(device.name)
        }
    }
}
#endif
