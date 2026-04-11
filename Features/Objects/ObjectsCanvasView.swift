import PhotosUI
import SwiftUI
import UIKit

private enum ObjectDisplayMode: String, CaseIterable, Identifiable {
    case earn
    case work

    var id: String { rawValue }

    var title: String {
        switch self {
        case .earn: L10n.s("objects.mode.how_many", "How many")
        case .work: L10n.s("objects.mode.work_for_it", "Work for it")
        }
    }
}

struct ObjectsCanvasView: View {
    @Bindable var scenario: Scenario
    @Bindable var settings: AppSettings
    let palette: ThemePalette
    let repository: BundledDatasetRepository
    let salaryEngine: SalaryTranslationEngine
    let onShare: (ShareSnapshot) -> Void

    @State private var selectedCategory: ObjectCategory = .food
    @State private var displayMode: ObjectDisplayMode = .earn
    @State private var showingCustomObjectEditor = false

    private var objects: [ObjectPreset] {
        (repository.objectCatalog + settings.customObjects)
            .filter { !scenario.hiddenObjectIDs.contains($0.id) }
    }

    private var filteredInsights: [ObjectInsight] {
        salaryEngine.objectInsights(
            for: scenario,
            settings: settings,
            objects: objects.filter { selectedCategory == .custom ? $0.category == .custom : $0.category == selectedCategory },
            fxRates: repository.fxRates
        )
    }

    private var featuredInsight: ObjectInsight? {
        let favorites = filteredInsights.filter { scenario.favoriteObjectIDs.contains($0.id) }
        return favorites.first ?? filteredInsights.first
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle(
                title: L10n.s("objects.title", "Translate salary into real things."),
                subtitle: L10n.s("objects.subtitle", "Objects stay editable, local, and instantly shareable."),
                palette: palette
            )

            if let featuredInsight {
                GlassCard(palette: palette, padding: 22) {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            HStack(spacing: 10) {
                                ObjectIconView(
                                    symbolName: featuredInsight.preset.iconName,
                                    customImageFileName: featuredInsight.preset.customImageFileName,
                                    palette: palette
                                )

                                Text(featuredInsight.preset.localizedName)
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(palette.textPrimary)
                            Spacer()
                            Button(L10n.s("common.share", "Share")) {
                                onShare(snapshot(for: featuredInsight))
                            }
                            .buttonStyle(.borderless)
                            .foregroundStyle(palette.accent)
                        }

                        Text(heroStatement(for: featuredInsight))
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(palette.textPrimary)

                        Text(featuredInsight.preset.supportingLine)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(palette.textSecondary)

                        RatioBar(progress: min(featuredInsight.ratio, 1), palette: palette)
                    }
                }
            }

