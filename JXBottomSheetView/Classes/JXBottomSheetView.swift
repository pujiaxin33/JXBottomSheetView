//
//  JXBottomSheetView.swift
//  JXBottomSheetView
//
//  Created by jiaxin on 2018/8/1.
//  Copyright © 2018年 jiaxin. All rights reserved.
//

import UIKit

public enum JXBottomSheetState {
    case maxDisplay
    case minDisplay
}

public class JXBottomSheetView: UIView {
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
    public var triggerDistance: CGFloat = 10    //滚动多少距离，可以触发展开和收缩状态切换
    public var isTriggerImmediately = false    //当达到触发距离时，是否立即触发。否则就等到用户结束拖拽时触发。
    fileprivate var panGesture: UIPanGestureRecognizer!
    fileprivate var mininumDisplayHeight: CGFloat = 100
    fileprivate var maxinumDisplayHeight: CGFloat = 300
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

    var contentView: UIScrollView

    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        if newSuperview == nil {
            contentView.removeObserver(self, forKeyPath: "contentSize")
        }
    }

    public init(contentView: UIScrollView) {
        self.contentView = contentView
        super.init(frame: CGRect.zero)

        clipsToBounds = true
        backgroundColor = .clear
        addSubview(contentView)
        contentView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)

        panGesture = UIPanGestureRecognizer(target: self, action: #selector(processPan(gesture:)))
        panGesture.delegate = self
        contentView.addGestureRecognizer(panGesture)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        if displayState == .minDisplay {
            contentView.frame = minFrame
        }else {
            contentView.frame = maxFrame
        }
    }

    @objc fileprivate func processPan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            print("began")
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
                    displayState = .maxDisplay
                }
            }else  {
                if contentView.frame.origin.y >= minFrame.origin.y {
                    displayState = .minDisplay
                }
            }

            if contentView.frame.origin.y > maxFrame.origin.y ||
                (contentView.frame.origin.y == minFrame.origin.y && contentView.frame.origin.y == maxFrame.origin.y) {
                //当contentView本身还未滚动到最大显示值时，内部的内容不允许滚动。mininumDisplayHeight = maxinumDisplayHeight时也不允许内部内容滚动。
                contentView.setContentOffset(CGPoint.zero, animated: false)
            }

            if isTriggerImmediately {
                if displayState == .minDisplay {
                    if minFrame.origin.y - contentView.frame.origin.y > triggerDistance {
                        displayMax()
                        contentView.setContentOffset(CGPoint.zero, animated: false)
                    }
                }else {
                    if contentView.frame.origin.y - maxFrame.origin.y > triggerDistance {
                        displayMin()
                    }
                }
            }
        case .cancelled, .ended, .failed:
            print("end")
            if displayState == .minDisplay {
                if minFrame.origin.y - contentView.frame.origin.y > triggerDistance {
                    displayMax()
                    contentView.setContentOffset(CGPoint.zero, animated: false)
                }else {
                    displayMin()
                }
            }else {
                if contentView.frame.origin.y - maxFrame.origin.y > triggerDistance {
                    displayMin()
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
        contentView.isUserInteractionEnabled = false
        panGesture.isEnabled = false
        UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.contentView.frame = self.maxFrame
        }) { (finished) in
            self.contentView.isUserInteractionEnabled = true
            self.panGesture.isEnabled = true
            self.displayState = .maxDisplay
        }
    }

    public func displayMin() {
        if contentView.frame == minFrame {
            return
        }
        contentView.isUserInteractionEnabled = false
        panGesture.isEnabled = false
        UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.contentView.frame = self.minFrame
        }) { (finished) in
            self.contentView.isUserInteractionEnabled = true
            self.panGesture.isEnabled = true
            self.displayState = .minDisplay
        }
    }

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            var shouldReload = false
            if displayState == .minDisplay {
                if contentView.contentSize.height < mininumDisplayHeight {
                    shouldReload = true
                }else if contentView.contentSize.height > mininumDisplayHeight && contentView.contentSize.height <= defaultMininumDisplayHeight {
                    shouldReload = true
                }
            }else {
                if contentView.contentSize.height < maxinumDisplayHeight {
                    shouldReload = true
                }else if contentView.contentSize.height > maxinumDisplayHeight && contentView.contentSize.height <= defaultMaxinumDisplayHeight {
                    shouldReload = true
                }
            }
            mininumDisplayHeight = min(defaultMininumDisplayHeight, contentView.contentSize.height)
            maxinumDisplayHeight = min(defaultMaxinumDisplayHeight, contentView.contentSize.height)

            if shouldReload {
                if displayState == .maxDisplay {
                    displayMax()
                }else {
                    displayMin()
                }
            }
        }
    }

}

extension JXBottomSheetView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}




