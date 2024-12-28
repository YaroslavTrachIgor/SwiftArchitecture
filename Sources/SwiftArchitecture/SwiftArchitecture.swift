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


public protocol ViewProtocol {
    associatedtype ViewModelType
    var viewModel: ViewModelType { get set }
    init(viewModel: ViewModelType)
}

public protocol ViewModelProtocol {
    associatedtype InteractorType
    associatedtype RouterType
    
    var interactor: InteractorType { get }
    var router: RouterType { get }
    
    init(interactor: InteractorType, router: RouterType)
}

public protocol InteractorProtocol {
    associatedtype ViewModelType
    var viewModel: ViewModelType? { get set }
    
    init()
}

public protocol RouterProtocol {
    associatedtype ViewModelType
    var viewModel: ViewModelType? { get set }
    
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
    @MainActor public static func assemble<V: Sendable, P, I, R>(
        view: V.Type,
        viewModel: P.Type,
        interactor: I.Type,
        router: R.Type
    ) -> P where
    V: ViewProtocol,
    I: InteractorProtocol,
    P: ViewModelProtocol,
    R: RouterProtocol,
    V.ViewModelType == P,
    P.InteractorType == I,
    P.RouterType == R,
    I.ViewModelType == P,
    R.ViewModelType == P {
        
        var interactor = I.init()
        var router = R.init()
        let viewModel = P.init(
            interactor: interactor,
            router: router
        )
        var view = V.init(viewModel: viewModel)
        
        interactor.viewModel = viewModel
        router.viewModel = viewModel
        
        return viewModel
    }
}















@MainActor
open class BaseViewController<VM>: @preconcurrency ViewProtocol {
    
    public var viewModel: VM
    
    required public init(viewModel: VM) {
        self.viewModel = viewModel
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@MainActor
open class BaseInteractor<VM: AnyObject>: @preconcurrency InteractorProtocol {
    public weak var viewModel: VM?
    
    required public init() {}
}











@MainActor
public final class DependencyContainer {
    private var dependencies: [String: Any] = [:]
    public static let shared = DependencyContainer()
    
    public func register<T>(_ type: T.Type, instance: T) {
        let key = String(describing: type)
        dependencies[key] = instance
    }
    
    public func resolve<T>() -> T {
        let key = String(describing: T.self)
        guard let instance = dependencies[key] as? T else {
            fatalError("No dependency found for \(T.self)")
        }
        return instance
    }
}


@propertyWrapper
public struct Observable<Value> {
    private var value: Value
    private var observers = [(Value) -> Void]()
    
    public init(wrappedValue: Value) {
        self.value = wrappedValue
    }
    
    public var wrappedValue: Value {
        get { value }
        set {
            value = newValue
            notifyObservers()
        }
    }
    
    public var projectedValue: Observable<Value> {
        get { self }
        set { self = newValue }
    }
    
    public mutating func bind(_ observer: @escaping (Value) -> Void) {
        observers.append(observer)
        observer(value)
    }
    
    private func notifyObservers() {
        observers.forEach { $0(value) }
    }
}

@MainActor
public protocol NavigationCoordinator: AnyObject {
    func start()
    func coordinate(to coordinator: NavigationCoordinator)
    func finish()
}

@MainActor
open class BaseCoordinator: NavigationCoordinator {
    private var childCoordinators: [NavigationCoordinator] = []
    
    public func start() {}
    
    public func coordinate(to coordinator: NavigationCoordinator) {
        childCoordinators.append(coordinator)
        coordinator.start()
    }
    
    public func finish() {
        childCoordinators.removeAll()
    }
}

@MainActor
open class BaseRouter<VM: AnyObject>: @preconcurrency RouterProtocol {
    public weak var viewModel: VM?
    public weak var navigationController: UINavigationController?
    private var coordinator: BaseCoordinator?
    
    required public init() {}
    
    public func setNavigationController(_ nav: UINavigationController) {
        self.navigationController = nav
    }
    
    public func setCoordinator(_ coordinator: BaseCoordinator) {
        self.coordinator = coordinator
    }
    
    public func push<T: UIViewController>(_ viewController: T, animated: Bool = true) {
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
    public func pop(animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
    }
    
    public func present<T: UIViewController>(_ viewController: T, animated: Bool = true) {
        navigationController?.present(viewController, animated: animated)
    }
}


@MainActor
open class ViewModel<I, R>: @preconcurrency ViewModelProtocol {
    public let interactor: I
    public let router: R
    
    private(set) var isLoading = false
    private(set) var error: Error?
    
    required public init(interactor: I, router: R) {
        self.interactor = interactor
        self.router = router
    }
    
    public func setLoading(_ loading: Bool) {
        isLoading = loading
    }
    
    public func setError(_ error: Error?) {
        self.error = error
    }
}
