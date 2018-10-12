//
//  ViewController.swift
//  CustomSliderExample
//
//  Created by Leonid Nifantyev on 10/5/18.
//  Copyright © 2018 Leonid Nifantyev. All rights reserved.
//

import UIKit


struct SliderState {
  var min: Double
  var max: Double
  
  var leftThumb: (min: Double, current: Double, max: Double)
  var midThumb: (min: Double, current: Double, max: Double)
  var rightThumb: (max: Double, current: Double, min: Double)
  
}



class ViewController: UIViewController {
  
  let rangeSlider = RangeSlider(frame: CGRect.zero)
  @IBOutlet private weak var leftLabel: UILabel!
  @IBOutlet private weak var middleLabel: UILabel!
  @IBOutlet private weak var rightLabel: UILabel!
  
  @IBOutlet private weak var messageLabel: UILabel!
  
  var min: Double = 0
  var max: Double = 100
  
  var state: SliderState = SliderState(min: 0, max: 100,
                                       leftThumb: (0, 0, 100),
                                       midThumb: (0, 40, 100),
                                       rightThumb: (100, 60, 0))
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    rangeSlider.backgroundColor = .clear
    
    rangeSlider.setupLimits(minimumValue: state.min, maximumValue: state.max)
    
    
    rangeSlider.setupSliderForCurrent(leftValue: state.leftThumb.current,
                                      middleValue: state.midThumb.current,
                                      rightValue: state.rightThumb.current)
    
    rangeSlider.setupLimitsLeftThumb(minimumValue: state.leftThumb.min,
                                      maximumValue: state.leftThumb.max)
    
    rangeSlider.setupLimitsMidValue(minimumValue: state.midThumb.min,
                                    maximumValue: state.midThumb.max)
    
    rangeSlider.setupLimitsRightThumb(minimumValue: state.rightThumb.min,
                                      maximumValue: state.rightThumb.max)
    
    
    self.leftLabel.text = String(format: "%.0f", state.leftThumb.current)
    self.middleLabel.text = String(format: "%.0f", state.midThumb.current)
    self.rightLabel.text = String(format: "%.0f", state.rightThumb.current)
    self.messageLabel.text = "No message"
    
    
    
    
    rangeSlider.eventHandler = { event in
      switch event {
      case let .leftUpdate(value):
        self.leftLabel.text = String(format: "%.0f", value)
      case let .rightUpdate(value):
        self.rightLabel.text = String(format: "%.0f", value)
      case let .midUpdate(value):
        self.middleLabel.text = String(format: "%.0f", value)
      case .maxValueReached(.mid):
        self.messageLabel.text = "Max Reached"
      case .minValueReached(.mid):
        self.messageLabel.text = "Min Reached"
      case .allInRanged(.mid):
        self.messageLabel.text = "No message"
      default:
        self.messageLabel.text = "No message"
      }
    }
    
    view.addSubview(rangeSlider)
  }
  
  override func viewDidLayoutSubviews() {
    let margin: CGFloat = 20
    let width = view.bounds.width - 2 * margin
    
    rangeSlider.frame = CGRect(x: margin,
                               y: margin + self.view.safeAreaInsets.top ,
                               width: width,
                               height: 70)
  }
}

