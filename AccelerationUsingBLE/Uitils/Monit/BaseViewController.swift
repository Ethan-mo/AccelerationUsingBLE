//
//  BaseViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 4..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import FirebaseAnalytics

enum ViewCategory: String {
    case none = "none"
    case registerSensor = "registerSensor"
}

class BaseViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var scTouchView: UIScrollView?
    
    var screenType: SCREEN_TYPE { get { return .none } }
    var m_category: ViewCategory = .none
    var isUpdateView: Bool = true
    var isKeyboardFrameUp: Bool = false
    var m_isStatusHidden = false
    var statusHidden: Bool {
        get {
            return m_isStatusHidden
        }
        set {
            m_isStatusHidden = newValue
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNaviView(view: self.view)
        
        if (isKeyboardFrameUp) {
            NotificationCenter.default.addObserver(self, selector:
                #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide,
                                                 object: nil)
            NotificationCenter.default.addObserver(self, selector:
                #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow,
                                                 object: nil)
            
            if let _scTouchView = scTouchView {
                let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(touchScroll))
                singleTapGestureRecognizer.numberOfTapsRequired = 1
                singleTapGestureRecognizer.isEnabled = true
                singleTapGestureRecognizer.cancelsTouchesInView = false
                _scTouchView.addGestureRecognizer(singleTapGestureRecognizer)
            }
        }
    }

    func setCustomNaviView(view: UIView) {
        for item in view.subviews as [UIView] {
            if let _item = item as? CustomNaviView {
                _item.setInit()
                break
            } else {
                setCustomNaviView(view: item)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Debug.print("[UI][\(self.classNameToString()).ViewWillAppear()]")
//        ScreenAnalyticsManager.instance.setScreen(screenType: screenType)
        
//        if (Config.channel == .goodmonit) {
//            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
//                "screen_num": screenType.rawValue])
//        }
//
//        Analytics.setUserProperty(food, forName: "favorite_food")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func touchScroll(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if (isKeyboardFrameUp) {
            textField.resignFirstResponder()
        }
        return false
    }
    
    @objc func keyboardWillShow(_ sender:Notification){
        self.view.frame.origin.y = -150
    }
    
    @objc func keyboardWillHide(_ sender:Notification){
        self.view.frame.origin.y = 0
    }
    
    override var prefersStatusBarHidden: Bool {
        return m_isStatusHidden
    }

    func reloadInfo() {
    }
}
