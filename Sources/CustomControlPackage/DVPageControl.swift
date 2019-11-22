//
//  DVPageControl.swift
//  DemoApp
//
//  Created by Shubham Joshi on 20/11/19.
//  Copyright © 2019 DigiValet. All rights reserved.
//

import UIKit
import Foundation
import CoreGraphics
import QuartzCore

open class DVPageControl: PageControlBase {
    @IBInspectable open var elementWidth: CGFloat = 20 {
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable open var elementHeight: CGFloat = 6 {
        didSet {
            setNeedsLayout()
        }
    }
    private var inactive = [CHILayer]()
    private var active = CHILayer()

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    override open func updateNumberOfPages(_ count: Int) {
        inactive.forEach { $0.removeFromSuperlayer() }
        inactive = [CHILayer]()
        inactive = (0..<count).map {_ in
            let layer = CHILayer()
            self.layer.addSublayer(layer)
            return layer
        }
        self.layer.addSublayer(active)
        setNeedsLayout()
        self.invalidateIntrinsicContentSize()
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        let floatCount = CGFloat(inactive.count)
        let minX = (self.bounds.size.width - self.elementWidth*floatCount - self.padding*(floatCount-1))*0.5
        let minY = (self.bounds.size.height - self.elementHeight)*0.5
        var frame = CGRect(x: minX, y: minY, width: self.elementWidth, height: self.elementHeight)
        active.cornerRadius = self.radius
        active.backgroundColor = (self.currentPageTintColor ?? self.tintColor)?.cgColor
        active.frame = frame
        inactive.enumerated().forEach { index, layer in
            let color = self.tintColor(position: index).withAlphaComponent(self.inactiveTransparency).cgColor
            layer.backgroundColor = color
            if self.borderWidth > 0 {
                layer.borderWidth = self.borderWidth
                layer.borderColor = self.tintColor(position: index).cgColor
            }
            layer.cornerRadius = self.radius
            layer.frame = frame
            frame.origin.x += self.elementWidth + self.padding
        }
        update(for: progress)
    }

    override open func update(for progress: Double) {
        guard let min = inactive.first?.frame,
              let max = inactive.last?.frame,
              progress >= 0 && progress <= Double(numberOfPages - 1),
              numberOfPages > 1 else {
                return
        }
        let total = Double(numberOfPages - 1)
        let dist = max.origin.x - min.origin.x
        let percent = CGFloat(progress / total)
        let offset = dist * percent
        active.frame.origin.x = min.origin.x + offset
    }
    override open var intrinsicContentSize: CGSize {
        return sizeThatFits(CGSize.zero)
    }
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: CGFloat(inactive.count) * self.elementWidth + CGFloat(inactive.count - 1) * self.padding,
                      height: self.elementHeight)
    }
    override open func didTouch(gesture: UITapGestureRecognizer) {
        let point = gesture.location(ofTouch: 0, in: self)
        if let touchIndex = inactive.enumerated().first(where: { $0.element.hitTest(point) != nil })?.offset {
            delegate?.didTouch(pager: self, index: touchIndex)
        }
    }
}
public protocol DVPageControllable: class {
   var numberOfPages: Int { get set }
   var currentPage: Int { get }
   var progress: Double { get set }
   var hidesForSinglePage: Bool { get set }
   var borderWidth: CGFloat { get set }
   func set(progress: Int, animated: Bool)
}
