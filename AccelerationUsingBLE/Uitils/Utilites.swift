//
//  Utilites.swift
//  AccelerationUsingBLE
//
//  Created by 모상현 on 2023/02/08.
//

import UIKit

func customAlert(view:UIViewController, mainTitle:String, mainMessage:String, completion:@escaping(UIAlertAction) -> Void) {
    let alert = UIAlertController(title: mainTitle, message: mainMessage, preferredStyle: .alert)
    let action = UIAlertAction(title: "확인", style: .cancel, handler: completion)
    alert.addAction(action)
    view.present(alert, animated: true)
}
