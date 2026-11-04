//
//  HealthSync.swift
//  kawaii_taiju_kanri
//
//  ヘルスケアとの同期（体重だけ）。体重計アプリの記録を読みこみ、ここでの記録を書きこむ。
//  広告（AdMob）にはヘルスケアのデータを渡さない（App Store の審査ガイドライン 5.1.3）。
//
//  いまの提出には入れていない（コンパイル条件 HEALTH_SYNC を定義していないので、ビルドに入らない）。
//  iCloud バックアップと併存させると、ガイドライン 5.1.3 に触れるおそれがあるため。もどし方は CLAUDE.md。
//

#if HEALTH_SYNC
import Foundation
import HealthKit

enum HealthSync {
    private static let store = HKHealthStore()
    private static let bodyMass = HKQuantityType(.bodyMass)

    static var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    /// 許可をたずねる（すでに決まっていればダイアログは出ない）。
    /// iOS は「読みこみ」を許可されたかどうかを教えないので、ここでは、たずねられたかだけを返す
    static func requestAuthorization() async -> Bool {
        guard isAvailable else { return false }
        do {
            try await store.requestAuthorization(toShare: [bodyMass], read: [bodyMass])
            return true
        } catch {
            return false
        }
    }

    /// いちばん新しい体重（kg）。記録がないとき・読みこみを許可されていないときは nil
    static func latestWeight() async -> Double? {
        guard isAvailable else { return nil }
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.quantitySample(type: bodyMass)],
            sortDescriptors: [SortDescriptor(\.startDate, order: .reverse)],
            limit: 1
        )
        let samples = try? await descriptor.result(for: store)
        return samples?.first?.quantity.doubleValue(for: .gramUnit(with: .kilo))
    }

    /// その日の記録を書きこむ。同じ日を直したときは、同じ印の前の記録と置きかわる
    static func write(date: Date, weight: Double) async {
        guard isAvailable, store.authorizationStatus(for: bodyMass) == .sharingAuthorized else { return }
        let at = date == .today ? Date() : date.addingTimeInterval(12 * 3600)
        let sample = HKQuantitySample(
            type: bodyMass,
            quantity: HKQuantity(unit: .gramUnit(with: .kilo), doubleValue: weight),
            start: at, end: at,
            metadata: [
                HKMetadataKeySyncIdentifier: syncID(date),
                HKMetadataKeySyncVersion: Int(Date().timeIntervalSince1970),
            ]
        )
        try? await store.save(sample)
    }

    /// この日にこのアプリが書きこんだ記録を消す
    static func delete(_ date: Date) async {
        guard isAvailable, store.authorizationStatus(for: bodyMass) == .sharingAuthorized else { return }
        let predicate = HKQuery.predicateForObjects(withMetadataKey: HKMetadataKeySyncIdentifier, allowedValues: [syncID(date)])
        _ = try? await store.deleteObjects(of: bodyMass, predicate: predicate)
    }

    private static func syncID(_ date: Date) -> String {
        let c = Calendar.app.dateComponents([.year, .month, .day], from: date)
        return String(format: "taikan-weight-%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }
}
#endif
