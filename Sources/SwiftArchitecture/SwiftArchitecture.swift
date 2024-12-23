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
    init()
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
        presenter: P.Type,
        interactor: I.Type,
        router: R.Type
    ) -> P where
    V: ViewProtocol,
    P: ViewModelProtocol,
    I: InteractorProtocol,
    R: RouterProtocol,
    V.ViewModelType == P,
    P.InteractorType == I,
    P.RouterType == R,
    I.ViewModelType == P,
    R.ViewModelType == P {
        
        var view = V.init()
        var interactor = I.init()
        var router = R.init()
        let viewModel = P.init(
            interactor: interactor,
            router: router
        )
        
        view.viewModel = viewModel
        interactor.viewModel = viewModel
        router.viewModel = viewModel
        
        return viewModel
    }
}















@MainActor
open class BaseViewController<VM>: @preconcurrency ViewProtocol {
    
    public var viewModel: VM
    
    required public init() {
        fatalError("Use ModuleAssembler")
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@MainActor
open class ViewModel<I, R>: @preconcurrency ViewModelProtocol {
    
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
open class BaseRouter<VM: AnyObject>: @preconcurrency RouterProtocol {
    public weak var viewModel: VM?
    
    required public init() {}
}
