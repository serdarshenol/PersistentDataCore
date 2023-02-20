//
// Helpers.swift
// Copyright (c) 2022 Nemlig.com. All rights reserved.
//

import Combine
import Foundation

public enum DatabaseError: Swift.Error {
    case unhandledType, noEntry, missingPrimaryKey
}

public enum DatabaseConstants {
    static let Byte = 1024
    static let MegaByte = Byte * Byte
}

public typealias DBReadable = DBStorable & Decodable
public typealias DBWritable = DBStorable & Encodable

public protocol DBStorable {
    static func primaryKey() -> String?
}

/** A block called when opening a Realm for the first time during the
 life of a process to determine if it should be compacted before being
 returned to the user. It is passed the total file size (data + free space)
 and the total bytes used by data in the file. It is used whenever Realm is configured */
public enum RealmShouldCompactOnLaunch {
    public static func make(limitMB: Double, usedCoefficient: Double = 0.5) -> (Int, Int) -> Bool {
        { totalBytes, usedBytes in
            // totalBytes refers to the size of the file on disk in bytes (data + free space)
            // usedBytes refers to the number of bytes used by data in the file

            // Compact if the file is over `sizeMB` in size and less than `usedCoefficient`
            let sizeMB = limitMB * Double(DatabaseConstants.MegaByte)
            let result = (Double(totalBytes) > sizeMB) && (Double(usedBytes) / Double(totalBytes)) < usedCoefficient
            return result
        }
    }
}
