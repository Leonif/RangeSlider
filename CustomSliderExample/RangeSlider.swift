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

enum ThumbType {
  case left
  case mid
  case right
  case none
}

enum RangeSliderEvent {
  case leftUpdate(Double)
  case midUpdate(Double)
  case rightUpdate(Double)
  case maxValueReached(ThumbType)
  case minValueReached(ThumbType)
  case allInRanged(ThumbType)
}

class RangeSlider: UIControl {
  
  private var minimumValue = 0.0
  private var midValue = 0.5
  private var maximumValue = 1.0
  private var leftThumbValue = 0.0
  private var rightThumbValue = 0.9
  
  private var leftThumbMinimumValue = 0.0
  private var leftThumbMaximumValue = 1.0
  
  private var midMinimumValue = 0.0
  private var midMaximumValue = 1.0
  
  private var rightThumbMinimumValue = 0.0
  private var rightThumbMaximumValue = 1.0
  
  var eventHandler: EventHandler<RangeSliderEvent>? = nil
  
  var previousLocation = CGPoint()
  
  var trackLayer = CALayer()
  var leftThumbLayer = RangeSliderThumbLayer()
  var rightThumbLayer = RangeSliderThumbLayer()
  
  var leftTrackBack = CALayer()
  var rightTrackBack = CALayer()
  
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
    
    leftTrackBack.backgroundColor = UIColor.yellow.cgColor
    layer.addSublayer(leftTrackBack)
    
    rightTrackBack.backgroundColor = UIColor.green.cgColor
    layer.addSublayer(rightTrackBack)
    
    
    leftThumbLayer.backgroundColor = UIColor.black.cgColor
    leftThumbLayer.contentsScale = UIScreen.main.scale
    leftThumbLayer.rangeSlider = self
    layer.addSublayer(leftThumbLayer)
    
    rightThumbLayer.backgroundColor = UIColor.black.cgColor
    rightThumbLayer.contentsScale = UIScreen.main.scale
    rightThumbLayer.rangeSlider = self
    layer.addSublayer(rightThumbLayer)
    
    updateLayerFrames()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private func updateLayerFrames() {
    trackLayer.frame = bounds.insetBy(dx: 0, dy: bounds.height / 3)
    trackLayer.setNeedsDisplay()
    
    let leftThumbCenter = calculateLeftPositionForValue(leftThumbValue)
    
    leftThumbLayer.frame = CGRect(x: leftThumbCenter - thumbWidth / 2,
                                   y: 0.0,
                                   width: thumbWidth,
                                   height: thumbHeight)
    leftThumbLayer.setNeedsDisplay()
    
    let rightThumbCenter = calculateRightPositionForValue(rightThumbValue)
    
    rightThumbLayer.frame = CGRect(x: rightThumbCenter - thumbWidth / 2,
                                   y: 0.0,
                                   width: thumbWidth,
                                   height: thumbHeight)
    rightThumbLayer.setNeedsDisplay()
    
    updateFrameForEdges()
  }
  
  
  private func updateFrameForEdges() {
    let w1 = leftThumbLayer.frame.origin.x
    let h1 = trackLayer.frame.height
    
    leftTrackBack.frame = CGRect(x: 0,
                             y: trackLayer.frame.origin.y,
                             width: w1,
                             height: h1)
    
    leftTrackBack.setNeedsDisplay()
    
    let w2 = bounds.width - rightThumbLayer.frame.origin.x
    let h2 = trackLayer.frame.height
    
    rightTrackBack.frame = CGRect(x: rightThumbLayer.frame.origin.x,
                             y: trackLayer.frame.origin.y,
                             width: w2,
                             height: h2)
    
    rightTrackBack.setNeedsDisplay()
  }
  
  private func calculateLeftPositionForValue(_ value: Double) -> CGFloat {
    let uiDistance = bounds.width - thumbWidth
    let valueDistance = value - minimumValue
    let realDistance = maximumValue - minimumValue
    let halfOfthumb = thumbWidth / 2
    let kReal = valueDistance / realDistance
    
    return (uiDistance.double * kReal  + halfOfthumb.double).cgFloat
  }
  
  private func calculateRightPositionForValue(_ value: Double) -> CGFloat {
    let uiDistance = bounds.width.double - thumbWidth.double
    let realDistance = maximumValue - minimumValue
    let halfOfthumb = thumbWidth / 2
    
    let k = uiDistance / realDistance
    let points = value * k
    let position = uiDistance - points
    
    return position.cgFloat + halfOfthumb
  }
}

extension RangeSlider {
  func setupLimits(minimumValue: Double, maximumValue: Double) {
    self.minimumValue = minimumValue
    self.maximumValue = maximumValue
  }
  
  func setupSliderForCurrent(leftValue: Double, middleValue: Double, rightValue: Double) {
    self.leftThumbValue = leftValue
    self.midValue = middleValue
    self.rightThumbValue = rightValue
  }
  
  func setupLimitsLeftThumb(minimumValue: Double, maximumValue: Double) {
    self.leftThumbMinimumValue = minimumValue
    self.leftThumbMaximumValue = maximumValue
  }
  
  func setupLimitsMidValue(minimumValue: Double, maximumValue: Double) {
    self.midMinimumValue = minimumValue
    self.midMaximumValue = maximumValue
  }
  
