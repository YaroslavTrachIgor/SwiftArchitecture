// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import UIKit
import SwiftUI

///****************************************************************************************************************************************************************************
//MARK: - ()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()
/******************************************************************************************************************************************************************************

 |\   ____\|\  \     |\  \|\  \|\  _____\\___   ___\     |\   __  \|\   __  \|\   ____\|\  \|\  \|\  \|\___   ___\\  ___ \ |\   ____\\___   ___\\  \|\  \|\   __  \|\  ___ \
 \ \  \___|\ \  \    \ \  \ \  \ \  \__/\|___ \  \_|     \ \  \|\  \ \  \|\  \ \  \___|\ \  \\\  \ \  \|___ \  \_\ \   __/|\ \  \___\|___ \  \_\ \  \\\  \ \  \|\  \ \   __/|
  \ \_____  \ \  \  __\ \  \ \  \ \   __\    \ \  \       \ \   __  \ \   _  _\ \  \    \ \   __  \ \  \   \ \  \ \ \  \_|/_\ \  \       \ \  \ \ \  \\\  \ \   _  _\ \  \_|/__
   \|____|\  \ \  \|\__\_\  \ \  \ \  \_|     \ \  \       \ \  \ \  \ \  \\  \\ \  \____\ \  \ \  \ \  \   \ \  \ \ \  \_|\ \ \  \____   \ \  \ \ \  \\\  \ \  \\  \\ \  \_|\
     ____\_\  \ \____________\ \__\ \__\       \ \__\       \ \__\ \__\ \__\\ _\\ \_______\ \__\ \__\ \__\   \ \__\ \ \_______\ \_______\  \ \__\ \ \_______\ \__\\ _\\ \______
 
******************************************************************************************************************************************************************************/
//MARK: - ()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()-()
///****************************************************************************************************************************************************************************


protocol ViewProtocol: AnyObject {
    associatedtype PresenterType
    var presenter: PresenterType { get set }
    init()
}

protocol PresenterProtocol: AnyObject {
    associatedtype ViewType
    associatedtype InteractorType
    associatedtype RouterType
    
    var view: ViewType? { get set }
    var interactor: InteractorType { get }
    var router: RouterType { get }
    
    init(view: ViewType, interactor: InteractorType, router: RouterType)
}

protocol InteractorProtocol: AnyObject {
    associatedtype PresenterType
    var presenter: PresenterType? { get set }
    
    init()
}

protocol RouterProtocol: AnyObject {
    associatedtype PresenterType
    var presenter: PresenterType? { get set }
    
    init()
}









@propertyWrapper
struct Injected<T> {
    private var value: T
    
    init(_ builder: () -> T) {
        self.value = builder()
    }
    
    var wrappedValue: T {
        get { value }
        set { value = newValue }
    }
}

final class ModuleAssembler {
    static func assemble<V, P, I, R>(
        view: V.Type,
        presenter: P.Type,
        interactor: I.Type,
        router: R.Type
    ) -> V where
        V: ViewProtocol,
        P: PresenterProtocol,
        I: InteractorProtocol,
        R: RouterProtocol,
        V.PresenterType == P,
        P.ViewType == V,
        P.InteractorType == I,
        P.RouterType == R,
        I.PresenterType == P,
        R.PresenterType == P {
        
        let view = V.init()
        let interactor = I.init()
        let router = R.init()
        let presenter = P.init(
            view: view,
            interactor: interactor,
            router: router
        )
        
        view.presenter = presenter
        interactor.presenter = presenter
        router.presenter = presenter
        
        return view
    }
}















@MainActor
class BaseView<P>: @preconcurrency ViewProtocol {
    var presenter: P
    
    required init() {
        fatalError("Use ModuleAssembler")
    }
}

@MainActor
class BasePresenter<V: AnyObject, I, R>: @preconcurrency PresenterProtocol {
    
    weak var view: V?
    let interactor: I
    let router: R
    
    required init(view: V, interactor: I, router: R) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
}

@MainActor
class BaseInteractor<P: AnyObject>: @preconcurrency InteractorProtocol {
    weak var presenter: P?
    
    required init() {}
}

@MainActor
class BaseRouter<P: AnyObject>: @preconcurrency RouterProtocol {
    weak var presenter: P?
    
    required init() {}
}







































import UIKit
































/*
 
 dynamic var currentRouter/currentRouterIndex/currentRouterID
 
 MainRouter {
    HomeModule()
 
    UserProfileModule()
 
    SettingsModule()
 }
 */


@MainActor
final class TabBarView: BaseView<TabBarPresenter> {
    private var tabView: UITabBarController
    private var viewControllers: [UIViewController]
    
    required init() {
        self.tabView = UITabBarController()
        self.viewControllers = []
        super.init()
    }
    
    func setupTabs(_ tabs: [TabItem]) {
        viewControllers = tabs.map { tab in
            let viewController = tab.view
            viewController.tabBarItem = UITabBarItem(
                title: tab.title,
                image: tab.icon,
                selectedImage: tab.selectedIcon
            )
            return viewController
        }
        tabView.setViewControllers(viewControllers, animated: false)
    }
}


@MainActor
final class TabBarPresenter: BasePresenter<TabBarView, TabBarInteractor, TabBarRouter> {
    private var tabs: [TabItem] = []
    
    func configureTabs(_ tabs: [TabItem]) {
        self.tabs = tabs
        view?.setupTabs(tabs)
    }
    
    func switchTab(to index: Int) {
        router.switchToTab(at: index)
    }
}

@MainActor
final class TabBarInteractor: BaseInteractor<TabBarPresenter> {
    // Add any business logic needed for tab management
}

@MainActor
final class TabBarRouter: BaseRouter<TabBarPresenter> {
    func switchToTab(at index: Int) {
        // Handle tab switching logic
    }
}

struct TabItem {
    let view: UIViewController
    let title: String
    let icon: UIImage
    let selectedIcon: UIImage?
    
    init(
        view: UIViewController,
        title: String,
        icon: UIImage,
        selectedIcon: UIImage? = nil
    ) {
        self.view = view
        self.title = title
        self.icon = icon
        self.selectedIcon = selectedIcon ?? icon
    }
}






@MainActor
enum MainTabBar {
    static func create(tabs: [TabItem]) -> TabBarView {
        let tabBar = ModuleAssembler.assemble(
            view: TabBarView.self,
            presenter: TabBarPresenter.self,
            interactor: TabBarInteractor.self,
            router: TabBarRouter.self
        )
        
        tabBar.presenter.configureTabs(tabs)
        return tabBar
    }
}
















@MainActor
final class HomeView: BaseView<HomePresenter>, View {
    private let contentView: UIView
    
    required init() {
        self.contentView = UIView()
        super.init()
        setupUI()
    }
    
    private func setupUI() {
        contentView.backgroundColor = .white
        let label = UILabel()
        label.text = "Home Screen"
        label.textAlignment = .center
        contentView.addSubview(label)
        label.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        label.center = contentView.center
    }
    
    var body: some View {
        VStack {
            Text("Home")
        }
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




let homeModule = ModuleAssembler.assemble(
    view: HomeView.self,
    presenter: HomePresenter.self,
    interactor: HomeInteractor.self,
    router: HomeRouter.self
)

@MainActor
let app = MainTabBar.create(tabs: [
    TabItem(
        view: UIHostingController(rootView: homeModule),
        title: "Home",
        icon: UIImage(systemName: "house")!
    )
])
