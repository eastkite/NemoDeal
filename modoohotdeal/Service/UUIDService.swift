//
//  UUIDService.swift
//  modoohotdeal
//
//  Created by baedy on 2019/12/30.
//  Copyright © 2019 baedy. All rights reserved.
//

import KeychainSwift

struct UUIDService {
    
    static let `default` = UUIDService()
    
    private let key = "UUID"
    private let keychain = KeychainSwift()
    
    /// UUID를 나타냅니다.
    ///
    /// - Returns: UUID 문자열
    var uuid: String {
        guard let uuid = keychain.get(key) else {
            let newUUID = UUID().uuidString
            keychain.set(newUUID, forKey: key, withAccess: .accessibleWhenPasscodeSetThisDeviceOnly)
            return newUUID
        }
        return uuid
    }
    
    /// 현재 UUID를 초기화하고 새로 생성합니다.
    ///
    /// - Returns: 새로운 UUID 문자열
    func renew() -> String {
        keychain.delete(key)
        return uuid
    }
}
