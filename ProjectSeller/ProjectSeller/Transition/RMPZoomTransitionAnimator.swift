//
// Copyright (c) 2015 Recruit Marketing Partners Co.,Ltd. All rights reserved.
// Copyright (c) 2018 Yuichi Hirano
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

public typealias RMPZoomTransitionable = RMPZoomTransitionAnimating & RMPZoomTransitionDelegate

open class RMPZoomTransitionAnimator: NSObject {
    
    open var goingForward: Bool = false
    open weak var sourceTransition: RMPZoomTransitionAnimating?
    open weak var destinationTransition: RMPZoomTransitionable?
    
    private let forwardAnimationDuration: TimeInterval
    private let forwardCompleteAnimationDuration: TimeInterval
    private let backwardAnimationDuration: TimeInterval
    private let backwardCompleteAnimationDuration: TimeInterval
    
    public init(forward: TimeInterval = 0.3, //0.3 이게 애니메이션 걸리는 시간부분이고..
        forwardComplete: TimeInterval = 0.2, //0.2
        backward: TimeInterval = 0.25, //0.25
        backwardComplete: TimeInterval = 0.18) {
        forwardAnimationDuration = forward
        forwardCompleteAnimationDuration = forwardComplete
        backwardAnimationDuration = backward
        backwardCompleteAnimationDuration = backwardComplete
    }
}

// MARK: - UIViewControllerAnimatedTransitioning

extension RMPZoomTransitionAnimator: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if self.goingForward {
            return forwardAnimationDuration + forwardCompleteAnimationDuration
        } else {
            return backwardAnimationDuration + backwardCompleteAnimationDuration
        }
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // Setup for animation transition
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                return
        }
        let containerView = transitionContext.containerView
        containerView.addSubview(fromVC.view)
        containerView.addSubview(toVC.view)
        
        guard let sourceTransition = self.sourceTransition,
            let destinationTransition = self.destinationTransition else {
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                return
        }
        
        let alphaView = UIView(frame: transitionContext.finalFrame(for: toVC))
        alphaView.backgroundColor = UIColor.black
        containerView.addSubview(alphaView)
        
        let sourceImageView = sourceTransition.transitionSourceImageView
        containerView.addSubview(sourceImageView)
        
        if self.goingForward {
            fromVC.beginAppearanceTransition(false, animated: true)
            UIView.animate(withDuration: forwardAnimationDuration, delay: 0, options: .curveEaseOut, animations: {
                sourceImageView.frame = CGRect(x: containerView.center.x - (sourceImageView.frame.width/2),
                                               y: containerView.frame.height/5,
                                               width: sourceImageView.frame.width,
                                               height: sourceImageView.frame.height)
                sourceImageView.layer.cornerRadius = 14
                alphaView.alpha = 0.9
            }, completion: { finished in
                UIView.animate(withDuration: self.forwardCompleteAnimationDuration, delay: 0, options: .curveEaseOut, animations: {
                    sourceImageView.frame = CGRect(x: 0, y: 44, width: 414, height: 375)
                    alphaView.alpha = 0
                    sourceImageView.transform = CGAffineTransform.identity
                }, completion: { finished in
                    sourceImageView.alpha = 0
                    destinationTransition.zoomTransitionAnimator?(animator: self,
                                                                  didCompleteTransition: !transitionContext.transitionWasCancelled,
                                                                  animatingSourceImageView: sourceImageView)
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                    alphaView.removeFromSuperview()
                    sourceImageView.removeFromSuperview()
                    fromVC.endAppearanceTransition()
                })
            })
        } else {
            UIView.animate(withDuration: backwardAnimationDuration, delay: 0, options: .curveEaseOut, animations: {
                alphaView.alpha = 0
            }, completion: { finished in
                UIView.animate(withDuration: self.backwardCompleteAnimationDuration, delay: 0, options: .curveEaseOut, animations: {
                    sourceImageView.alpha = 0
                }, completion: { finished in
                    destinationTransition.zoomTransitionAnimator?(animator: self,
                                                                  didCompleteTransition: !transitionContext.transitionWasCancelled,
                                                                  animatingSourceImageView: sourceImageView)
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                    alphaView.removeFromSuperview()
                    sourceImageView.removeFromSuperview()
                })
            })
        }
    }
}
