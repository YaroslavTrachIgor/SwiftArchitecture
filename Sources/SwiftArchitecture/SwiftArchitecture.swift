// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import UIKit
import SwiftUI

// MARK: - Library Code

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
    associatedtype Destination: Hashable
    
    var viewModel: ViewModelType? { get set }
    var navigationCoordinator: NavigationCoordinator<Destination> { get }
    
    init(navigationCoordinator: NavigationCoordinator<Destination>)
    func navigate(to destination: Destination)
    func dismiss()
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

// Simplified NavigationCoordinator with a reference to another coordinator
open class NavigationCoordinator<Destination: Hashable>: ObservableObject {
    @Published public var path: [Destination] = []
    public weak var childCoordinator: NavigationCoordinator<Destination>? // Reference to another coordinator
    
    public init(childCoordinator: NavigationCoordinator<Destination>? = nil) {
        self.childCoordinator = childCoordinator
    }
    
    public func push(_ destination: Destination) {
        print("Pushing destination: \(destination)") // Debug
        if let child = childCoordinator, child.handles(destination) {
            child.push(destination) // Delegate to child if it handles this destination
        } else {
            path.append(destination)
        }
        print("Path updated: \(path)") // Debug
    }
    
    public func pop() {
        if !path.isEmpty {
            path.removeLast()
        } else if let child = childCoordinator {
            child.pop() // Delegate dismissal to child if path is empty here
        }
    }
    
    // Check if this coordinator handles a specific destination
    open func handles(_ destination: Destination) -> Bool {
        true // Override in subclasses if needed
    }
}

public final class ModuleAssembler {
    @MainActor public static func assemble<P, I, R>(
        viewModel: P.Type,
        interactor: I.Type,
        router: R.Type,
        navigationCoordinator: NavigationCoordinator<R.Destination>
    ) -> P where
    I: InteractorProtocol,
    P: ViewModelProtocol,
    R: RouterProtocol,
    P.InteractorType == I,
    P.RouterType == R,
    I.ViewModelType == P,
    R.ViewModelType == P {
        var interactor = I.init()
        var router = R.init(navigationCoordinator: navigationCoordinator)
        let viewModel = P.init(interactor: interactor, router: router)
        interactor.viewModel = viewModel
        router.viewModel = viewModel
        return viewModel
    }
}

public protocol BaseSwiftUIViewProtocol {
    associatedtype ViewModel
    init(viewModel: ViewModel)
}

public typealias BaseSwiftUIView = View & BaseSwiftUIViewProtocol

@MainActor
open class ViewModel<I, R>: @preconcurrency ViewModelProtocol, ObservableObject {
    public let interactor: I
    public let router: R
    
    required public init(interactor: I, router: R) {
        self.interactor = interactor
        self.router = router
    }
}

@MainActor
open class BaseInteractor<VM: AnyObject>: @preconcurrency InteractorProtocol {
    public weak var viewModel: VM?
    
    required public init() {}
}

@MainActor
open class BaseRouter<VM: AnyObject, D: Hashable>: @preconcurrency RouterProtocol {
    public typealias Destination = D
    
    public weak var viewModel: VM?
    public let navigationCoordinator: NavigationCoordinator<Destination>
    
    required public init(navigationCoordinator: NavigationCoordinator<Destination>) {
        self.navigationCoordinator = navigationCoordinator
    }
    
    public func navigate(to destination: Destination) {
        navigationCoordinator.push(destination)
    }
    
    public func dismiss() {
        navigationCoordinator.pop()
    }
}
