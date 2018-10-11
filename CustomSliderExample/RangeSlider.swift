//
//  RangeSlider.swift
//  CustomSliderExample
//
//  Created by Leonid Nifantyev on 10/5/18.
//  Copyright © 2018 Leonid Nifantyev. All rights reserved.
//

import UIKit
import QuartzCore

typealias EventHandler<T> = (T) -> Void

enum RangeSliderEvent {
  case leftUpdate(Double)
  case midUpdate(Double)
  case rightUpdate(Double)
}


class RangeSlider: UIControl {
  
  private var minimumValue = 0.0
  private var maximumValue = 1.0
  private var lowerValue = 0.0
  private var upperValue = 0.9
  
  private var lowerMinimumValue = 0.0
  private var lowerMaximumValue = 1.0
  
  private var upperMinimumValue = 0.0
  private var upperMaximumValue = 1.0
  
  var eventHandler: EventHandler<RangeSliderEvent>? = nil
  
  var previousLocation = CGPoint()
  
  var trackLayer = CALayer()
  var lowerThumbLayer = RangeSliderThumbLayer()
  var upperThumbLayer = RangeSliderThumbLayer()
  
  var lowerBack = CALayer()
  var upperBack = CALayer()
  
  var thumbWidth: CGFloat {
    return bounds.height / 2
  }
  
  var thumbHeight: CGFloat {
    return bounds.height
  }
  
  override var frame: CGRect {
    didSet {
      updateLayerFrames()
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    trackLayer.backgroundColor = UIColor.blue.cgColor
    trackLayer.contentsScale = UIScreen.main.scale
    layer.addSublayer(trackLayer)
    
    lowerBack.backgroundColor = UIColor.yellow.cgColor
    layer.addSublayer(lowerBack)
    
    upperBack.backgroundColor = UIColor.green.cgColor
    layer.addSublayer(upperBack)
    
    
    lowerThumbLayer.backgroundColor = UIColor.black.cgColor
    lowerThumbLayer.contentsScale = UIScreen.main.scale
    lowerThumbLayer.rangeSlider = self
    layer.addSublayer(lowerThumbLayer)
    
    upperThumbLayer.backgroundColor = UIColor.black.cgColor
    upperThumbLayer.contentsScale = UIScreen.main.scale
    upperThumbLayer.rangeSlider = self
    layer.addSublayer(upperThumbLayer)
    
    updateLayerFrames()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private func updateLayerFrames() {
    trackLayer.frame = bounds.insetBy(dx: 0, dy: bounds.height / 3)
    trackLayer.setNeedsDisplay()
    
    let lowerThumbCenter = calculatePositionForValue(lowerValue)
    
    lowerThumbLayer.frame = CGRect(x: lowerThumbCenter - thumbWidth / 2,
                                   y: 0.0,
                                   width: thumbWidth,
                                   height: thumbHeight)
    lowerThumbLayer.setNeedsDisplay()
    
    let upperThumbCenter = calculatePositionForValue(upperValue)
    
    upperThumbLayer.frame = CGRect(x: upperThumbCenter - thumbWidth / 2,
                                   y: 0.0,
                                   width: thumbWidth,
                                   height: thumbHeight)
    upperThumbLayer.setNeedsDisplay()
    
    updateFrameForEdges()
  }
  
  
  private func updateFrameForEdges() {
    let w1 = lowerThumbLayer.frame.origin.x
    let h1 = trackLayer.frame.height
    
    lowerBack.frame = CGRect(x: 0,
                             y: trackLayer.frame.origin.y,
                             width: w1,
                             height: h1)
    
    lowerBack.setNeedsDisplay()
    
    let w2 = bounds.width - upperThumbLayer.frame.origin.x
    let h2 = trackLayer.frame.height
    
    upperBack.frame = CGRect(x: upperThumbLayer.frame.origin.x,
                             y: trackLayer.frame.origin.y,
                             width: w2,
                             height: h2)
    
    upperBack.setNeedsDisplay()
  }
  
  
  private func calculatePositionForValue(_ value: Double) -> CGFloat {
    let c1 = bounds.width - thumbWidth
    let delataMinAndCurrentValue = value - minimumValue
    let deltaAvalableValues = maximumValue - minimumValue
    let halfOfthumb = thumbWidth / 2
    
    return (c1.double * delataMinAndCurrentValue / deltaAvalableValues + halfOfthumb.double).cgFloat
  }
}



extension RangeSlider {
  func setupLimits(minimumValue: Double, maximumValue: Double) {
    self.minimumValue = minimumValue
    self.maximumValue = maximumValue
  }
  
  func setupSliderForCurrent(lowerValue: Double, upperValue: Double) {
    self.lowerValue = lowerValue
    self.upperValue = upperValue
  }
  
  func setupLimitsLowerThumb(minimumValue: Double, maximumValue: Double) {
    self.lowerMinimumValue = minimumValue
    self.lowerMaximumValue = maximumValue
  }
  
  func setupLimitsUpperThumb(minimumValue: Double, maximumValue: Double) {
    self.upperMinimumValue = minimumValue
    self.upperMaximumValue = maximumValue
  }
}

extension RangeSlider {
  func boundValue(value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
    return min(max(value, lowerValue), upperValue)
  }
  
  override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    previousLocation = touch.location(in: self)
    if lowerThumbLayer.frame.contains(previousLocation) {
      lowerThumbLayer.highlighted = true
    } else if upperThumbLayer.frame.contains(previousLocation) {
      upperThumbLayer.highlighted = true
    }
    
    return lowerThumbLayer.highlighted || upperThumbLayer.highlighted
  }
  
  override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    let location = touch.location(in: self)
    
    let deltaLocation = location.x - previousLocation.x
    let deltaValue = (maximumValue - minimumValue) * deltaLocation.double / (bounds.width - thumbWidth).double
    
    previousLocation = location
    
    if lowerThumbLayer.highlighted {
      lowerValue += deltaValue
      let maxValue = min(upperValue, lowerMaximumValue)
      lowerValue = boundValue(value: lowerValue,
                              toLowerValue: lowerMinimumValue,
                              upperValue: maxValue)
      
      eventHandler?(.leftUpdate(lowerValue))
      
      let mdValue = maximumValue - lowerValue - (maximumValue - upperValue)
      
      eventHandler?(.midUpdate(mdValue))
    } else if upperThumbLayer.highlighted {
      upperValue += deltaValue
      let minValue = max(lowerValue, upperMinimumValue)
      
      upperValue = boundValue(value: upperValue,
                              toLowerValue: minValue,
                              upperValue: upperMaximumValue)
      
      eventHandler?(.rightUpdate(upperValue))
      let mdValue = maximumValue - lowerValue - (maximumValue - upperValue)
      eventHandler?(.midUpdate(mdValue))
    }
    
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    
    updateLayerFrames()
    
    CATransaction.commit()
    
    return true
  }
  
  override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
    (lowerThumbLayer.highlighted,
     upperThumbLayer.highlighted) = (false, false)
    
  }
}

extension CGFloat {
  var double: Double {
    return Double(self)
  }
}

extension Double {
  var cgFloat: CGFloat {
    return CGFloat(self)
  }
}

