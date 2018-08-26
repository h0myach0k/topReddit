////////////////////////////////////////////////////////////////////////////////
//
//  BaseStatesViewController.swift
//  SharedUI
//
//  Created by Iurii Khomiak on 8/26/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation
import Core

////////////////////////////////////////////////////////////////////////////////
/// View controller that defines posibility to switch states animated
open class BaseStatesViewController : UIViewController, ErrorViewDelegate
{
    //! MARK: - Forward Declarations
    public enum Screen { case noData, error, content, loading }
    private struct Transition
    {
        var fromView: UIView?
        var toView: UIView
        var animated: Bool
        var screen: Screen
    }
    
    //! MARK: - Loading View properties
    /// Title that will be displayed in loading view
    open var loadingTitle: String { return "Loading".localized }
    /// Message that will be displayed in loading view
    open var loadingMessage: String? { return "Please wait, data is being loaded…"
        .localized }
    /// The loading view style
    open var loadingViewStyle: LoadingView.Style { return .default }
    
    //! MARK: - Error View properties
    /// Title to be displayed on error view
    open var errorTitle: String { return "Failed to load data".localized }
    /// Message to be displayed on error view
    open var errorMessage: String? { return nil }
    /// Icon to be displayed on error view
    open var errorIcon: UIImage? { return UIImage(named: "ico_cloud_off", in:
        .sharedUI, compatibleWith: nil) }
    /// Action to be displayed on error view
    open var errorAction: String? { return "Retry…".localized }
    /// The error view style
    open var errorViewStyle: ErrorView.Style { return .default }
    
    //! MARK: - No Data View properties
    /// Title to be displayed on error view
    open var noDataMessage: String { return "No data to show".localized }
    /// Icon to be displayed on error view
    open var noDataIcon: UIImage? { return UIImage(named: "ico_face_unhappy", in:
        .sharedUI, compatibleWith: nil) }
    /// The no data view style
    open var noDataViewStyle: NoDataView.Style { return .default }
    
    //! MARK: - UI Connections
    @IBOutlet open var contentView: UIView!
    
    //! MARK: - Properties
    /// Contains visible screen information
    public internal(set) var screen: Screen = .content
    private var activeView: UIView!
    private var currentTransition: Transition?
    private var scheduledTransition: Transition?
    
