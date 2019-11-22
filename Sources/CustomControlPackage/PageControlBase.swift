//
//  PageControlBase.swift
//  DemoApp
//
//  Created by Shubham Joshi on 20/11/19.
//  Copyright © 2019 DigiValet. All rights reserved.
//

import UIKit

@IBDesignable open class PageControlBase: UIControl, DVPageControllable {
    open weak var delegate: DVPageControlBaseDelegate?
    @IBInspectable open var numberOfPages: Int = 0 {
        didSet {
            populateTintColors()
            updateNumberOfPages(numberOfPages)
            self.isHidden = hidesForSinglePage && numberOfPages <= 1
        }
    }
    @IBInspectable open var progress: Double = 0 {
        didSet {
            update(for: progress)
        }
    }
    open var currentPage: Int {
        return Int(round(progress))
    }
    @IBInspectable open var padding: CGFloat = 8 {
        didSet {
            setNeedsLayout()
            update(for: progress)
        }
    }
    @IBInspectable open var radius: CGFloat = 2 {
        didSet {
            setNeedsLayout()
            update(for: progress)
        }
    }
    @IBInspectable open var inactiveTransparency: CGFloat = 0.2 {
        didSet {
            setNeedsLayout()
            update(for: progress)
        }
    }
    @IBInspectable open var hidesForSinglePage: Bool = true {
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable open var borderWidth: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    override open var tintColor: UIColor! {
        didSet {
            setNeedsLayout()
        }
    }
    open var tintColors: [UIColor] = [] {
        didSet {
            guard tintColors.count == numberOfPages else {
                fatalError("The number of tint colors needs to be the same as the number of page")
            }
            setNeedsLayout()
        }
    }
    @IBInspectable open var currentPageTintColor: UIColor? {
        didSet {
            setNeedsLayout()
        }
    }
    open var moveToProgress: Double?
    private var displayLink: CADisplayLink?
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDisplayLink()
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupDisplayLink()
    }
    internal func setupDisplayLink() {
        self.displayLink = CADisplayLink(target: WeakProxy(self), selector: #selector(updateFrame))
        self.displayLink?.add(to: .current, forMode: .common)
    }
    @objc internal func updateFrame() {
        self.animate()
    }
    open func set(progress: Int, animated: Bool) {
        guard progress <= numberOfPages - 1 && progress >= 0 else { return }
        if animated == true {
            self.moveToProgress = Double(progress)
        } else {
            self.progress = Double(progress)
        }
    }
    open func tintColor(position: Int) -> UIColor {
        if tintColors.count < numberOfPages {
            return tintColor
        } else {
            return tintColors[position]
        }
    }
    open func insertTintColor(_ color: UIColor, position: Int) {
        if tintColors.count < numberOfPages {
            setupTintColors()
        }
        tintColors[position] = color
    }
    private func setupTintColors() {
        tintColors = Array<UIColor>(repeating: tintColor, count: numberOfPages)
    }
    private func populateTintColors() {
        guard tintColors.count > 0 else { return }

        if tintColors.count > numberOfPages {
            tintColors = Array(tintColors.prefix(numberOfPages))
        } else if tintColors.count < numberOfPages {
            tintColors.append(contentsOf: Array<UIColor>(repeating: tintColor, count: numberOfPages - tintColors.count))
        }
    }
    private var tapEvent: UITapGestureRecognizer?
    @IBInspectable open var enableTouchEvents: Bool = false {
        didSet {
            enableTouchEvents ? enableTouch() : disableTouch()
        }
    }
    private func enableTouch() {
        if tapEvent == nil {
            setupTouchEvent()
        }
    }
    private func disableTouch() {
        if tapEvent != nil {
            removeGestureRecognizer(tapEvent!)
            tapEvent = nil
        }
    }
    internal func setupTouchEvent() {
        tapEvent = UITapGestureRecognizer(target: self, action: #selector(self.didTouch(gesture:)))
        addGestureRecognizer(tapEvent!)
    }

    @objc internal func didTouch(gesture: UITapGestureRecognizer) {}

    open func animate() {
        guard let moveToProgress = self.moveToProgress else { return }
        let pointA = fabsf(Float(moveToProgress))
        let pointB = fabsf(Float(progress))
        if pointA > pointB {
            self.progress += 0.1
        }
        if pointA < pointB {
            self.progress -= 0.1
        }
        if pointA == pointB {
            self.progress = moveToProgress
            self.moveToProgress = nil
        }
        if self.progress < 0 {
            self.progress = 0
            self.moveToProgress = nil
        }
        if self.progress > Double(numberOfPages - 1) {
            self.progress = Double(numberOfPages - 1)
            self.moveToProgress = nil
        }
    }
    open func updateNumberOfPages(_ count: Int) {
        fatalError("Should be implemented in child class")
    }
    open func update(for progress: Double) {
        fatalError("Should be implemented in child class")
    }
    deinit {
        self.displayLink?.remove(from: .current, forMode: .common)
        self.displayLink?.invalidate()
    }
}

extension PageControlBase {
    internal func blend(color1: UIColor, color2: UIColor, progress: CGFloat) -> UIColor {
        let point1 = 1 - progress
        let point2 = progress
        var (red1, green1, blue1, alpha1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        var (red2, green2, blue2, alpha2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        color1.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        color2.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
        let red = point1*red1 + point2*red2
        let green = point1*green1 + point2*green2
        let blue = point1*blue1 + point2*blue2
        return UIColor(red: red, green: green, blue: blue, alpha: point1*alpha1 + point2*alpha2)
    }
}

public protocol DVPageControlBaseDelegate: class {
    func didTouch(pager: PageControlBase, index: Int)
}

final class WeakProxy: NSObject {
    weak var target: NSObjectProtocol?
    init(_ target: NSObjectProtocol) {
        self.target = target
        super.init()
    }
    override func responds(to aSelector: Selector!) -> Bool {
        guard let target = target else { return super.responds(to: aSelector) }
        return target.responds(to: aSelector)
    }
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return target
    }
}

class CHILayer: CAShapeLayer {
    override init() {
        super.init()
        self.actions = [
            "bounds": NSNull(),
            "frame": NSNull(),
            "position": NSNull()
        ]
    }
    override public init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
