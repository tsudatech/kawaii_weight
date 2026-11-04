//
//  KawaiiWidgetBundle.swift
//  KawaiiWidget
//

import SwiftUI
import WidgetKit

@main
struct KawaiiWidgetBundle: WidgetBundle {
    var body: some Widget {
        KawaiiWidget()
        LockFaceWidget()
        LockAverageWidget()
        LockGoalWidget()
        RecordControl()
    }
}
