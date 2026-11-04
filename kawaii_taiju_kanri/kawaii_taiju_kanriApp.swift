//
//  kawaii_taiju_kanriApp.swift
//  kawaii_taiju_kanri
//
//  Created by 津田準 on 2026/10/28.
//

import Combine
import SwiftUI

@main
struct kawaii_taiju_kanriApp: App {
    @StateObject private var store = WeightStore.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                // 開いたまま日付が変わったら、きょうの表示に切りかえる
                .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged).receive(on: RunLoop.main)) { _ in
                    store.didBecomeActive()
                }
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active: store.didBecomeActive()
            case .background: store.saveNow()
            default: break
            }
        }
    }
}
