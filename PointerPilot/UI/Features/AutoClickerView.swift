import SwiftUI

/// View for the auto-clicker feature
struct AutoClickerView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showingPermissionAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Click interval slider
            VStack(alignment: .leading) {
                Text("Click Interval")
                    .font(.headline)
                
                HStack {
                    Slider(
                        value: Binding(
                            get: { viewModel.state.clickInterval },
                            set: { viewModel.updateClickInterval($0) }
                        ),
                        in: 0.1...5.0,
                        step: 0.1
                    )
                    .accessibilityIdentifier("Click Interval")
                    
                    Text(String(format: "%.1f s", viewModel.state.clickInterval))
                        .monospacedDigit()
                        .frame(width: 50)
                }
            }
            
            // Target app selection
            VStack(alignment: .leading) {
                Text("Target App")
                    .font(.headline)
                
                Text("Coming soon...")
                    .font(.caption)
            }
            
            // Status indicator
            VStack(alignment: .leading) {
                Text("Status")
                    .font(.headline)
                
                HStack {
                    Circle()
                        .fill(viewModel.state.isClickingEnabled ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    
                    Text(viewModel.state.isClickingEnabled ? "Running" : "Stopped")
                        .font(.caption)
                        .accessibilityIdentifier("Status")
                }
                .foregroundStyle(.secondary)
            }
            
            // Test click button
            Button("Test Click") {
                if !viewModel.testClick() {
                    showingPermissionAlert = true
                }
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("Test Click")
            .alert("Accessibility Permission Required", isPresented: $showingPermissionAlert) {
                Button("Open Settings") {
                    viewModel.openAccessibilitySettings()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Test Click requires accessibility permissions to perform clicks.")
            }
        }
        .padding()
    }
}

#Preview {
    AutoClickerView()
        .environmentObject(PreviewViewModel())
}

private class PreviewViewModel: AppViewModel {
    init() {
        super.init(services: PreviewServices())
    }
}

private class PreviewServices: AppServices {
    override func getCurrentMouseLocation() -> CGPoint { .zero }
    override func performClick(at location: CGPoint) throws {}
    override func getRunningApplications() -> [AppIdentifier] {
        [
            AppIdentifier(bundleIdentifier: "com.example.app1", name: "App 1"),
            AppIdentifier(bundleIdentifier: "com.example.app2", name: "App 2")
        ].compactMap { $0 }
    }
} 