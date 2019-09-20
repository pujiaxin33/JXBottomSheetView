//
//  JXBottomSheetView.swift
//  JXBottomSheetView
//
//  Created by jiaxin on 2018/8/1.
//  Copyright © 2018年 jiaxin. All rights reserved.
//

import UIKit

@objc public enum JXBottomSheetState: Int {
    case maxDisplay
    case minDisplay
}

@objc public protocol JXBottomSheetViewDelegate: NSObjectProtocol {
    @objc optional func bottomSheet(bottomSheet: JXBottomSheetView, willDisplay state: JXBottomSheetState)
    @objc optional func bottomSheet(bottomSheet: JXBottomSheetView, didDisplayed state: JXBottomSheetState)
}

public class JXBottomSheetView: UIView {
    weak public var delegate: JXBottomSheetViewDelegate?
    //默认最小内容高度，当contentSize.height更小时，会更新mininumDisplayHeight值
    public var defaultMininumDisplayHeight: CGFloat = 100 {
        didSet {
            mininumDisplayHeight = defaultMininumDisplayHeight
        }
    }
    //默认最大内容高度，当contentSize.height更小时，会更新maxinumDisplayHeight值
    public var defaultMaxinumDisplayHeight: CGFloat = 300 {
        didSet {
            maxinumDisplayHeight = defaultMaxinumDisplayHeight
        }
    }
    public var displayState: JXBottomSheetState = .minDisplay
    //1、判断triggerVelocity，大于当前切换方向，直接切换；
    //2、判断triggerDistance：
    //2.1、当超过triggerDistance时，根据结束手势时手指的方向切换状态；
    //2.2、未超过triggerDistance时，恢复状态；
    public var triggerVelocity: CGFloat = 1000  //触发状态切换的滚动速度，points/second
    public var triggerDistance: CGFloat = 50    //滚动多少距离，可以触发展开和收缩状态切换
    fileprivate var mininumDisplayHeight: CGFloat = 100
    fileprivate var maxinumDisplayHeight: CGFloat = 300
    fileprivate var isFirstLayout = true
    fileprivate var minFrame: CGRect {
        get {
            return CGRect(x: 0, y: self.bounds.size.height - mininumDisplayHeight, width: self.bounds.size.width, height: maxinumDisplayHeight)
        }
    }
    fileprivate var maxFrame: CGRect {
        get {
            return CGRect(x: 0, y: self.bounds.size.height - maxinumDisplayHeight, width: self.bounds.size.width, height: maxinumDisplayHeight)
        }
    }
    fileprivate var lastContentSize: CGSize?

