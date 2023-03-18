//
//  Utility.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 20..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class CircleSlider: UIView {

    fileprivate var drawn_circle: UIBezierPath!
    var circle_color = UIColor.red
    
    func makeSlider(amount: Float, width:CGFloat, diameter:CGFloat, color: UIColor) {
        self.backgroundColor = UIColor.white.withAlphaComponent(0.0)
        self.circle_color = color

        let _diameter = diameter - width
        let _startAngle: CGFloat = CGFloat(-1 * Double.pi * 0.5)
        let _angle: CGFloat = CGFloat((Double.pi * 2) * Double(amount)) + _startAngle
        let _circle_center = CGPoint(x: diameter / 2, y: diameter / 2)
        
        drawn_circle = UIBezierPath(arcCenter: _circle_center, radius: (_diameter / 2), startAngle: _startAngle, endAngle: _angle, clockwise: true)
        drawn_circle.lineWidth = width
  
        self.setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.clear(self.bounds)
        
        circle_color.setStroke()
        drawn_circle.stroke()
    }
}


