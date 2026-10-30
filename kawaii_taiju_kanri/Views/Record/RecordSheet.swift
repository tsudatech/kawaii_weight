//
//  RecordSheet.swift
//  kawaii_taiju_kanri
//
//  記録の入力・修正（過去日の入力・削除も）。下からせり上がるシート（.sheet）
//

import SwiftUI

struct RecordSheet: View {
    @State var date: Date

    @EnvironmentObject private var store: WeightStore

    @State private var weight: Double = 58
    @State private var face: Mood?
    @State private var faceTouched = false
    @State private var fatOn = false
    @State private var fat: Double = 28
    @State private var tags: [String] = []
    @State private var memo = ""
    @State private var deleteArmed = false
    @State private var contentHeight: CGFloat = 600
    @State private var drag: CGFloat = 0
    @FocusState private var memoFocused: Bool

    /// さかのぼれる日数
    private let maxBack = 119

    private var hasEntry: Bool { store.entries[date] != nil }
    private var ago: Int { date.days(to: .today) }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                ScrollViewReader { proxy in
                    ScrollView {
                        content
                            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { contentHeight = $0 }
                    }
                    // メモを書きはじめたら、メモ欄と保存ボタンがキーボードの上に見えるところまで送る
                    .onChange(of: memoFocused) { _, focused in
                        guard focused else { return }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            withAnimation(.cssEase(0.3)) { proxy.scrollTo(Self.saveID, anchor: .bottom) }
                        }
                    }
                    // キーボードが出たあとにも送る（出るのがおそいと、0.35 秒後の時点ではまだ出ていない）
                    .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)) { _ in
                        guard memoFocused else { return }
                        withAnimation(.cssEase(0.3)) { proxy.scrollTo(Self.saveID, anchor: .bottom) }
                    }
                }
                // いちばん上でさらに下へ引っぱったら閉じる
                .onScrollGeometryChange(for: CGFloat.self) { $0.contentOffset.y + $0.contentInsets.top } action: { _, y in
                    if y < -80 { store.editing = nil }
                }
                .scrollBounceBehavior(.always, axes: .vertical)
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
                // max-height: 88%（画面全体の高さに対して）。キーボードが出ているあいだは、その上に収める
                .frame(height: min(contentHeight, memoFocused
                    ? geo.size.height - 8
                    : (geo.size.height + geo.safeAreaInsets.top + geo.safeAreaInsets.bottom) * 0.88))
                .background(UnevenRoundedRectangle(topLeadingRadius: 30, topTrailingRadius: 30).fill(Palette.paper).ignoresSafeArea(edges: .bottom))
                .offset(y: drag)
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .onAppear(perform: load)
        .onChange(of: date) { _, _ in load() }
    }

    private var content: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                grab
                header
            }
            .contentShape(Rectangle())
            .gesture(pullDown)
            weightCard.padding(.top, 12)
            faceCard.padding(.top, 12)
            fatCard.padding(.top, 12)
            tagCard.padding(.top, 12)
            Button(hasEntry ? L("修正を保存") : L("この日をきろくする")) { save() }
                .buttonStyle(.primary)
                .padding(.top, 14)
                .padding(.bottom, memoFocused ? 28 : 0)
                .id(Self.saveID)
            if hasEntry {
                Button(deleteArmed ? L("もう一度おすと削除します") : L("この日の記録を削除")) { deleteTapped() }
                    .font(.ui(13))
                    .foregroundStyle(Palette.up)
                    .buttonStyle(.plain)
                    .padding(.vertical, 6).padding(.horizontal, 10)
                    .padding(.top, 14)
            }
        }
        .padding(.top, 10).padding(.horizontal, 18).padding(.bottom, 34)
    }

    private static let saveID = "record.save"

    /// .grab
    private var grab: some View {
        Capsule().fill(Color(hex: 0xDCCBBE))
            .frame(width: 40, height: 5)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 10)
    }

    /// つまみ・日付の行を下へ引っぱると、指について動き、離したときに十分下がっていれば閉じる
    private var pullDown: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .global)
            .onChanged { drag = max(0, $0.translation.height) }
            .onEnded { v in
                if v.translation.height > 120 || v.predictedEndTranslation.height > 300 {
                    store.editing = nil
                } else {
                    withAnimation(.slide) { drag = 0 }
                }
            }
    }

    // MARK: - 部品

    /// .shHead
    private var header: some View {
        HStack {
            Color.clear.frame(width: 32, height: 32)
            Spacer(minLength: 0)
            HStack(spacing: 8) {
                circleButton("‹", fill: Palette.blush, enabled: ago < maxBack) { date = date.adding(days: -1) }
                    .accessibilityLabel(L("前の日"))
                Text(Fmt.dayTitle(date)).font(.ui(17, .black)).foregroundStyle(Palette.ink)
                    .frame(minWidth: 120)
                circleButton("›", fill: Palette.blush, enabled: ago > 0) { date = date.adding(days: 1) }
                    .accessibilityLabel(L("次の日"))
            }
            Spacer(minLength: 0)
            circleButton("×", fill: Color(hex: 0xF3ECE6), enabled: true) { store.editing = nil }
                .accessibilityLabel(L("とじる"))
        }
    }

    private func circleButton(_ s: String, fill: Color, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(s).font(.ui(14, .black)).foregroundStyle(Palette.ink)
                .frame(width: 32, height: 32)
                .background(Circle().fill(fill))
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.3)
    }

    /// .shCard
    private func sheetCard<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) { content() }
            .card(padding: 14, radius: 22)
    }

    /// .shLbl
    private func label<Trailing: View>(_ title: String, @ViewBuilder trailing: () -> Trailing) -> some View {
        HStack {
            Text(title)
            Spacer(minLength: 4)
            trailing()
        }
        .font(.ui(13, .black))
        .foregroundStyle(Palette.ink)
        .padding(.bottom, 8)
    }

    private var weightCard: some View {
        sheetCard {
            label(L("体重")) {
                Text(ago == 0 ? L("きょう") : hasEntry ? L("記録ずみ・修正できるよ") : L("まだ記録がない日"))
                    .font(.ui(12, .black)).foregroundStyle(Palette.inkSoft)
            }
            WeightStepper(value: $weight)
        }
    }

    private var faceCard: some View {
        let auto = hasEntry ? store.judge(date)?.mood : nil
        return sheetCard {
            label(L("この日のきぶん")) {
                Text(hasEntry ? L("えらびなおせるよ") : L("えらばなければ体重から自動できまるよ"))
                    .font(.ui(11, .black)).foregroundStyle(Palette.inkSoft)
            }
            FacePicker(selected: face, auto: auto) { m in
                // 未記録の日は、もう一度押すと選択を外せる
                face = (!hasEntry && face == m) ? nil : m
                faceTouched = true
            }
            .id(date)
        }
    }

    private var fatCard: some View {
        sheetCard {
            label(L("体脂肪率もきろく")) { CSSSwitch(isOn: $fatOn, label: L("体脂肪率もきろく")) }
            HStack(spacing: 10) {
                RoundStepButton.mini("−") { fat = max(3, ((fat - 0.1) * 10).rounded() / 10) }
                    .accessibilityLabel(L("0.1% 減らす"))
                Text("\(Text(Fmt.kg(fat)).font(.num(28)))\(Text("%").font(.num(14)))")
                    .foregroundStyle(Palette.ink)
                    .frame(maxWidth: .infinity)
                RoundStepButton.mini("+") { fat = min(70, ((fat + 0.1) * 10).rounded() / 10) }
                    .accessibilityLabel(L("0.1% 増やす"))
            }
            .opacity(fatOn ? 1 : 0.3)
            .disabled(!fatOn)
        }
    }

    private var tagCard: some View {
        sheetCard {
            label(L("タグ")) { EmptyView() }
            TagPicker(selected: $tags)
            label(L("ひとことメモ")) { EmptyView() }.padding(.top, 14)
            MemoField(text: $memo, focused: $memoFocused)
        }
    }

    // MARK: - 処理

    private func load() {
        deleteArmed = false
        faceTouched = false
        let e = store.entries[date]
        let before = store.sortedDates.last { $0 < date }
        weight = e?.weight ?? before.flatMap { store.entries[$0]?.weight } ?? store.lastWeightOrDefault
        let lastFat = store.sortedDates.reversed().lazy.compactMap { store.entries[$0]?.fat }.first
        fatOn = e?.fat != nil || (e == nil && lastFat != nil)
        fat = e?.fat ?? lastFat ?? 28
        tags = e?.tags ?? []
        memo = e?.memo ?? ""
        face = e.map { $0.face ?? store.judge(date)?.mood } ?? nil
    }

    private func save() {
        let trimmed = memo.trimmingCharacters(in: .whitespacesAndNewlines)
        // えらび直したときはその顔を、触っていなければ前の選択をそのまま残す
        let pickedFace = faceTouched ? face : store.entries[date]?.face
        store.save(WeightEntry(
            date: date,
            weight: weight,
            fat: fatOn ? fat : nil,
            tags: tags,
            memo: trimmed.isEmpty ? nil : trimmed,
            face: pickedFace
        ))
        store.editing = nil
    }

    private func deleteTapped() {
        if !deleteArmed {
            deleteArmed = true
            return
        }
        store.delete(date)
        store.editing = nil
    }
}
