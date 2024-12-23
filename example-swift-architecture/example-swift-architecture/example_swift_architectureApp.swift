//
//  example_swift_architectureApp.swift
//  example-swift-architecture
//
//  Created by User on 2024-12-23.
//

import SwiftUI
import SwiftArchitecture

@main
struct example_swift_architectureApp: App {
    var body: some Scene {
        WindowGroup {
            TabBarContainerView(tabs: [createTabItem(title: "Home", iconName: "house", content: HomeView())])
        }
    }
}
