import AppKit
import AVFoundation
import SwiftUI
import UniformTypeIdentifiers

struct CameraPreviewView: NSViewRepresentable {
    let session: AVCaptureSession

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.wantsLayer = true
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.cornerRadius = 12
        view.layer = layer
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if let layer = nsView.layer as? AVCaptureVideoPreviewLayer {
            layer.session = session
            layer.frame = nsView.bounds
        }
    }
}

struct ScannerDashboardView: View {
    @ObservedObject var store: ProductStore
    var onOpenCompare: (ProductItem) -> Void

    @StateObject private var cameraScanner = CameraBarcodeScanner()
    @State private var barcodeInput: String = ""
    @State private var activeTab: Int = 0
    @State private var customName: String = ""
    @State private var customBrand: String = ""
    @State private var customDomain: ProductDomain = .food
    @State private var customOrganic: Bool = false
    @State private var customIngredients: String = "Sugar, Palm Oil, Hazelnuts (13%), Skimmed Milk Powder, Lecithins (E322), Sodium Nitrite (E250), Tartrazine (E102)"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                scannerHeaderBar
                inputModeCard

                if let selected = store.selectedProduct {
                    ProductDetailView(
                        product: selected,
                        store: store,
                        onSelectComparison: onOpenCompare
                    )
                }
            }
            .padding(20)
        }
        .navigationTitle(L("Scanner & Live Lookup"))
        .onChange(of: cameraScanner.lastDetectedBarcode) { _, code in
            if let code, !code.isEmpty {
                barcodeInput = code
                Task { await store.lookupBarcode(code) }
            }
        }
        .onDisappear {
            cameraScanner.stop()
        }
    }

    private var scannerHeaderBar: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(L("Scanner & Live Lookup"))
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                    Text(L("Evaluate food, cosmetics, and raw whole foods with transparent scientific scoring."))
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                Spacer()

                Picker("", selection: $activeTab) {
                    Text(L("Scan Barcode")).tag(0)
                    Text(L("Camera Scanner")).tag(1)
                    Text(L("Scan Photo / OCR")).tag(2)
                    Text(L("Ingredient Analyzer")).tag(3)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 520)
            }
        }
    }

    @ViewBuilder
    private var inputModeCard: some View {
        switch activeTab {
        case 1:
            cameraScannerPanel
        case 2:
            photoOCRPanel
        case 3:
            ingredientAnalyzerPanel
        default:
            barcodeLookupPanel
        }
    }

    // MARK: - Tab 0: Barcode Lookup + Quick Presets
    private var barcodeLookupPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "barcode.viewfinder")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(YarzarTheme.emerald)

                TextField(L("Enter EAN-13 / UPC barcode (e.g. 3017620422003)..."), text: $barcodeInput)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 13, design: .monospaced))
                    .onSubmit {
                        Task { await store.lookupBarcode(barcodeInput) }
                    }

                Button {
                    Task { await store.lookupBarcode(barcodeInput) }
                } label: {
                    if store.isLookingUpBarcode {
                        HStack(spacing: 6) {
                            ProgressView().controlSize(.small)
                            Text(L("Looking up product…"))
                        }
                    } else {
                        Label(L("Lookup Barcode"), systemImage: "magnifyingglass")
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(YarzarTheme.emerald)
                .disabled(store.isLookingUpBarcode)
            }

            if let msg = store.lookupStatusMessage {
                Text(msg)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(YarzarTheme.emerald)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(L("Quick Sample Barcodes"))
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(store.products.prefix(9)) { item in
                            Button {
                                barcodeInput = item.barcode
                                store.selectAndRecordScan(item)
                            } label: {
                                HStack(spacing: 6) {
                                    Text(item.emojiIcon)
                                    Text(item.name)
                                        .font(.system(size: 11.5, weight: .semibold))
                                        .lineLimit(1)
                                    Text("\(item.totalScore)")
                                        .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 1.5)
                                        .background(Capsule().fill(item.scoreColor))
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule()
                                        .fill(Color(nsColor: .windowBackgroundColor).opacity(0.75))
                                )
                                .overlay(
                                    Capsule()
                                        .strokeBorder(item.scoreColor.opacity(0.35), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .padding(16)
        .yarzarCard(accent: YarzarTheme.emerald)
    }

    // MARK: - Tab 1: Live Camera Barcode Scanner
    private var cameraScannerPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(L("Camera Scanner"), systemImage: "camera.viewfinder")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                Spacer()
                Button(cameraScanner.isRunning ? L("Stop Camera") : L("Start Live Camera")) {
                    if cameraScanner.isRunning {
                        cameraScanner.stop()
                    } else {
                        cameraScanner.start()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(cameraScanner.isRunning ? YarzarTheme.crimsonPoor : YarzarTheme.emerald)
            }

            if cameraScanner.isRunning {
                CameraPreviewView(session: cameraScanner.session)
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(YarzarTheme.emerald, lineWidth: 2)
                    )
            }

            if !cameraScanner.statusText.isEmpty {
                Text(cameraScanner.statusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .yarzarCard(accent: YarzarTheme.mintTeal)
    }

    // MARK: - Tab 2: Photo / OCR Label & Barcode Scanner
    private var photoOCRPanel: some View {
        HStack(spacing: 16) {
            Image(systemName: "doc.text.viewfinder")
                .font(.system(size: 28))
                .foregroundStyle(YarzarTheme.mintTeal)
            VStack(alignment: .leading, spacing: 4) {
                Text(L("Drop or Choose Product / Barcode / Ingredient Photo"))
                    .font(.system(size: 14, weight: .bold))
                Text("Apple Vision automatically detects EAN/UPC barcodes OR reads the full ingredient list via OCR.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(L("Choose Image…")) {
                pickImageForVision()
            }
            .buttonStyle(.borderedProminent)
            .tint(YarzarTheme.mintTeal)
        }
        .padding(16)
        .yarzarCard(accent: YarzarTheme.mintTeal)
    }

    // MARK: - Tab 3: Custom Ingredient List Analyzer
    private var ingredientAnalyzerPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L("Paste or type ingredient list or nutrition facts to score any custom product:"))
                .font(.system(size: 13, weight: .bold))

            HStack(spacing: 10) {
                TextField("Product Name (e.g. Custom Granola / Face Serum)", text: $customName)
                    .textFieldStyle(.roundedBorder)
                TextField("Brand", text: $customBrand)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 160)
                Picker("", selection: $customDomain) {
                    Text(L("Food & Beverage")).tag(ProductDomain.food)
                    Text(L("Cosmetic & Beauty")).tag(ProductDomain.cosmetic)
                }
                .frame(width: 190)
                Toggle(L("Organic Certified"), isOn: $customOrganic)
                    .toggleStyle(.checkbox)
            }

            TextEditor(text: $customIngredients)
                .font(.system(size: 12.5, design: .monospaced))
                .frame(height: 68)
                .padding(6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(nsColor: .textBackgroundColor))
                )

            HStack {
                Spacer()
                Button {
                    let item = YarzarScoringEngine.analyzeCustomIngredients(
                        name: customName,
                        brand: customBrand,
                        domain: customDomain,
                        ingredientsText: customIngredients,
                        isOrganic: customOrganic
                    )
                    store.selectAndRecordScan(item)
                } label: {
                    Label(L("Analyze Ingredients"), systemImage: "wand.and.stars")
                }
                .buttonStyle(.borderedProminent)
                .tint(YarzarTheme.emerald)
            }
        }
        .padding(16)
        .yarzarCard(accent: YarzarTheme.emerald)
    }

    private func pickImageForVision() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image]
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK,
              let url = panel.url,
              let image = NSImage(contentsOf: url) else { return }

        Task {
            let result = await VisionScannerService.analyzeImage(image)
            if let barcode = result.detectedBarcode, !barcode.isEmpty {
                barcodeInput = barcode
                await store.lookupBarcode(barcode)
            } else if !result.recognizedText.isEmpty {
                customIngredients = result.recognizedText
                let item = YarzarScoringEngine.analyzeCustomIngredients(
                    name: url.deletingPathExtension().lastPathComponent,
                    brand: "Vision OCR Scan",
                    domain: customDomain,
                    ingredientsText: result.recognizedText,
                    isOrganic: customOrganic
                )
                store.selectAndRecordScan(item)
            }
        }
    }
}
