import SwiftUI

/// A reusable card component for sections in the app
struct SectionCard<Content: View>: View {
    let title: String
    let systemImage: String
    var shortcut: String?
    var isEnabled: Bool?
    @ViewBuilder let content: Content
    
    init(
        _ title: String,
        systemImage: String,
        shortcut: String? = nil,
        isEnabled: Bool? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.systemImage = systemImage
        self.shortcut = shortcut
        self.isEnabled = isEnabled
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: AppConfig.UI.defaultPadding) {
            // Header
            HStack {
                Label(title, systemImage: systemImage)
                    .font(.headline)
                    .foregroundStyle(isEnabled == true ? .blue : .primary)
                
                Spacer()
                
                if let shortcut {
                    Text(shortcut)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.secondary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            
            // Content
            content
                .padding(.horizontal, 4)
        }
        .padding(AppConfig.UI.defaultPadding)
        .background {
            RoundedRectangle(cornerRadius: AppConfig.UI.cornerRadius)
                .fill(.background)
                .shadow(
                    color: .black.opacity(0.1),
                    radius: 1,
                    y: 1
                )
        }
    }
}

#Preview {
    VStack {
        SectionCard(
            "Test Section",
            systemImage: "star.fill",
            shortcut: "⌃⇧T",
            isEnabled: true
        ) {
            Text("Content goes here")
        }
        
        SectionCard(
            "Another Section",
            systemImage: "gear"
        ) {
            Text("More content")
        }
    }
    .padding()
} 