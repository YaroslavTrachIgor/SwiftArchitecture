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


public protocol ViewProtocol: AnyObject {
    associatedtype PresenterType
    var presenter: PresenterType { get set }
    init()
}

public protocol PresenterProtocol: AnyObject {
    associatedtype ViewType
    associatedtype InteractorType
    associatedtype RouterType
    
    var view: ViewType? { get set }
    var interactor: InteractorType { get }
    var router: RouterType { get }
    
    init(view: ViewType, interactor: InteractorType, router: RouterType)
}

public protocol InteractorProtocol: AnyObject {
    associatedtype PresenterType
    var presenter: PresenterType? { get set }
    
    init()
}

public protocol RouterProtocol: AnyObject {
    associatedtype PresenterType
    var presenter: PresenterType? { get set }
    
    init()
}









@propertyWrapper
struct Injected<T> {
    private var value: T
    
    public init(_ builder: () -> T) {
        self.value = builder()
    }
    
    var wrappedValue: T {
        get { value }
        set { value = newValue }
    }
}

public final class ModuleAssembler {
    public static func assemble<V, P, I, R>(
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
open class BaseView<P>: @preconcurrency ViewProtocol {
    public var presenter: P
    
    required public init() {
        fatalError("Use ModuleAssembler")
    }
}

@MainActor
open class BasePresenter<V: AnyObject, I, R>: @preconcurrency PresenterProtocol {
    
    weak public var view: V?
    public let interactor: I
    public let router: R
    
    required public init(view: V, interactor: I, router: R) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
}

@MainActor
open class BaseInteractor<P: AnyObject>: @preconcurrency InteractorProtocol {
    public weak var presenter: P?
    
    required public init() {}
}

@MainActor
open class BaseRouter<P: AnyObject>: @preconcurrency RouterProtocol {
    public weak var presenter: P?
    
    required public init() {}
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
public final class TabBarView: BaseView<TabBarPresenter> {
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
public final class TabBarPresenter: BasePresenter<TabBarView, TabBarInteractor, TabBarRouter> {
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
public final class TabBarInteractor: BaseInteractor<TabBarPresenter> {
    // Add any business logic needed for tab management
}

@MainActor
public final class TabBarRouter: BaseRouter<TabBarPresenter> {
    func switchToTab(at index: Int) {
        // Handle tab switching logic
    }
}

public struct TabItem {
    let view: UIViewController
    let title: String
    let icon: UIImage
    let selectedIcon: UIImage?
    
    public init(
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
public enum MainTabBar {
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






