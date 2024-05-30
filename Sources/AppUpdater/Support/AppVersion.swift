//
//  Created by Nico Verbruggen on 26/05/2024.
//  Copyright © 2024 Nico Verbruggen. All rights reserved.
//

import Foundation

class AppVersion: Comparable {
    var version: String
    var build: Int?
    var suffix: String?

    init(version: String, build: String?, suffix: String? = nil) {
        self.version = version
        self.build = build == nil ? nil : Int(build!)
        self.suffix = suffix
    }

    public static func from(_ string: String) -> AppVersion? {
        do {
            let regex = try NSRegularExpression(
                pattern: #"(?<version>(\d+)[.](\d+)([.](\d+))?)(-(?<suffix>[a-z]+)){0,1}((,|_)(?<build>\d+)){0,1}"#,
                options: []
            )

            let match = regex.matches(
                in: string,
                options: [],
                range: NSRange(location: 0, length: string.count)
            ).first

            guard let match = match else {
                return nil
            }

            var version: String = ""
            var build: String?
            var suffix: String?

            if let versionRange = Range(match.range(withName: "version"), in: string) {
                version = String(string[versionRange])
            }

            if let buildRange = Range(match.range(withName: "build"), in: string) {
                build = String(string[buildRange])
            }

            if let suffixRange = Range(match.range(withName: "suffix"), in: string) {
                suffix = String(string[suffixRange])
            }

            return AppVersion(
                version: version,
                build: build,
                suffix: suffix
            )
        } catch {
            return nil
        }
    }

    public static func fromCurrentVersion() -> AppVersion {
        return AppVersion.from("\(Executable.shortVersion)_\(Executable.bundleVersion)")!
    }

    public var tagged: String {
        if version.suffix(2) == ".0" && version.count > 3 {
            return String(version.dropLast(2))
        }

        return version
    }

    public var computerReadable: String {
        return "\(version)_\(build ?? 0)"
    }

    public var humanReadable: String {
        return "\(version) (\(build ?? 0))"
    }

    // MARK: - Comparable Protocol

    static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        if lhs.version < rhs.version {
            return true
        }

        return lhs.build ?? 0 < rhs.build ?? 0
    }

    static func == (lhs: AppVersion, rhs: AppVersion) -> Bool {
        lhs.version == rhs.version
        && lhs.build == rhs.build
    }
}

extension String {

    static func ==(lhs: String, rhs: String) -> Bool {
        return lhs.compare(rhs, options: .numeric) == .orderedSame
    }

    static func <(lhs: String, rhs: String) -> Bool {
        return lhs.compare(rhs, options: .numeric) == .orderedAscending
    }

    static func <=(lhs: String, rhs: String) -> Bool {
        return lhs.compare(rhs, options: .numeric) == .orderedAscending || lhs.compare(rhs, options: .numeric) == .orderedSame
    }

    static func >(lhs: String, rhs: String) -> Bool {
        return lhs.compare(rhs, options: .numeric) == .orderedDescending
    }

    static func >=(lhs: String, rhs: String) -> Bool {
        return lhs.compare(rhs, options: .numeric) == .orderedDescending || lhs.compare(rhs, options: .numeric) == .orderedSame
    }

}
