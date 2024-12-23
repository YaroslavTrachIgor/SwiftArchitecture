//
//  ContentView.swift
//  example-swift-architecture
//
//  Created by User on 2024-12-23.
//

import SwiftUI
import SwiftArchitecture



final class HomeViewController: BaseViewController<HomePresenter> {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homeView = HomeView()
        let hostingController = UIHostingController(rootView: homeView)
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostingController.didMove(toParent: self)
    }
}

let tabs = [
    TabItem(
        view: homeModule,
        title: "Home",
        icon: UIImage(systemName: "house")!
    )
]




struct HomeView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}




@MainActor
final class HomePresenter: BasePresenter<UIViewController, HomeInteractor, HomeRouter> {
    func viewDidLoad() {
        // Handle view lifecycle
    }
}

@MainActor
final class HomeInteractor: BaseInteractor<HomePresenter> {
    // Add business logic
}


@MainActor
final class HomeRouter: BaseRouter<HomePresenter> {
    // Add navigation logic
}