    //! MARK: - Init & Deinit
    public init ()
    {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    //! MARK: - UIViewController overrides
    open override func viewDidLoad()
    {
        super.viewDidLoad()
        activeView = contentView
        addContentViewIfNeeded()
    }
    
    //! MARK: - Screen management
    public func setScreen(_ screen: Screen, animated: Bool = false)
    {
        guard screen != self.screen else { return }
        self.screen = screen
        let view = self.view(for: screen)
        setActiveView(view, screen: screen, animated: animated)
    }
    
    //! MARK: - Loading View related methods
    /// Creates loading view with loading related properties defined in controller
    /// Clients may override this method to provide own implementation of
    /// loading view
    ///
    /// - Returns: UI View instance that stands for loading view
    open func createLoadingView() -> UIView
    {
        let result = LoadingView.instantiate(style: loadingViewStyle)
        result.title = loadingTitle
        result.message = loadingMessage
        return result
    }
    
    /// Adds loading view to view hierarchy. Clients may override this method
    /// and provide own implementation
    open func addLoadingView(_ view: UIView)
    {
        addStateView(view)
    }
    
    //! MARK: - No Data View related methods
    /// Creates no data view with no data related properties defined in controller
    /// Clients may override this method to provide own implementation of
    /// no data view
    ///
    /// - Returns: UI View instance that stands for no data view
    open func createNoDataView() -> UIView
    {
        let result = NoDataView.instantiate(style: noDataViewStyle)
        result.icon = noDataIcon
        result.message = noDataMessage
        return result
    }
    
    /// Adds loading view to view hierarchy. Clients may override this method
    /// and provide own implementation
    open func addNoDataView(_ view: UIView)
    {
        addStateView(view)
    }
    
    //! MARK: - Error View related methods
    /// Creates error view with error related properties defined in controller
    /// Clients may override this method to provide own implementation of
    /// error view
    ///
    /// - Returns: UI View instance that stands for error view
    open func createErrorView() -> UIView
    {
        let result = ErrorView.instantiate(style: errorViewStyle)
        result.title = errorTitle
        result.message = errorMessage
        result.icon = errorIcon
        result.action = errorAction
        result.delegate = self
        return result
    }
    
    /// Adds error view to view hierarchy. Clients may override this method
    /// and provide own implementation
    open func addErrorView(_ view: UIView)
    {
        addStateView(view)
    }
    
    //! MARK: - Private
    private func addContentViewIfNeeded()
    {
        guard nil == contentView else { return }
        contentView = UIView()
        view.addSubview(contentView)
        contentView.frame = view.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private func addStateView(_ view: UIView)
    {
        self.view.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo:
            view.leadingAnchor).isActive = true
        self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo:
            view.trailingAnchor).isActive = true
        self.view.safeAreaLayoutGuide.topAnchor.constraint(equalTo:
            view.topAnchor).isActive = true
        self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo:
            view.bottomAnchor).isActive = true
    }
    
    private func view(for screen: Screen) -> UIView
    {
        let result: UIView
        switch screen
        {
            case .error:
                result = createErrorView()
            case .content:
                result = contentView
            case .loading:
                result = createLoadingView()
            case .noData:
                result = createNoDataView()
        }
        return result
    }
    
    private func addView(_ view: UIView, screen: Screen)
    {
        switch screen
        {
            case .error:
                addErrorView(view)
            case .content:
                break
            case .loading:
                addLoadingView(view)
            case .noData:
                addNoDataView(view)
        }
    }
    
    private func setActiveView(_ view: UIView, screen: Screen, animated:
        Bool = false)
    {
        guard activeView != view else { return }
        
        let oldActiveView = activeView
        activeView = view
        
        let transition = Transition(fromView: oldActiveView, toView: activeView,
            animated: animated, screen: screen)
        if let _ = currentTransition
        {
            scheduleTransition(transition)
        }
        else
        {
            performTransition(transition)
        }
    }
        
    private func performTransition(_ transition: Transition)
    {
        currentTransition = transition
        
        let fromView = transition.fromView
        let toView = transition.toView
        let screen = transition.screen
        let animated = transition.animated
        
        let completion =
        { [weak self] in
            self?.currentTransition = nil
            self?.startScheduledTransitionIfNeeded()
        }
        
        //! Addds view to hierarchy
        addView(toView, screen: screen)
        
        //! Calculate animation params. Since methods addLoadingView,
        //! addNoDataView, etc is open for overriding, subclasses may use
        //! it to add view into content view.
        let fromViewInContentView = (nil != fromView) ? isContentViewHostsView(
            fromView!) : false
        let fromViewIsContentView = fromView == contentView
        let toViewInContentView = isContentViewHostsView(toView)
        let toViewIsContentView = toView == contentView
        
        let contentViewAlpha: CGFloat = (toViewInContentView ||
            toViewIsContentView) ? 1 : 0
        let removesFromView = !fromViewIsContentView
        let fadesInToView = !fromViewIsContentView || !fromViewInContentView
        let fadesOutFromView = !fromViewIsContentView
        
        //! Configure animation blocks
        let animations =
        {
            if fadesInToView
            {
                toView.alpha = 1
            }
            if fadesOutFromView
            {
                fromView?.alpha = 0
            }
            self.contentView.alpha = contentViewAlpha
        }
        let animationCompletion =
        { (finished: Bool) in
            if removesFromView
            {
                fromView?.removeFromSuperview()
            }
            completion()
        }
        
        //! Finally, start animations
        if animated
        {
            UIView.animate(withDuration: 0.3, delay: 0, options:
                [.transitionCrossDissolve, .layoutSubviews],
                animations:
                {
                    animations()
                }, completion: animationCompletion)
        }
        else
        {
            animations()
            animationCompletion(true)
        }
    }
    
    private func scheduleTransition(_ transition: Transition)
    {
        if var scheduledTransition = scheduledTransition
        {
            if transition.screen == screen
            {
                self.scheduledTransition = nil
            }
            else
            {
                scheduledTransition.toView = transition.toView
                scheduledTransition.screen = transition.screen
                scheduledTransition.animated = transition.animated
                self.scheduledTransition = transition
            }
        }
        else
        {
            self.scheduledTransition = transition
        }
    }
    
    private func startScheduledTransitionIfNeeded()
    {
        guard let scheduledTransition = scheduledTransition else
        {
            return
        }
        
        self.scheduledTransition = nil
        performTransition(scheduledTransition)
    }
    
    private func isContentViewHostsView(_ view: UIView) -> Bool
    {
        var result = false
        var view = view
        while true
        {
            guard let superview = view.superview else { break }
            view = superview
            if view == contentView
            {
                result = true
                break
            }
            else if view == self.view
            {
                result = false
                break
            }
        }
        return result
    }
}
