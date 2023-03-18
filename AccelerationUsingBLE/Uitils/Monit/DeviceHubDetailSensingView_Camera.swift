//
//  UserSetupNoticeController.swift
//  Monit
//
//  Created by john.lee on 2019. 3. 13..
//  Copyright © 2019년 맥. All rights reserved.
//

import UIKit
import MobileVLCKit

//extension PlaybackViewController: VLCMediaPlayerDelegate {
//
//    func mediaPlayerStateChanged(_ aNotification: Notification!) {
//        if mediaPlayer.state == .stopped {
//            self.dismiss(animated: true, completion: nil)
//        }
//    }
//}

class DeviceHubDetailSensingView_Camera: UIView, VLCMediaPlayerDelegate {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var webInnerView: UIView!
    
    var m_popup: CustomWebView? // ip camera
    var m_url: String?
    var m_naviTitle: String?
    
    var mediaPlayer = VLCMediaPlayer() // vlc camera
    
    var isVLCCaemra: Bool = false
    var camera_ip: String {
        get { return DataManager.instance.m_configData.getLocalStringAes256(name: "camera_ip") }
        set { DataManager.instance.m_configData.setLocalAes256(name: "camera_ip", value: newValue.description) }
    }
    
    func setInit(url: String?, naviTitle: String?) {
        m_url = url
        m_naviTitle = naviTitle
        
        lblNaviTitle.text = m_naviTitle ?? ""
        // "rtsp://10.4.10.73/live/thirdstream"
        if (isVLCCaemra) {
            let media = VLCMedia(url: URL(string:"rtsp://\(camera_ip)/live/thirdstream")!)
               mediaPlayer.media = media
               mediaPlayer.delegate = self
            mediaPlayer.drawable = webInnerView
               mediaPlayer.play()
        } else {
            if (Utility.currentReachabilityStatus != .notReachable) {
                if (m_popup == nil) {
                    m_popup = .fromNib()
                    m_popup!.frame = webInnerView.bounds
                    webInnerView.addSubview(m_popup!)
                }

                if let _url = m_url {
                    m_popup!.openUrl(url: _url)
                }
            }
        }
    }
    
    func closeWebView() {
        if (isVLCCaemra) {
            mediaPlayer.stop()
        } else {
            m_popup?.webView.removeFromSuperview()
            m_popup?.webView = nil
            m_popup?.removeFromSuperview()
            m_popup = nil
            m_url = nil
        }
    }
}
