//
//  ViewController.swift
//  CustomSliderExample
//
//  Created by Leonid Nifantyev on 10/5/18.
//  Copyright © 2018 Leonid Nifantyev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  let rangeSlider = RangeSlider(frame: CGRect.zero)
  @IBOutlet private weak var leftLabel: UILabel!
  @IBOutlet private weak var middleLabel: UILabel!
  @IBOutlet private weak var rightLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    rangeSlider.backgroundColor = .clear
    
    rangeSlider.setupLimits(minimumValue: 0, maximumValue: 100)
    rangeSlider.setupSliderForCurrent(lowerValue: 4, upperValue: 60)
    
    rangeSlider.setupLimitsLowerThumb(minimumValue: 10, maximumValue: 50)
    rangeSlider.setupLimitsUpperThumb(minimumValue: 60, maximumValue: 80)
    
    rangeSlider.eventHandler = { event in
      switch event {
      case let .leftUpdate(value):
        self.leftLabel.text = String(format: "%.0f", value)
      case let .rightUpdate(value):
        self.rightLabel.text = String(format: "%.0f", value)
      case let .midUpdate(value):
        self.middleLabel.text = String(format: "%.0f", value)
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

