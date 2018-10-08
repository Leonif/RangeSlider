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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rangeSlider.backgroundColor = .clear
        
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

