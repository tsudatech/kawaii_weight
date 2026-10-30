//
//  AdLog.swift
//  kawaii_taiju_kanri
//
//  かわいい日記（kawaiidiary）の AdLog.swift と同じもの
//

import Foundation
import OSLog

/// 広告まわりのログ。読み込みの失敗は珍しくないので、落とさず記録だけする。
enum AdLog {
    private static let logger = Logger(subsystem: "jp.jntech.kawaii-taiju-kanri", category: "ads")

    static func info(_ message: String) {
        logger.info("\(message, privacy: .public)")
    }

    static func error(_ message: String, _ error: Error) {
        logger.error("\(message): \(error.localizedDescription, privacy: .public)")
    }
}