    var contentView: UIScrollView

    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        if newSuperview == nil {
            contentView.removeObserver(self, forKeyPath: "contentSize")
        }
    }

    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return contentView.frame.contains(point)
    }

    public init(contentView: UIScrollView) {
        self.contentView = contentView
        super.init(frame: CGRect.zero)

        clipsToBounds = true
        backgroundColor = .clear

        contentView.bounces = false
        if let tableView = contentView as? UITableView {
            tableView.estimatedRowHeight = 0
        }
        addSubview(contentView)
        contentView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(processPan(gesture:)))
        panGesture.delegate = self
        contentView.addGestureRecognizer(panGesture)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        if isFirstLayout {
            isFirstLayout = false
            if displayState == .minDisplay {
                contentView.frame = minFrame
            }else {
                contentView.frame = maxFrame
            }
        }
    }

    @objc fileprivate func processPan(gesture: UIPanGestureRecognizer) {
        if mininumDisplayHeight == maxinumDisplayHeight {
            return
        }
        switch gesture.state {
        case .changed:
            var canMoveFrame = false
            if displayState == .minDisplay {
                canMoveFrame = true
            }else  {
                if contentView.frame.origin.y > maxFrame.origin.y || contentView.contentOffset.y <= 0 {
                    canMoveFrame = true
                }
            }
            if canMoveFrame {
                let point = gesture.translation(in: contentView)
                var frame = contentView.frame
                frame.origin.y += point.y
                frame.origin.y = max(frame.origin.y, maxFrame.origin.y)
                frame.origin.y = min(frame.origin.y, minFrame.origin.y)
                contentView.frame = frame
            }
            gesture.setTranslation(CGPoint.zero, in: contentView)
            if displayState == .minDisplay {
                if contentView.frame.origin.y <= maxFrame.origin.y {
                    delegate?.bottomSheet?(bottomSheet: self, willDisplay: .maxDisplay)
                    displayState = .maxDisplay
                    delegate?.bottomSheet?(bottomSheet: self, didDisplayed: .maxDisplay)
                }
            }else  {
                if contentView.frame.origin.y >= minFrame.origin.y {
                    delegate?.bottomSheet?(bottomSheet: self, willDisplay: .minDisplay)
                    displayState = .minDisplay
                    delegate?.bottomSheet?(bottomSheet: self, didDisplayed: .minDisplay)
                }
            }

            if contentView.frame.origin.y > maxFrame.origin.y ||
                (contentView.frame.origin.y == minFrame.origin.y && contentView.frame.origin.y == maxFrame.origin.y) {
                //当contentView本身还未滚动到最大显示值时，内部的内容不允许滚动。mininumDisplayHeight = maxinumDisplayHeight时也不允许内部内容滚动。
                contentView.setContentOffset(CGPoint.zero, animated: false)
            }
        case .cancelled, .ended, .failed:
            let velocity = gesture.velocity(in: gesture.view)
            if displayState == .minDisplay {
                if velocity.y < -triggerVelocity {
                    displayMax()
                }else if minFrame.origin.y - contentView.frame.origin.y > triggerDistance {
                    if velocity.y <= 0 {
                        //往上滚
                        displayMax()
                    }else {
                        //往下滚
                        displayMin()
                    }
                }else {
                    displayMin()
                }
                contentView.setContentOffset(CGPoint.zero, animated: false)
            }else {
                if velocity.y > triggerVelocity && contentView.contentOffset.y <= 0 {
                    displayMin()
                    contentView.setContentOffset(CGPoint.zero, animated: false)
                }else if contentView.frame.origin.y - maxFrame.origin.y > triggerDistance {
                    if velocity.y < 0 {
                        //往上滚
                        displayMax()
                    }else {
                        //往下滚
                        displayMin()
                    }
                }else {
                    displayMax()
                }
            }
        default:
            break
        }
    }

    public func displayMax() {
        if contentView.frame == maxFrame {
            return
        }
        delegate?.bottomSheet?(bottomSheet: self, willDisplay: JXBottomSheetState.maxDisplay)
        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.contentView.frame = self.maxFrame
        }) { (finished) in
            self.displayState = .maxDisplay
            self.delegate?.bottomSheet?(bottomSheet: self, didDisplayed: JXBottomSheetState.maxDisplay)
        }
    }

    public func displayMin() {
        if contentView.frame == minFrame {
            return
        }
        delegate?.bottomSheet?(bottomSheet: self, willDisplay: JXBottomSheetState.minDisplay)
        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.contentView.frame = self.minFrame
        }) { (finished) in
            self.displayState = .minDisplay
            self.delegate?.bottomSheet?(bottomSheet: self, didDisplayed: JXBottomSheetState.minDisplay)
        }
    }

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            guard let newContentSize = change?[NSKeyValueChangeKey.newKey] as? CGSize else {
                return
            }
            guard newContentSize != lastContentSize else {
                return
            }
            mininumDisplayHeight = min(defaultMininumDisplayHeight, contentView.contentSize.height)
            maxinumDisplayHeight = min(defaultMaxinumDisplayHeight, contentView.contentSize.height)
            if displayState == .maxDisplay {
                contentView.frame = maxFrame
            }else {
                contentView.frame = minFrame
            }
            lastContentSize = newContentSize
        }
    }

}

extension JXBottomSheetView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}




