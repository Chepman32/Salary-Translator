import SwiftUI
import UIKit

struct ShareStudioView: View {
    let snapshot: ShareSnapshot
    let palette: ThemePalette

    @State private var template: ShareTemplate = .boldNumber
    @State private var privacyMode: SharePrivacyMode = .exact
    @State private var shareURL: URL?
    @State private var renderTaskID = UUID()

    private let renderer = DefaultShareRenderService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SharePreviewCard(snapshot: snapshot, palette: palette, template: template, privacyMode: privacyMode)
                        .padding(.top, 8)

                    Picker("Template", selection: $template) {
                        ForEach(ShareTemplate.allCases) { template in
                            Text(template.title).tag(template)
                        }
                    }
                    .pickerStyle(.menu)

                    Picker("Privacy", selection: $privacyMode) {
                        ForEach(SharePrivacyMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)

                    if let shareURL {
                        ShareLink(item: shareURL) {
                            Label("Export Card", systemImage: "square.and.arrow.up")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(palette.accent)
                    }

                    Text("Still image export uses native rendering with the active theme and privacy controls.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(palette.textSecondary)
                }
                .padding(20)
            }
            .background(EarnzaBackground(palette: palette))
            .navigationTitle("Share Studio")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task(id: renderTaskID) {
            shareURL = try? await renderer.fileURL(for: snapshot, template: template, privacy: privacyMode, width: 1200)
        }
        .onChange(of: template) { _, _ in renderTaskID = UUID() }
        .onChange(of: privacyMode) { _, _ in renderTaskID = UUID() }
        .presentationDetents([.large])
    }
}

struct SharePreviewCard: View {
    let snapshot: ShareSnapshot
    let palette: ThemePalette
    let template: ShareTemplate
    let privacyMode: SharePrivacyMode

    var body: some View {
        let protectedValue: String = switch privacyMode {
        case .exact: snapshot.value
        case .blurred: snapshot.value.map { $0 == " " ? " " : "•" }.reduce("", +)
        case .hidden: "Hidden"
        }

        GlassCard(palette: palette, padding: 26) {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Label("Earnza", systemImage: snapshot.symbolName)
                        .font(.system(size: 15, weight: .semibold))
                    Spacer()
                    Text(template.title)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(palette.textSecondary)
                }
                .foregroundStyle(palette.textPrimary)

                Text(snapshot.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(palette.textSecondary)

                Text(protectedValue)
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(palette.textPrimary)
                    .minimumScaleFactor(0.7)

                Text(snapshot.subtitle)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(palette.textSecondary)

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(snapshot.details, id: \.self) { detail in
                        Text(detail)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(palette.textSecondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct DefaultShareRenderService: ShareRenderService {
    @MainActor
    func fileURL(for snapshot: ShareSnapshot, template: ShareTemplate, privacy: SharePrivacyMode, width: CGFloat) async throws -> URL {
        let palette = EarnzaTheme.palette(for: snapshot.theme)
        let view = SharePreviewCard(snapshot: snapshot, palette: palette, template: template, privacyMode: privacy)
            .frame(width: width / 3.1)
            .padding(32)
            .background(EarnzaBackground(palette: palette))

        let renderer = ImageRenderer(content: view)
        renderer.scale = 3

        guard let uiImage = renderer.uiImage,
              let data = uiImage.pngData()
        else {
            throw CocoaError(.fileWriteUnknown)
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("earnza-\(snapshot.id.uuidString).png")
        try data.write(to: url, options: .atomic)
        return url
    }
}
