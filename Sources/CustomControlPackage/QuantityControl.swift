//
//  QuantityControl.swift
//  DemoApp
//
//  Created by Shubham Joshi on 19/11/19.
//  Copyright © 2019 DigiValet. All rights reserved.
//

import UIKit

protocol QuantityControlDelegate: class {
    func quantityControll(_ quantityControll: QuantityControl, didChange value: Int, with btnTag: Int)
}

@IBDesignable
  class QuantityControl: UIView {
    @IBInspectable private var minimumQuantity: Int = 1 {
        didSet {
            loadView()
        }
    }
    @IBInspectable private var maximumQuantity: Int = 10 {
        didSet {
            loadView()
        }
    }
    @IBInspectable  var minusImage: UIImage? = UIImage(named: "quantityMinus") {
        didSet {
            loadView()
        }
    }
    @IBInspectable  var plusImage: UIImage? = UIImage(named: "quantityPlus") {
        didSet {
            loadView()
        }
    }
    @IBInspectable  var btnSize: CGFloat = 30 {
        didSet {
            loadView()
        }
    }
    @IBInspectable  var displayExtraLabel: Bool = true {
        didSet {
            loadView()
        }
    }
    @IBInspectable  var extraText: String = "" {
        didSet {
            loadView()
        }
    }
    @IBInspectable  var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    weak var delegate: QuantityControlDelegate?
    var font: UIFont = UIFont(name: "Cochin", size: 35)!
    var disableFont: UIFont = UIFont(name: "Cochin", size: 35)!
    var color: UIColor = .black
    var labelQuantity = UILabel()
    var buttonMinus = UIButton()
    var buttonPlus = UIButton()
    var extraLabel = UILabel()
    var lblQuantityText: String! {
        get {
            return labelQuantity.text
        }
        set(lblQuantityText) {
            if lblQuantityText != nil {
                self.labelQuantity.animatedText = lblQuantityText
            } else {
                self.labelQuantity.animatedText = "0"
            }
        }
    }
    private var range: CountableClosedRange<Int> {
        if minimumQuantity > maximumQuantity {
            maximumQuantity = minimumQuantity+1
        }
        return minimumQuantity...maximumQuantity
    }
     var value: Int {
        get {
            return Int(labelQuantity.text ?? "") ?? minimumQuantity
        }
        set {
            if range.contains(newValue) {
                labelQuantity.animatedText = "\(newValue)"
            }
        }
    }
    required  init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadView()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadView()
    }
    private func loadView() {
        subviews.forEach({$0.removeFromSuperview()})
        setButtonProperty()
        let space = (frame.height-btnSize)/2
        let lblQuantityWidth: CGFloat = frame.width-(btnSize+space)*2
        let lblQuantityHeight: CGFloat = frame.height
        let btnMinusY = frame.height/2 - btnSize/2
        let btnPlusX = (frame.width-btnSize-space)
        buttonMinus.frame = CGRect(x: space, y: btnMinusY, width: btnSize, height: btnSize)
        buttonPlus.frame = CGRect(x: btnPlusX, y: btnMinusY, width: btnSize, height: btnSize)
        let stackViewX = buttonMinus.frame.width
        if #available(iOS 9.0, *) {
            let stackForLabels = UIStackView()
            stackForLabels.axis = .horizontal
            stackForLabels.alignment = .fill
            stackForLabels.distribution = .fillEqually
            stackForLabels.frame = CGRect(x: stackViewX, y: 0, width: lblQuantityWidth, height: lblQuantityHeight)
            stackForLabels.addArrangedSubview(extraLabel)
            stackForLabels.insertArrangedSubview(labelQuantity, at: 0)
            addSubview(stackForLabels)
        }
        labelQuantity.textAlignment = .center
        labelQuantity.font = font
        labelQuantity.textColor = color
        if displayExtraLabel {
            extraLabel.font = font
            extraLabel.text = extraText
            extraLabel.textAlignment = .center
        }
        addSubview(buttonMinus)
        addSubview(buttonPlus)
        value = minimumQuantity
    }
    private func setButtonProperty() {
        buttonMinus.removeTarget(self, action: #selector(btnMinusAction(sender:)), for: .touchUpInside)
        buttonPlus.removeTarget(self, action: #selector(btnMinusAction(sender:)), for: .touchUpInside)
        buttonMinus.tag = 0
        buttonPlus.tag = 1
        buttonMinus.addTarget(self, action: #selector(btnMinusAction(sender:)), for: .touchUpInside)
        buttonPlus.addTarget(self, action: #selector(btnPlusAction(sender:)), for: .touchUpInside)
        if plusImage != nil {
            buttonPlus.setImage(plusImage, for: .normal)
        } else {
            buttonPlus.setTitle("+", for: .normal)
            buttonPlus.titleLabel?.font = font
            buttonPlus.setTitleColor(labelQuantity.textColor, for: .normal)
        }
        if minusImage != nil {
            buttonMinus.setImage(minusImage, for: .normal)
        } else {
            buttonMinus.setTitle("-", for: .normal)
            buttonMinus.titleLabel?.font = font
            buttonMinus.setTitleColor(labelQuantity.textColor, for: .normal)
        }
    }
    @discardableResult func setMinMaxQuantity(minLimit: Int, maxLimit: Int) -> Bool {
        if minLimit > maxLimit {
            return false
        } else {
            minimumQuantity = minLimit
            maximumQuantity = maxLimit
            return true
        }
    }
    func setDisable(disableColor: UIColor) {
        labelQuantity.font = disableFont
        buttonPlus.titleLabel?.font = disableFont
        buttonMinus.titleLabel?.font = disableFont
        labelQuantity.textColor = disableColor
        buttonPlus.setTitleColor(disableColor, for: .normal)
        buttonMinus.setTitleColor(disableColor, for: .normal)
    }
    func setEnable(disableColor: UIColor) {
        labelQuantity.font = font
        buttonPlus.titleLabel?.font = font
        buttonMinus.titleLabel?.font = font
        labelQuantity.textColor = color
        buttonPlus.setTitleColor(color, for: .normal)
        buttonMinus.setTitleColor(color, for: .normal)
    }
    @objc func btnPlusAction(sender: UIButton) {
        value += 1
        self.delegate?.quantityControll(self, didChange: value, with: sender.tag)
    }
    @objc func btnMinusAction(sender: UIButton) {
        value -= 1
        self.delegate?.quantityControll(self, didChange: value, with: sender.tag)
    }
}

extension UILabel {
    func setAnimated(text: String?, with duration: TimeInterval) {
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve,
           animations: { [weak self] in
            self?.text = text
        }, completion: nil)
    }
    var animatedText: String? {
        set {
            setAnimated(text: newValue, with: 0.25)
        } get {
            return text
        }
    }
}
