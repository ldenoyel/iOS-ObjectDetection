//
//  Helpers.swift
//  yolov3
//
//  Created by Alexander on 10/07/2019.
//  Copyright © 2019 Alexander. All rights reserved.
//

import Foundation
import UIKit

let labels = ["Porte avant", "Jante", "Dommage"]

struct ColorPallete {
  static let shared = ColorPallete()
  let colors: [CGColor]
  init() {
    colors = [
      ColorPallete.rgba(23,187,185,1),
      ColorPallete.rgba(156,39,176,1),
      ColorPallete.rgba(193,20,20,1),
      ColorPallete.rgba(0,150,136,1),
    ]
  }
  
  private static func rgba(_ red: CGFloat, _ green: CGFloat,
                           _ blue: CGFloat, _ alpha: CGFloat) -> CGColor {
    return UIColor(red: red / 255.0, green: green / 255.0,
                   blue: blue / 255.0, alpha: alpha).cgColor
  }
}

let anchors1_tiny: [Float] = [81,82 , 135,169,  344,319]
let anchors2_tiny: [Float] = [10,14,  23,27,  37,58]

let tiny_anchors = [
  "output1": anchors1_tiny,
  "output2": anchors2_tiny
]

let anchors1: [Float] = [116,90,  156,198,  373,326]
let anchors2: [Float] = [30,61,  62,45,  59,119]
let anchors3: [Float] = [10,13,  16,30,  33,23]

let anchors_416 = [
  "output1": anchors1,
  "output2": anchors2,
  "output3": anchors3
]
