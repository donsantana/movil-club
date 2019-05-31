//
//  UITextfield.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/4/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    func setBottomBorder(borderColor: UIColor) {
        self.borderStyle = UITextField.BorderStyle.none
        self.backgroundColor = UIColor.clear
        let width = 1.0
        let borderLine = UIView()
        borderLine.frame = CGRect(x: 0, y: Double(self.frame.height) - width, width: Double(self.frame.width), height: width)
        borderLine.backgroundColor = borderColor
        self.addSubview(borderLine)
    }
}
