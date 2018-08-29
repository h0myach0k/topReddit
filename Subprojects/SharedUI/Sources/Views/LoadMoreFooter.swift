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
    private var cachedPoint: CGPoint = .zero
    
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
    static public func instantiate(style: Style) -> LoadMoreFooter
    {
        let result: LoadMoreFooter
        switch style
        {
            case .default:
                result = DefaultLoadMoreFooter.instantiate()
        }
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
        
        state = .opened
        scrollView.contentInset.bottom = bounds.height
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
        
        let contentOffset = scrollView.contentOffset
        scrollView.contentInset.bottom = 0
        scrollView.setContentOffset(contentOffset, animated: false)
        state = .hidden
        completion?(true)
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
    
    //! MARK: - Private
    private func updateFrame(in scrollView: UIScrollView)
    {
        frame.origin.y = max(scrollView.contentSize.height,
            scrollView.bounds.height)
    }
}
