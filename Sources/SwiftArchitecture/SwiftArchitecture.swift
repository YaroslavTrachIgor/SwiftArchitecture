// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import UIKit
import SwiftUI

// MARK: - Library Code

public protocol ViewModelProtocol {
    associatedtype InteractorType
    
    var interactor: InteractorType { get }
    
    init(interactor: InteractorType)
}

public protocol InteractorProtocol {
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
    @MainActor public static func assemble<P, I>(
        viewModel: P.Type,
        interactor: I.Type
    ) -> P where
    I: InteractorProtocol,
    P: ViewModelProtocol,
    P.InteractorType == I,
    I.ViewModelType == P {
        var interactor = I.init()
        let viewModel = P.init(interactor: interactor)
        interactor.viewModel = viewModel
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
    
    required public init(interactor: I) {
        self.interactor = interactor
    }
}

@MainActor
open class BaseInteractor<VM: AnyObject>: @preconcurrency InteractorProtocol {
    public weak var viewModel: VM?
    
    required public init() {}
}