            Picker(L10n.s("objects.mode", "Mode"), selection: $displayMode) {
                ForEach([ObjectDisplayMode.work, .earn], id: \.self) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ObjectCategory.allCases) { category in
                        Button {
                            selectedCategory = category
                        } label: {
                            Text(category.title)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(category == selectedCategory ? palette.textPrimary : palette.textSecondary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule(style: .continuous)
                                        .fill(category == selectedCategory ? palette.cardFill : .clear)
                                        .overlay(
                                            Capsule(style: .continuous)
                                                .stroke(category == selectedCategory ? palette.accent.opacity(0.35) : palette.divider, lineWidth: 1)
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Button {
                showingCustomObjectEditor = true
            } label: {
                Label(L10n.s("objects.add_custom", "Add Custom Object"), systemImage: "plus.circle")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(palette.textPrimary)
            }
            .buttonStyle(.plain)

            LazyVStack(spacing: 12) {
                ForEach(filteredInsights) { insight in
                    GlassCard(palette: palette, padding: 16) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                HStack(spacing: 10) {
                                    ObjectIconView(
                                        symbolName: insight.preset.iconName,
                                        customImageFileName: insight.preset.customImageFileName,
                                        palette: palette
                                    )

                                    Text(insight.preset.localizedName)
                                }
                                .font(.system(size: 16, weight: .semibold))
                                Spacer()
                                Text(EarnzaFormatters.currency(insight.priceInScenarioCurrency, code: scenario.currencyCode, maximumFractionDigits: 0))
                                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            }
                            .foregroundStyle(palette.textPrimary)

                            Text(displayMode == .earn ? earnCopy(for: insight) : workCopy(for: insight))
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(palette.textPrimary)

                            Text(displayMode == .earn ? L10n.s("objects.quantity_note", "Quantity earned on your current pace.") : salaryEngine.humanWorkDescription(hours: insight.workHours))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(palette.textSecondary)

                            RatioBar(progress: min(insight.ratio, 1), palette: palette)
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            toggleFavorite(insight.id)
                        } label: {
                            Label(L10n.s("objects.favorite", "Favorite"), systemImage: scenario.favoriteObjectIDs.contains(insight.id) ? "star.slash" : "star")
                        }
                        .tint(.yellow)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            hide(insight.id)
                        } label: {
                            Label(L10n.s("common.hide", "Hide"), systemImage: "eye.slash")
                        }

                        Button {
                            onShare(snapshot(for: insight))
                        } label: {
                            Label(L10n.s("common.share", "Share"), systemImage: "square.and.arrow.up")
                        }
                        .tint(Color(palette.accent))
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .padding(.bottom, 30)
        .sheet(isPresented: $showingCustomObjectEditor) {
            CustomObjectEditorView(palette: palette) { newObject in
                var customObjects = settings.customObjects
                customObjects.append(newObject)
                settings.customObjects = customObjects

                withAnimation(.spring(response: 0.34, dampingFraction: 0.84)) {
                    selectedCategory = .custom
                }
            }
        }
    }

    private func earnCopy(for insight: ObjectInsight) -> String {
        switch displayMode {
        case .earn:
            return L10n.f("objects.per_hour", "%@ per hour", EarnzaFormatters.decimal(insight.quantityPerHour, fractionDigits: 1))
        case .work:
            return workCopy(for: insight)
        }
    }

    private func workCopy(for insight: ObjectInsight) -> String {
        if insight.workHours >= 8 {
            return L10n.f("objects.workdays", "%@ workdays", EarnzaFormatters.decimal(insight.workDays, fractionDigits: 1))
        }
        return L10n.f("objects.hours", "%@ hours", EarnzaFormatters.decimal(insight.workHours, fractionDigits: 1))
    }

    private func heroStatement(for insight: ObjectInsight) -> String {
        if displayMode == .earn {
            return L10n.f("objects.hero_earn", "You earn %@ %@ per hour.", EarnzaFormatters.decimal(insight.quantityPerHour, fractionDigits: 1), insight.preset.localizedName)
        }
        return L10n.f("objects.hero_work", "One %@ costs %@ work hours.", insight.preset.localizedName, EarnzaFormatters.decimal(insight.workHours, fractionDigits: 1))
    }

    private func toggleFavorite(_ id: String) {
        var favorites = scenario.favoriteObjectIDs
        if let index = favorites.firstIndex(of: id) {
            favorites.remove(at: index)
        } else {
            favorites.append(id)
        }
        scenario.favoriteObjectIDs = favorites
        scenario.touch()
    }

    private func hide(_ id: String) {
        var hidden = scenario.hiddenObjectIDs
        if !hidden.contains(id) {
            hidden.append(id)
            scenario.hiddenObjectIDs = hidden
            scenario.touch()
        }
    }

    private func snapshot(for insight: ObjectInsight) -> ShareSnapshot {
        ShareSnapshot(
            title: insight.preset.localizedName,
            value: displayMode == .earn ? earnCopy(for: insight) : workCopy(for: insight),
            subtitle: displayMode == .earn ? L10n.s("objects.share.earn_subtitle", "How many you earn at current pace.") : L10n.s("objects.share.work_subtitle", "How long you work for it."),
            details: [
                L10n.f("common.price_value", "Price: %@", EarnzaFormatters.currency(insight.priceInScenarioCurrency, code: scenario.currencyCode)),
                L10n.f("objects.per_day", "Per day: %@", EarnzaFormatters.decimal(insight.quantityPerDay, fractionDigits: 1)),
                salaryEngine.humanWorkDescription(hours: insight.workHours)
            ],
            symbolName: insight.preset.iconName,
            theme: scenario.selectedTheme,
            customImageFileName: insight.preset.customImageFileName
        )
    }
}

private struct CustomObjectEditorView: View {
    let palette: ThemePalette
    let onSave: (ObjectPreset) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var price = 0.0
    @State private var showingImagePicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var previewImage: UIImage?
    @State private var isLoadingImage = false
    @State private var errorMessage: String?

    var body: some View {
        BottomSheetEditor(title: L10n.s("objects.custom.title", "Custom Object"), palette: palette) {
            Button {
                showingImagePicker = true
            } label: {
                VStack(alignment: .leading, spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(palette.cardFill)

                        if let previewImage {
                            Image(uiImage: previewImage)
                                .resizable()
                                .scaledToFill()
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 26, weight: .semibold))
                                    .foregroundStyle(palette.accent)

                                Text(L10n.s("objects.custom.image_picker", "Choose image"))
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(palette.textPrimary)

                                Text(L10n.s("objects.custom.image_hint", "Pick a photo from your library. It will be cropped into a square icon."))
                                    .font(.system(size: 13, weight: .medium))
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(palette.textSecondary)
                                    .padding(.horizontal, 18)
                            }
                        }
                    }
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(palette.divider, lineWidth: 1)
                    )

                    HStack {
                        Text(previewImage == nil ? L10n.s("objects.custom.image_picker", "Choose image") : L10n.s("objects.custom.change_image", "Change image"))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(palette.textPrimary)
                        Spacer()
                        if isLoadingImage {
                            ProgressView()
                                .tint(palette.accent)
                        } else {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(palette.textSecondary)
                        }
                    }
                }
            }
            .buttonStyle(.plain)
            .photosPicker(isPresented: $showingImagePicker, selection: $selectedPhotoItem, matching: .images)

            TextField(L10n.s("objects.custom.name", "Name"), text: $name)
                .textFieldStyle(.roundedBorder)

            TextField(L10n.s("objects.custom.price", "Price"), value: $price, format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)

            Button(L10n.s("objects.custom.save", "Save Object")) {
                saveObject()
            }
            .buttonStyle(.borderedProminent)
            .tint(palette.accent)
            .disabled(selectedImageData == nil || isLoadingImage)
        }
        .task(id: selectedPhotoItem) {
            await loadSelectedImage()
        }
        .alert(
            L10n.s("objects.custom.image_error_title", "Image unavailable"),
            isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )
        ) {
            Button(L10n.s("common.ok", "OK"), role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    @MainActor
    private func loadSelectedImage() async {
        guard let selectedPhotoItem else { return }
        isLoadingImage = true
        defer { isLoadingImage = false }

        do {
            guard let data = try await selectedPhotoItem.loadTransferable(type: Data.self),
                  let image = UIImage(data: data)
            else {
                errorMessage = L10n.s("objects.custom.image_error", "Couldn't load this image. Try a different photo.")
                return
            }

            selectedImageData = data
            previewImage = image
        } catch {
            errorMessage = L10n.s("objects.custom.image_error", "Couldn't load this image. Try a different photo.")
        }
    }

    private func saveObject() {
        guard let selectedImageData else { return }

        let objectID = UUID().uuidString

        do {
            let fileName = try CustomObjectImageStore.saveImageData(selectedImageData, id: objectID)
            let object = ObjectPreset(
                id: objectID,
                localizedName: name.isEmpty ? L10n.s("objects.custom.default_name", "Custom Object") : name,
                category: .custom,
                iconName: "shippingbox",
                customImageFileName: fileName,
                defaultPrice: price,
                currencyCode: "USD",
                editableByUser: true,
                sharePriority: 2,
                supportingLine: L10n.s("objects.custom.supporting_line", "User-defined salary benchmark.")
            )
            onSave(object)
            dismiss()
        } catch {
            errorMessage = L10n.s("objects.custom.save_error", "Couldn't save this image on your device.")
        }
    }
}
