//
//  Configuration.swift
//  modoohotdeal
//
//  Created by baedy on 2019/12/20.
//  Copyright © 2019 baedy. All rights reserved.
//

import Foundation


struct Configuration {
    let serviceApiServer    : String
}

extension Configuration{
    static let current: Configuration = .production
    
    private static let dev = Configuration (
        serviceApiServer: ApiServer.dev
    )
    
    private static let staging = Configuration (
        serviceApiServer: ApiServer.staging
    )
    
    private static let production = Configuration(
        serviceApiServer: ApiServer.production
    )
}

