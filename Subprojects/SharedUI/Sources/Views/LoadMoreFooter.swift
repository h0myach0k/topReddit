////////////////////////////////////////////////////////////////////////////////
//
//  LoadMoreFooter.swift
//  SharedUI
//
//  Created by Iurii Khomiak on 8/26/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
public protocol LoadMoreFooterViewDelegate: class
{
    func loadMoreFooterView(_ sender: LoadMoreFooter, shouldChange state:
        LoadMoreFooter.State) -> Bool
    func loadMoreFooterView(_ sender: LoadMoreFooter, didChange state:
        LoadMoreFooter.State)
}

////////////////////////////////////////////////////////////////////////////////
/// Implementation of load more footer
public class LoadMoreFooter : UIView
{
    //! MARK: Forward Declarations
    public enum Style { case `default` }
    public enum State { case hidden, opened }
    
    //! MARK: - Properties
    public weak var delegate: LoadMoreFooterViewDelegate?
    public internal(set) var state: State = .hidden
    {
        didSet { delegateDidChangeState() }
    }
    private let animationDuration: TimeInterval = 0.3
    private var cachedPoint: CGPoint = .zero
    private var scrollView: UIScrollView!
    private var footerInsets: CGFloat = 0
    private var isTransitioning = false
    
    //! MARK: Overrides
    override public  func didMoveToSuperview()
    {
        super.didMoveToSuperview()
        if let superview = superview as? UIScrollView
        {
            updateFrame(in: superview)
        }
    }
    
    //! MARK: - Public
    static public func instantiate(style: Style, scrollView: UIScrollView) ->
        LoadMoreFooter
    {
        let result: LoadMoreFooter
        switch style
        {
            case .default:
                result = DefaultLoadMoreFooter.instantiate()
        }
        result.scrollView = scrollView
        return result
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        updateFrame(in: scrollView)
        guard scrollView.isDragging || scrollView.isDecelerating else { return }
        
        defer { cachedPoint = scrollView.contentOffset }
        guard state == .hidden, cachedPoint != .zero else
        {
            return
        }
        
        let contentSize = scrollView.contentSize.height
        let contentOffset = scrollView.contentOffset
        let currentOffset = scrollView.bounds.height + contentOffset.y
        let isScrollingDown = (contentOffset.y - cachedPoint.y) > 0
        let trigger = contentSize - scrollView.bounds.height
        
        guard isScrollingDown, currentOffset > trigger, contentOffset.y > 0,
            delegateShouldChangeState(.opened) else { return }
        guard !isTransitioning else { return }
        
        transition(to: .opened, completion: {_ in})
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate
        decelerate: Bool)
    {
        
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        
    }
    
    public func hide(in scrollView: UIScrollView, animated: Bool, completion:
        ((_ finished: Bool) -> Void)?)
    {
        updateFrame(in: scrollView)
        guard state == .opened else { return }
        guard !isTransitioning else { return }
        transition(to: .hidden, completion: completion ?? { _ in })
    }
    
    public func prepereToHide()
    {
        guard state == .opened else { return }
        self.alpha = 0
    }

    //! MARK: - Delegate
    private func delegateDidChangeState()
    {
        delegate?.loadMoreFooterView(self, didChange: state)
    }
    
    private func delegateShouldChangeState(_ state: State) -> Bool
    {
        return delegate?.loadMoreFooterView(self, shouldChange: state) ?? true
    }
    
    //! MARK: - Transitions
    private func transition(to state: State, completion: @escaping
        (_ finished: Bool) -> Void)
    {
        guard self.state != state else { return }
        isTransitioning = true
        switch state
        {
            case .opened:
                transitionToOpenedState(completion: completion)
            case .hidden:
                transitionToHiddenState(completion: completion)
        }
    }
    
    private func transitionToOpenedState(completion: @escaping
        (_ finished: Bool) -> Void)
    {
        //! Configure new insets
        var contentInsets = scrollView.contentInset
        let footerHeight = bounds.height
        contentInsets.bottom += footerHeight
        
        //! Store additional scroll view insets
        self.footerInsets = footerHeight
        
        //! Restore alpha
        self.alpha = 1
        
        //! Perform animation
        setScrollViewInsets(contentInsets, animated: true)
        { [weak self] finished in
            guard let `self` = self else { return }
            self.isTransitioning = false
            self.state = .opened
            completion(finished)
        }
    }
    
    private func transitionToHiddenState(completion: @escaping
        (_ finished: Bool) -> Void)
    {
        //! Configure new insets
        var contentInsets = scrollView.contentInset
        contentInsets.bottom -= footerInsets
        
        //! Reset insets
        self.footerInsets = 0
        
        setScrollViewInsets(contentInsets, animated: true)
        { [weak self] finished in
            guard let `self` = self else { return }
            self.isTransitioning = false
            self.state = .hidden
            completion(finished)
        }
    }
    
    private func setScrollViewInsets(_ insets: UIEdgeInsets, animated: Bool,
        completion: @escaping (_ finished: Bool) -> Void)
    {
        let animations = { self.scrollView.contentInset = insets }
        if animated
        {
            UIView.animate(withDuration: animationDuration, delay: 0,
                options: [.allowUserInteraction, .beginFromCurrentState],
                animations: animations, completion: completion)
        }
        else
        {
            animations()
            completion(true)
        }
    }
    
    private func scrollToLoadMoreFooterIfNeeded()
    {
        guard !scrollView.isDragging else { return }
        let contentSize = scrollView.contentSize
        let y = contentSize.height - scrollView.bounds.height + bounds.height
        var contentOffset = scrollView.contentOffset
        contentOffset.y = y
        scrollView.setContentOffset(contentOffset, animated: true)
    }
    
    //! MARK: - Private
    private func updateFrame(in scrollView: UIScrollView)
    {
        frame.origin.y = max(scrollView.contentSize.height,
            scrollView.bounds.height)
    }
}
