import SwiftUI

struct PreferencesView: View {
    @Bindable var settingsService: SettingsService

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Hidden Apps")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 8)

            if sortedIgnoredApps.isEmpty {
                Spacer()
                Text("No hidden apps")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                List {
                    ForEach(sortedIgnoredApps, id: \.self) { path in
                        HStack(spacing: 10) {
                            Image(nsImage: appIcon(for: path))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)

                            Text(appName(from: path))
                                .lineLimit(1)

                            Spacer()

                            Button {
                                settingsService.unignore(path: path)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .frame(width: 400, height: 300)
    }

    private var sortedIgnoredApps: [String] {
        settingsService.ignoredApps.sorted()
    }

    private func appName(from path: String) -> String {
        let url = URL(fileURLWithPath: path)
        return url.deletingPathExtension().lastPathComponent
    }

    private func appIcon(for path: String) -> NSImage {
        let icon = NSWorkspace.shared.icon(forFile: path)
        icon.size = NSSize(width: 24, height: 24)
        return icon
    }
}
