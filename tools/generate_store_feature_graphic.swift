import AppKit

let workspace = FileManager.default.currentDirectoryPath
let iconPath = "\(workspace)/assets/images/app_icon.png"
let outputDirectory = "\(workspace)/store_assets"
let outputPath = "\(outputDirectory)/feature-graphic-1024x500.png"

guard let icon = NSImage(contentsOfFile: iconPath) else {
    fatalError("Could not load app icon at \(iconPath)")
}

try FileManager.default.createDirectory(
    atPath: outputDirectory,
    withIntermediateDirectories: true
)

let size = NSSize(width: 1024, height: 500)
let image = NSImage(size: size)
image.lockFocus()

let bounds = NSRect(origin: .zero, size: size)
let background = NSGradient(
    starting: NSColor(red: 1.0, green: 0.973, blue: 0.965, alpha: 1.0),
    ending: NSColor(red: 1.0, green: 0.855, blue: 0.824, alpha: 1.0)
)!
background.draw(in: bounds, angle: 0)

NSColor(red: 0.847, green: 0.290, blue: 0.227, alpha: 0.08).setFill()
NSBezierPath(ovalIn: NSRect(x: 720, y: 195, width: 430, height: 430)).fill()
NSColor(red: 0.145, green: 0.467, blue: 0.851, alpha: 0.07).setFill()
NSBezierPath(ovalIn: NSRect(x: -120, y: -150, width: 430, height: 430)).fill()

let iconPanel = NSBezierPath(
    roundedRect: NSRect(x: 58, y: 72, width: 356, height: 356),
    xRadius: 72,
    yRadius: 72
)
NSColor.white.withAlphaComponent(0.72).setFill()
iconPanel.fill()

let shadow = NSShadow()
shadow.shadowColor = NSColor.black.withAlphaComponent(0.16)
shadow.shadowBlurRadius = 24
shadow.shadowOffset = NSSize(width: 0, height: -10)
NSGraphicsContext.saveGraphicsState()
shadow.set()
icon.draw(
    in: NSRect(x: 84, y: 98, width: 304, height: 304),
    from: .zero,
    operation: .sourceOver,
    fraction: 1.0
)
NSGraphicsContext.restoreGraphicsState()

func drawText(
    _ value: String,
    rect: NSRect,
    font: NSFont,
    color: NSColor,
    lineHeight: CGFloat? = nil
) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .left
    if let lineHeight {
        paragraph.minimumLineHeight = lineHeight
        paragraph.maximumLineHeight = lineHeight
    }
    value.draw(
        in: rect,
        withAttributes: [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraph,
        ]
    )
}

let titleColor = NSColor(red: 0.169, green: 0.114, blue: 0.106, alpha: 1.0)
let bodyColor = NSColor(red: 0.361, green: 0.235, blue: 0.216, alpha: 1.0)
let accentColor = NSColor(red: 0.847, green: 0.290, blue: 0.227, alpha: 1.0)

drawText(
    "근육 학습 지도",
    rect: NSRect(x: 460, y: 292, width: 500, height: 100),
    font: NSFont.systemFont(ofSize: 62, weight: .heavy),
    color: titleColor
)
drawText(
    "인체 근육을 한눈에 익혀보세요",
    rect: NSRect(x: 464, y: 224, width: 500, height: 58),
    font: NSFont.systemFont(ofSize: 30, weight: .semibold),
    color: bodyColor
)

let badge = NSBezierPath(
    roundedRect: NSRect(x: 460, y: 116, width: 508, height: 70),
    xRadius: 24,
    yRadius: 24
)
NSColor.white.withAlphaComponent(0.76).setFill()
badge.fill()
drawText(
    "학습 완료  ·  관심 근육  ·  학습 포인트",
    rect: NSRect(x: 492, y: 133, width: 450, height: 38),
    font: NSFont.systemFont(ofSize: 23, weight: .semibold),
    color: accentColor
)

image.unlockFocus()

guard
    let tiff = image.tiffRepresentation,
    let bitmap = NSBitmapImageRep(data: tiff),
    let png = bitmap.representation(using: .png, properties: [:])
else {
    fatalError("Could not encode feature graphic")
}

try png.write(to: URL(fileURLWithPath: outputPath), options: .atomic)
print(outputPath)
