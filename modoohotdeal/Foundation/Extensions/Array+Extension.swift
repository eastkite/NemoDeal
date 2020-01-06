//
//  Array+Extension.swift
//  modoohotdeal
//
//  Created by baedy on 2019/12/26.
//  Copyright © 2019 baedy. All rights reserved.
//

import Foundation

extension Array{
    func get(_ index: Int) -> Element? {
        if 0 <= index && index < count {
            return self[index]
        } else {
            return nil
        }
    }
}
