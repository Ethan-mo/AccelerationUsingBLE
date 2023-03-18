//
//  BaseUIView.swift
//  Monit
//
//  Created by john.lee on 2020/07/23.
//  Copyright © 2020 맥. All rights reserved.
//

import UIKit

class BaseUIView: UIView, UITextFieldDelegate {
    var isKeyboardFrameUp: Bool = false
    
    func setInit() {
        if (isKeyboardFrameUp) {
            NotificationCenter.default.addObserver(self, selector:
                #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide,
                                                 object: nil)
            NotificationCenter.default.addObserver(self, selector:
                #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow,
                                                 object: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }
    
    @objc func keyboardWillShow(_ sender:Notification){
        frame.origin.y = -150
    }
    
    @objc func keyboardWillHide(_ sender:Notification){
        frame.origin.y = 0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        if (isKeyboardFrameUp) {
            textField.resignFirstResponder()
        }
        return false
    }
}
