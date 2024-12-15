import SwiftUI

/// View for the mouse ping feature
struct CursorHighlighterView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showingPermissionAlert = false
    
    var body: some View {
        SectionCard(
            "Mouse Ping",
            systemImage: "cursorarrow.rays",
            shortcut: "⌃⇧H"
        ) {
            VStack(spacing: AppConfig.UI.Layout.spacing * 2) {
                // Primary Action Section
                Button(action: {
                    if !viewModel.testMouseLocation() {
                        showingPermissionAlert = true
                    }
                }) {
                    HStack {
                        Image(systemName: "cursorarrow.click")
                            .font(.system(size: AppConfig.UI.Layout.iconSize))
                        Text("Ping Mouse")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: AppConfig.UI.Layout.buttonHeight)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("Test Highlight")
                .alert("Accessibility Permission Required", isPresented: $showingPermissionAlert) {
                    Button("Open Settings") {
                        viewModel.openAccessibilitySettings()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Mouse Ping requires accessibility permissions to highlight the cursor location.")
                }
                
                Divider()
                
                // Settings Section
                VStack(alignment: .leading, spacing: AppConfig.UI.Layout.spacing) {
                    Text("Settings")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    // Size Control
                    HStack(spacing: AppConfig.UI.Layout.spacing) {
                        Text("Ring Size")
                            .frame(width: 80, alignment: .leading)
                        
                        TextField("", value: Binding(
                            get: { viewModel.state.highlightSize },
                            set: { viewModel.updateHighlightSize($0) }
                        ), format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 60)
                        
                        Text("pixels")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                    
                    // Duration Control
                    HStack(spacing: AppConfig.UI.Layout.spacing) {
                        Text("Duration")
                            .frame(width: 80, alignment: .leading)
                        
                        TextField("", value: Binding(
                            get: { viewModel.state.highlightDuration },
                            set: { viewModel.updateHighlightDuration($0) }
                        ), format: .number.precision(.fractionLength(1)))
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 60)
                        
                        Text("seconds")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                }
            }
        }
    }
}

#Preview {
    CursorHighlighterView()
        .environmentObject(PreviewViewModel())
        .padding()
}

private class PreviewViewModel: AppViewModel {
    init() {
        super.init(services: PreviewServices())
    }
}

private class PreviewServices: AppServices {
    override func getCurrentMouseLocation() -> CGPoint { .zero }
    override func performClick(at location: CGPoint) throws {}
} 