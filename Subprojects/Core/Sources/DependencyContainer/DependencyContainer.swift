////////////////////////////////////////////////////////////////////////////////
//
//  DependencyContainer.swift
//  Core
//
//  Created by Iurii Khomiak on 8/28/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
//! MARK: - Forward Declarations
fileprivate protocol DefinitionProtocol
{
    var scope: DependencyContainer.Scope {get}
    var _factory: (DependencyResolver) throws -> Any {get}
}
fileprivate let resolveQueueName = "com.h0myach0k.core.dependencyContainer.queue"

////////////////////////////////////////////////////////////////////////////////
public protocol DependencyResolver
{
    /// Resolves previously registered service
    ///
    /// - Parameters:
    ///   - serviceType: Service type
    ///   - name: Service name if was set during registration
    /// - Returns: Service based on registration settings
    func resolve<Service>(_ serviceType: Service.Type, name: String?) throws -> Service
    
    /// Resolves previously registered service by service type
    ///
    /// - Parameters:
    ///   - serviceType: Service type
    /// - Returns: Service based on registration settings
    func resolve<Service>(_ serviceType: Service.Type) throws -> Service
}

////////////////////////////////////////////////////////////////////////////////
public class DependencyContainer
{
    /// Describe possible scopes
    public enum Scope { case unique, singleton }
    
    //! MARK: - Properties
    /// Contains registered definitions
    private var definitions: [String : DefinitionProtocol] = [:]
    /// Contains resolved instance
    private var resolvedInstances: [String : Any] = [:]
    /// Model lock
    private var lock = NSRecursiveLock()
    /// Resolve queue
    private var resolveQueue = DispatchQueue(label: resolveQueueName)
    /// Resolver
    private var containerResolver: ContainerResolver!
    
    //! MARK: - Init & Deinit
    public init()
    {
        containerResolver = ContainerResolver(container: self)
    }
    
    //! MARK: - Init & Deinit
    /// Registers new service in container
    ///
    /// - Parameters:
    ///   - serviceType: Service type to register
    ///   - scope: Component scope
    ///   - name: Optional name
    ///   - factory: Factory that produces Service
    public func register<Service>(_ serviceType: Service.Type,
        in scope: Scope = .unique, name: String? = nil,
        factory: @escaping (DependencyResolver) throws -> Service)
    {
        let name = name ?? String(describing: serviceType)
        let definition = Definition(scope: scope, factory: factory)
        lock.lock()
        defer { lock.unlock() }
        definitions[name] = definition
    }
    
    /// Resolves previously registered service
    ///
    /// - Parameter name: Service name if was set during registration
    /// - Returns: Service based on registration settings
    public func resolve<Service>(_ serviceType : Service.Type,
        name: String? = nil) throws -> Service
    {
        return try resolveQueue.sync
        { [unowned self] in
            try self.containerResolver.resolve(serviceType, name: name)
        }
    }
    
    //! MARK: - Concrete Definition implementation
    private class Definition<Service> : DefinitionProtocol
    {
        let factory: (DependencyResolver) throws -> Service
        let scope: Scope

        init(scope: Scope, factory: @escaping (DependencyResolver) throws -> Service)
        {
            self.scope = scope
            self.factory = factory
        }
        
        //! As Definition Protocol
        var _factory: (DependencyResolver) throws -> Any
        {
            return factory
        }
    }
    
    //! MARK: - Container resolver implementation
    private class ContainerResolver : DependencyResolver
    {
        unowned let container: DependencyContainer
        
        init(container: DependencyContainer)
        {
            self.container = container
        }
        
        func resolve<Service>(_ serviceType: Service.Type) throws -> Service
        {
            return try resolve(serviceType, name: nil)
        }
        
        func resolve<Service>(_ serviceType: Service.Type, name: String? = nil)
            throws -> Service
        {
            let name = name ?? String(describing: serviceType)
            container.lock.lock()
            guard let definition = container.definitions[name] else { throw
                DependencyContainerError.serviceIsNotRegistered}
            let resolvedInstance = container.resolvedInstances[name] as? Service
            container.lock.unlock()
            
            guard nil == resolvedInstance else { return resolvedInstance! }
            
            let result = try definition._factory(self) as! Service
            container.lock.lock()
            if definition.scope == .singleton
            {
                container.resolvedInstances[name] = result
            }
            container.lock.unlock()
            return result
        }
    }
}
