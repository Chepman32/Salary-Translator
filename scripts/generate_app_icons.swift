import AppKit

struct IconSpec {
    let filename: String
    let size: CGFloat
}

let outputDirectory = URL(fileURLWithPath: "Resources/Assets.xcassets/AppIcon.appiconset", isDirectory: true)
let specs: [IconSpec] = [
    .init(filename: "Icon-20@2x.png", size: 40),
    .init(filename: "Icon-20@3x.png", size: 60),
    .init(filename: "Icon-29@2x.png", size: 58),
    .init(filename: "Icon-29@3x.png", size: 87),
    .init(filename: "Icon-40@2x.png", size: 80),
    .init(filename: "Icon-40@3x.png", size: 120),
    .init(filename: "Icon-60@2x.png", size: 120),
    .init(filename: "Icon-60@3x.png", size: 180),
    .init(filename: "Icon-1024.png", size: 1024)
]

func drawIcon(size: CGFloat) throws -> Data {
    let pixels = Int(size)
    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixels,
        pixelsHigh: pixels,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        throw CocoaError(.fileWriteUnknown)
    }

    bitmap.size = NSSize(width: size, height: size)

    guard let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
        throw CocoaError(.fileWriteUnknown)
    }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context

    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    let radius = size * 0.225
    let background = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)

    NSColor(calibratedRed: 0.06, green: 0.08, blue: 0.11, alpha: 1).setFill()
    background.fill()

    let gradient = NSGradient(colors: [
        NSColor(calibratedRed: 0.20, green: 0.87, blue: 0.60, alpha: 0.98),
        NSColor(calibratedRed: 0.23, green: 0.59, blue: 0.95, alpha: 0.92)
    ])!
    gradient.draw(in: background, angle: -40)

    let overlay = NSBezierPath(roundedRect: rect.insetBy(dx: size * 0.02, dy: size * 0.02), xRadius: radius * 0.92, yRadius: radius * 0.92)
    NSColor.white.withAlphaComponent(0.05).setStroke()
    overlay.lineWidth = size * 0.012
    overlay.stroke()

    let leftBar = NSBezierPath(roundedRect: NSRect(x: size * 0.24, y: size * 0.18, width: size * 0.16, height: size * 0.64), xRadius: size * 0.08, yRadius: size * 0.08)
    NSColor.white.withAlphaComponent(0.92).setFill()
    leftBar.fill()

    let topLoop = NSBezierPath(roundedRect: NSRect(x: size * 0.34, y: size * 0.46, width: size * 0.32, height: size * 0.24), xRadius: size * 0.12, yRadius: size * 0.12)
    NSColor.white.withAlphaComponent(0.92).setFill()
    topLoop.fill()

    let cutout = NSBezierPath(roundedRect: NSRect(x: size * 0.42, y: size * 0.53, width: size * 0.17, height: size * 0.10), xRadius: size * 0.05, yRadius: size * 0.05)
    NSColor(calibratedRed: 0.09, green: 0.22, blue: 0.25, alpha: 1).setFill()
    cutout.fill()

    let bars = [
        NSRect(x: size * 0.58, y: size * 0.22, width: size * 0.08, height: size * 0.14),
        NSRect(x: size * 0.68, y: size * 0.22, width: size * 0.08, height: size * 0.28),
        NSRect(x: size * 0.78, y: size * 0.22, width: size * 0.08, height: size * 0.42)
    ]

    for (index, barRect) in bars.enumerated() {
        let bar = NSBezierPath(roundedRect: barRect, xRadius: size * 0.03, yRadius: size * 0.03)
        let alpha = 0.46 + CGFloat(index) * 0.12
        NSColor.white.withAlphaComponent(alpha).setFill()
        bar.fill()
    }

    NSGraphicsContext.restoreGraphicsState()

    guard let data = bitmap.representation(using: .png, properties: [:]) else {
        throw CocoaError(.fileWriteUnknown)
    }
    return data
}

func writePNG(_ data: Data, to url: URL) throws {
    try data.write(to: url, options: .atomic)
}

try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

for spec in specs {
    let data = try drawIcon(size: spec.size)
    try writePNG(data, to: outputDirectory.appendingPathComponent(spec.filename))
}