  func setupLimitsRightThumb(minimumValue: Double, maximumValue: Double) {
    self.rightThumbMinimumValue = minimumValue
    self.rightThumbMaximumValue = maximumValue
  }
}

extension RangeSlider {
  func boundLeftValue(value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
    
    let leftLimit = max(lowerValue, value)
    let leftLimitRight = min(leftLimit, upperValue)
    
    return leftLimitRight
  }
  
  func boundRightValue(value: Double, leftValue: Double, rightValue: Double) -> Double {
    
    let leftLimit = min(leftValue, value)
    let leftLimitRight = max(leftLimit, rightValue)
    
    return leftLimitRight
  }
  
  // MARK: - Проверка ЛЕВОГО слайдера на допустимость значения
  func confirmLeftValue(startValue: Double, changedValue: Double) -> Double {
    
    var mutableChangedValue = changedValue
    
    // 1. Проверить нахоится ли оно в границах своего мин и максимума
    // и не заходит ли оно за другой слайдер
    
    // минимального верхнего значения
    
    let adjustRightMax = maximumValue - rightThumbValue
    
    let maxValue = min(adjustRightMax, leftThumbMaximumValue)
    
    // подгонка значения
    mutableChangedValue = boundLeftValue(value: mutableChangedValue,
                                   toLowerValue: leftThumbMinimumValue,
                                   upperValue: maxValue)
    
    // 2. Вычисление среднего показателя
    let mV = calculateMidValue(leftThumbValue: mutableChangedValue, rightThumbValue: rightThumbValue)
    
    // 3. Проверка что средний показатель в пределах своих мин и макс
    
    if isPossible(midValue: mV) {
      return mutableChangedValue
    } else {
      return startValue
    }
  }
  
  func isPossible(midValue: Double) -> Bool {
      switch midValue {
      case let x where x < midMinimumValue:
        eventHandler?(.minValueReached(.mid))
        return false
      case let x where x > midMaximumValue:
        eventHandler?(.maxValueReached(.mid))
        return false
      default:
        return true
      }
  }
  
  
  // MARK: - Проверка ПРАВОГО слайдера на допустимость значения
  func confirmRightValue(startValue: Double, changedValue: Double) -> Double {
    
    var mutableChangedValue = changedValue
    
    // 1. Проверить нахоится ли оно в границах своего мин и максимума
    // и не заходит ли оно за другой слайдер
    
    
    let adjustRightMax = maximumValue - rightThumbValue
    
    // максимального нижнего значения
//    let minValue = max(leftThumbValue, rightThumbMinimumValue)
    
    // подгонка значения
    mutableChangedValue = boundRightValue(value: mutableChangedValue,
                                          leftValue: rightThumbMaximumValue,
                                     rightValue: rightThumbMinimumValue)
    
    // 2. Вычисление среднего показателя
    // 2.1. Развернуть правый слайдер
    let mV = calculateMidValue(leftThumbValue: leftThumbValue, rightThumbValue: mutableChangedValue)
    
    // 3. Проверка что средний показатель в пределах своих мин и макс
    if isPossible(midValue: mV) {
      return mutableChangedValue
    } else {
      return startValue
    }
  }
  
  
  // MARK: - Вычисление среднего показателя
  func calculateMidValue(leftThumbValue: Double, rightThumbValue: Double) -> Double {
    // Вычисление общего диапозона
    let total = maximumValue - minimumValue

    // Вычисление остатка (среднего показателя) от двух слайдеров
    let mV = total - (leftThumbValue + rightThumbValue)
    
    return mV
  }
  
  override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    previousLocation = touch.location(in: self)
    if leftThumbLayer.frame.contains(previousLocation) {
      leftThumbLayer.highlighted = true
    } else if rightThumbLayer.frame.contains(previousLocation) {
      rightThumbLayer.highlighted = true
    }
    
    return leftThumbLayer.highlighted || rightThumbLayer.highlighted
  }
  
  override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    let location = touch.location(in: self)
    
    let deltaLocation = location.x - previousLocation.x
    let deltaValue = (maximumValue - minimumValue) * deltaLocation.double / (bounds.width - thumbWidth).double
    
    previousLocation = location
    
    if leftThumbLayer.highlighted {
      let notConfirmedValue = leftThumbValue + deltaValue
      
      leftThumbValue = confirmLeftValue(startValue: leftThumbValue, changedValue: notConfirmedValue)
      midValue = calculateMidValue(leftThumbValue: leftThumbValue, rightThumbValue: rightThumbValue)
      
      eventHandler?(.leftUpdate(leftThumbValue))
      eventHandler?(.midUpdate(midValue))

    } else if rightThumbLayer.highlighted {
      
      let notConfirmedValue = rightThumbValue - deltaValue
      rightThumbValue = confirmRightValue(startValue: rightThumbValue, changedValue: notConfirmedValue)
      midValue = calculateMidValue(leftThumbValue: leftThumbValue, rightThumbValue: rightThumbValue)

      eventHandler?(.rightUpdate(rightThumbValue))
      eventHandler?(.midUpdate(midValue))
      
      
    }
    
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    
    updateLayerFrames()
    
    CATransaction.commit()
    
    return true
  }
  
  override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
    (leftThumbLayer.highlighted,
     rightThumbLayer.highlighted) = (false, false)
    
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

