import SwiftUI

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Getting Started
                HelpSection(title: "Getting Started") {
                    Text("PointerPilot helps you enhance your cursor visibility and automate clicks. Access the app from the menu bar icon.")
                }
                
                // Features
                HelpSection(title: "Features") {
                    FeatureHelp(
                        title: "Cursor Highlighter",
                        description: "Makes your cursor more visible with a customizable highlight effect.",
                        tips: [
                            "Adjust the size, color, and opacity in settings",
                            "Toggle with the customizable keyboard shortcut",
                            "Works across all applications"
                        ]
                    )
                    
                    FeatureHelp(
                        title: "Auto Clicker",
                        description: "Automatically clicks at the current cursor position at a specified interval.",
                        tips: [
                            "Set the interval between clicks (0.1 to 5 seconds)",
                            "Toggle with the customizable keyboard shortcut",
                            "Clicks occur at the current cursor position"
                        ]
                    )
                }
                
                // Keyboard Shortcuts
                HelpSection(title: "Keyboard Shortcuts") {
                    ShortcutHelp(action: "Toggle Cursor Highlighter", shortcut: "⌃⇧H (customizable)")
                    ShortcutHelp(action: "Toggle Auto Clicker", shortcut: "⌃⇧C (customizable)")
                    ShortcutHelp(action: "Emergency Stop", shortcut: "⌃⎋ (Control + Escape)")
                }
                
                // Tips & Tricks
                HelpSection(title: "Tips & Tricks") {
                    BulletPoint("Use the emergency stop shortcut to quickly disable all features")
                    BulletPoint("Customize keyboard shortcuts to avoid conflicts with other apps")
                    BulletPoint("Adjust the highlighter opacity for different backgrounds")
                    BulletPoint("The app runs in the menu bar for easy access")
                }
            }
            .padding()
        }
    }
}

struct HelpSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            content()
        }
    }
}

struct FeatureHelp: View {
    let title: String
    let description: String
    let tips: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            Text(description)
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(tips, id: \.self) { tip in
                    BulletPoint(tip)
                }
            }
            .padding(.leading, 8)
        }
        .padding(.vertical, 8)
    }
}

struct ShortcutHelp: View {
    let action: String
    let shortcut: String
    
    var body: some View {
        HStack {
            Text(action)
            Spacer()
            Text(shortcut)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
    }
}

struct BulletPoint: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            Text(text)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    HelpView()
} 