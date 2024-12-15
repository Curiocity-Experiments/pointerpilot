import SwiftUI

/// A reusable component for grouping controls with labels
struct ControlGroup<Control: View>: View {
    let label: String
    let value: String?
    @ViewBuilder let control: Control
    
    init(
        _ label: String,
        value: String? = nil,
        @ViewBuilder control: () -> Control
    ) {
        self.label = label
        self.value = value
        self.control = control()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.subheadline)
                Spacer()
                if let value {
                    Text(value)
                        .monospacedDigit()
                        .foregroundStyle(.blue)
                        .font(.headline)
                }
            }
            
            control
        }
    }
}

/// A reusable component for quick-select buttons
struct QuickSelectButtons: View {
    let values: [Double]
    let selectedValue: Double
    let format: String
    let action: (Double) -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(values, id: \.self) { value in
                Button(String(format: format, value)) {
                    action(value)
                }
                .buttonStyle(.bordered)
                .tint(selectedValue == value ? .blue : nil)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

/// A reusable component for displaying stats
struct StatRow: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .gridColumnAlignment(.trailing)
            Text(value)
                .monospacedDigit()
                .foregroundStyle(color)
        }
        .font(.subheadline)
    }
}

#Preview {
    VStack(spacing: 20) {
        ControlGroup("Test Control", value: "100") {
            Slider(value: .constant(0.5))
        }
        
        QuickSelectButtons(
            values: [0.5, 1.0, 2.0],
            selectedValue: 1.0,
            format: "%.1f"
        ) { value in
            print("Selected: \(value)")
        }
        
        StatRow(
            label: "Test Stat:",
            value: "42",
            color: .blue
        )
    }
    .padding()
} 