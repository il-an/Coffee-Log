//
//  Components.swift
//  Coffee Log
//

import SwiftUI

/// Wraps its subviews onto multiple lines, used for flavor tag chips.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(in: proposal.width ?? .infinity, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(in: bounds.width, subviews: subviews)
        for (index, origin) in result.origins.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + origin.x, y: bounds.minY + origin.y), proposal: .unspecified)
        }
    }

    private func arrange(in width: CGFloat, subviews: Subviews) -> (size: CGSize, origins: [CGPoint]) {
        var origins: [CGPoint] = []
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0, maxWidth: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + size.width > width {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            origins.append(CGPoint(x: x, y: y))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            maxWidth = max(maxWidth, x - spacing)
        }
        return (CGSize(width: maxWidth, height: y + rowHeight), origins)
    }
}

/// A selectable capsule used for flavor tags.
struct TagChip: View {
    let title: String
    let isSelected: Bool
    var action: (() -> Void)?

    var body: some View {
        let label = Text(title)
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .foregroundStyle(isSelected ? Color.white : Color.accentColor)
            .background(isSelected ? Color.accentColor : Color.clear, in: Capsule())
            .overlay(Capsule().stroke(Color.accentColor))
        if let action {
            Button(action: action) { label }.buttonStyle(.plain)
        } else {
            label
        }
    }
}

struct LabeledValue: View {
    let title: LocalizedStringKey
    let value: String

    init(_ title: LocalizedStringKey, _ value: String) {
        self.title = title
        self.value = value
    }

    var body: some View {
        LabeledContent(title) {
            Text(value).multilineTextAlignment(.trailing)
        }
    }
}

extension View {
    /// Decimal keyboard on iOS; no-op on macOS.
    func decimalKeyboard() -> some View {
        #if os(iOS)
        self.keyboardType(.decimalPad)
        #else
        self
        #endif
    }

    func integerKeyboard() -> some View {
        #if os(iOS)
        self.keyboardType(.numberPad)
        #else
        self
        #endif
    }

    func inlineNavigationTitle() -> some View {
        #if os(iOS)
        self.navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }
}

extension Double {
    var ratingText: String { formatted(.number.precision(.fractionLength(1))) + "/5" }
}

/// One tasting in a list: coffee name, brew method, rating and date.
struct TastingRow: View {
    let tasting: Tasting
    var showsCoffeeName = true

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(showsCoffeeName ? (tasting.coffeeBean?.name ?? "Unknown coffee") : tasting.timestamp.formatted(date: .abbreviated, time: .omitted))
                    .font(.headline)
                Spacer()
                Label(tasting.rating.ratingText, systemImage: "star.fill")
                    .font(.subheadline)
                    .foregroundStyle(.orange)
            }
            if let method = tasting.brewLog?.brewMethod?.name {
                Text(method).font(.subheadline).foregroundStyle(.secondary)
            }
            if !(tasting.flavors ?? []).isEmpty {
                Text((tasting.flavors ?? []).map(\.name).sorted().joined(separator: ", "))
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

/// A form row with a permanent label and the example text as a placeholder,
/// so the label stays visible on iOS where a prompt would otherwise replace the title.
struct LabeledTextField: View {
    let title: LocalizedStringKey
    @Binding var text: String
    var prompt: String?
    var isValid = true

    init(_ title: LocalizedStringKey, text: Binding<String>, prompt: String? = nil, isValid: Bool = true) {
        self.title = title
        self._text = text
        self.prompt = prompt
        self.isValid = isValid
    }

    var body: some View {
        LabeledContent(title) {
            TextField(title, text: $text, prompt: prompt.map { Text($0) })
                .labelsHidden()
                .multilineTextAlignment(.trailing)
                .foregroundStyle(isValid ? Color.primary : Color.red)
        }
    }
}
