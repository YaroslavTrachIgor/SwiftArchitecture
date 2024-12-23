//
//  ContentView.swift
//  example-swift-architecture
//
//  Created by User on 2024-12-23.
//

import SwiftUI
import SwiftArchitecture

let homeModule = ModuleAssembler.assemble(
    view: HomeView.self,
    presenter: HomePresenter.self,
    interactor: HomeInteractor.self,
    router: HomeRouter.self
)

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
final class HomePresenter: BasePresenter<HomeView, HomeInteractor, HomeRouter> {
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
