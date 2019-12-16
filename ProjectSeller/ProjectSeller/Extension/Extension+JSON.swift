//
//  Extension+JSON.swift
//  kimjongchan
//
//  Created by Jaycee on 2019/12/14.
//  Copyright © 2019 Jaycee. All rights reserved.
//

import SwiftyJSON

extension JSON {
    mutating func merge(other: JSON) {
        if self.type == other.type {
            switch self.type {
                case .dictionary:
                    for (key, _) in other {
                        self[key].merge(other: other[key])
                    }
                case .array:
                    self = JSON(self.arrayValue + other.arrayValue)
                default:
                    self = other
            }
        } else {
            self = other
        }
    }

    func merged(other: JSON) -> JSON {
        var merged = self
        merged.merge(other: other)
        return merged
    }
}
