//
//  Localized.swift
//  Monit
//
//  Created by 맥 on 2017. 8. 24..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        if (Config.channel == .goodmonit || Config.channel == .kc || Config.channel == .kao) {
            return NSLocalizedString(self, tableName: "Localizable", comment: "")
        } else { // 국내 고정
            let path = Bundle.main.path(forResource: "ko", ofType: "lproj")!
            let bundle = Bundle(path: path)!
            return NSLocalizedString(self, bundle: bundle, comment: "")
        }
    }
    
    func localizedWithComment(comment: String) -> String {
        return NSLocalizedString(self, tableName: "Localizable", comment: comment)
    }
}
