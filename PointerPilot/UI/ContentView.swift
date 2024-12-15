import SwiftUI

/// Main content view for the application
struct ContentView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            CursorHighlighterView()
            AutoClickerView()
        }
        .padding()
        .frame(width: 300)
    }
}

#Preview {
    ContentView()
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