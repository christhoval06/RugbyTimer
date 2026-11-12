import AppKit

// Renders the App Store creative assets (Apple's creative asset specifications):
//   product page header  3840 x 1646 (21:9), art safe area 1646 x 661 at (1097, 493)
//   search results       3840 x 2560 (3:2),  art safe area 2168 x 1030 at (836, 765)
// Usage: swift creative.swift <screens dir> <out dir>
// Needs <screens dir>/phone/match-clock.png (1320 x 2868), watch/match-clock.png (416 x 496)
// and brand/app-icon-1024.png.

let screens = URL(fileURLWithPath: CommandLine.arguments[1])
let outDir = URL(fileURLWithPath: CommandLine.arguments[2])
try FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)

func rgb(_ hex: UInt32, _ a: CGFloat = 1) -> NSColor {
    NSColor(srgbRed: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255, alpha: a)
}
let void = rgb(0x0B0E14), emerald = rgb(0x10B981), ice = rgb(0xF9FAFB), outline = rgb(0x86948A)
let amber = rgb(0xF59E0B), yellow = rgb(0xFACC15), surface = rgb(0x1D2026), border = rgb(0x2E3746)

/// Draws with a top-left origin. AppKit needs an alpha channel to draw; run flatten.swift on the
/// output to remove it, as App Store Connect rejects images with alpha.
func render(_ w: Int, _ h: Int, to name: String, _ draw: (CGFloat, CGFloat) -> Void) throws {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: w, pixelsHigh: h, bitsPerSample: 8,
                               samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                               colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    rep.size = NSSize(width: w, height: h)
    let base = NSGraphicsContext(bitmapImageRep: rep)!
    let cg = base.cgContext
    cg.translateBy(x: 0, y: CGFloat(h)); cg.scaleBy(x: 1, y: -1)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(cgContext: cg, flipped: true)
    draw(CGFloat(w), CGFloat(h))
    NSGraphicsContext.restoreGraphicsState()
    try rep.representation(using: .png, properties: [:])!.write(to: outDir.appendingPathComponent(name))
    print("wrote", name, w, "x", h)
}

func background(_ w: CGFloat, _ h: CGFloat, glowAt c: NSPoint, radius: CGFloat) {
    void.setFill(); NSRect(x: 0, y: 0, width: w, height: h).fill()
    let glow = NSGradient(colors: [rgb(0x10B981, 0.16), rgb(0x10B981, 0.04), rgb(0x10B981, 0)],
                          atLocations: [0, 0.5, 1], colorSpace: .sRGB)!
    glow.draw(fromCenter: c, radius: 0, toCenter: c, radius: radius, options: [])
    // Faint pitch markings: halfway line, 10 m (dashed) and 22 m lines, touchlines.
    let line = rgb(0x10B981, 0.10)
    func vertical(_ x: CGFloat, dashed: Bool = false) {
        let p = NSBezierPath(); p.move(to: NSPoint(x: x, y: 0)); p.line(to: NSPoint(x: x, y: h))
        p.lineWidth = 6; if dashed { p.setLineDash([40, 34], count: 2, phase: 0) }
        line.setStroke(); p.stroke()
    }
    let mid = w / 2, step = w * 0.15
    vertical(mid); vertical(mid - step, dashed: true); vertical(mid + step, dashed: true)
    vertical(mid - step * 2.2); vertical(mid + step * 2.2)
    for y in [h * 0.06, h * 0.94] {
        let p = NSBezierPath(); p.move(to: NSPoint(x: 0, y: y)); p.line(to: NSPoint(x: w, y: y))
        p.lineWidth = 6; line.setStroke(); p.stroke()
    }
}

func text(_ s: String, _ font: NSFont, _ color: NSColor, kern: CGFloat = 0, align: NSTextAlignment = .left,
          lineHeight: CGFloat? = nil) -> NSAttributedString {
    let p = NSMutableParagraphStyle(); p.alignment = align
    if let lineHeight { p.minimumLineHeight = lineHeight; p.maximumLineHeight = lineHeight }
    return NSAttributedString(string: s, attributes: [.font: font, .foregroundColor: color, .kern: kern, .paragraphStyle: p])
}

func draw(_ s: NSAttributedString, centeredAt c: NSPoint) {
    let size = s.size(); s.draw(at: NSPoint(x: c.x - size.width / 2, y: c.y - size.height / 2))
}

/// The app's clock ring: tick marks, a dark track and the emerald arc for the time left.
func clockRing(center c: NSPoint, radius r: CGFloat, remaining: CGFloat, clock: String, label: String) {
    for i in 0..<60 {
        let major = i % 5 == 0, angle = CGFloat(i) / 60 * 2 * .pi - .pi / 2
        let outer = r * 1.0, inner = r * (major ? 0.91 : 0.95)
        let p = NSBezierPath()
        p.move(to: NSPoint(x: c.x + cos(angle) * inner, y: c.y + sin(angle) * inner))
        p.line(to: NSPoint(x: c.x + cos(angle) * outer, y: c.y + sin(angle) * outer))
        p.lineWidth = major ? r * 0.022 : r * 0.010; p.lineCapStyle = .round
        let lit = CGFloat(i) / 60 < remaining
        (lit ? emerald.withAlphaComponent(major ? 1 : 0.7) : rgb(0x374151, major ? 0.9 : 0.6)).setStroke(); p.stroke()
    }
    let trackR = r * 0.80, width = r * 0.075
    let track = NSBezierPath(); track.appendArc(withCenter: c, radius: trackR, startAngle: 0, endAngle: 360)
    track.lineWidth = width; rgb(0x1F2937).setStroke(); track.stroke()
    // Flipped context: angles run clockwise from 3 o'clock; start at 12 o'clock (-90).
    let arc = NSBezierPath()
    arc.appendArc(withCenter: c, radius: trackR, startAngle: -90, endAngle: -90 + 360 * remaining, clockwise: false)
    arc.lineWidth = width; arc.lineCapStyle = .round; emerald.setStroke(); arc.stroke()

    let pill = text("●  RUNNING", .systemFont(ofSize: r * 0.075, weight: .bold), emerald, kern: r * 0.012)
    let ps = pill.size(), pillRect = NSRect(x: c.x - ps.width / 2 - r * 0.07, y: c.y - r * 0.40,
                                            width: ps.width + r * 0.14, height: ps.height + r * 0.05)
    rgb(0x10B981, 0.14).setFill()
    NSBezierPath(roundedRect: pillRect, xRadius: pillRect.height / 2, yRadius: pillRect.height / 2).fill()
    draw(pill, centeredAt: NSPoint(x: c.x, y: pillRect.midY))
    draw(text(clock, .monospacedDigitSystemFont(ofSize: r * 0.42, weight: .black), ice), centeredAt: NSPoint(x: c.x, y: c.y + r * 0.02))
    draw(text(label, .monospacedSystemFont(ofSize: r * 0.068, weight: .medium), outline, kern: r * 0.014),
         centeredAt: NSPoint(x: c.x, y: c.y + r * 0.33))
}

func image(_ path: String) -> NSImage { NSImage(contentsOf: screens.appendingPathComponent(path))! }

/// A plain dark device body around a screen image (no Apple product artwork).
func device(_ img: NSImage, screen: NSRect, radius: CGFloat, bezel: CGFloat, crown: Bool = false) {
    let body = screen.insetBy(dx: -bezel, dy: -bezel)
    if crown {
        let k = NSRect(x: body.maxX - bezel * 0.2, y: body.minY + body.height * 0.22, width: bezel * 0.9, height: body.height * 0.17)
        rgb(0x2A313D).setFill(); NSBezierPath(roundedRect: k, xRadius: bezel * 0.35, yRadius: bezel * 0.35).fill()
    }
    let shape = NSBezierPath(roundedRect: body, xRadius: radius + bezel, yRadius: radius + bezel)
    rgb(0x161B23).setFill(); shape.fill()
    border.setStroke(); shape.lineWidth = bezel * 0.12; shape.stroke()
    NSGraphicsContext.saveGraphicsState()
    NSBezierPath(roundedRect: screen, xRadius: radius, yRadius: radius).addClip()
    img.draw(in: screen, from: .zero, operation: .sourceOver, fraction: 1, respectFlipped: true,
             hints: [.interpolation: NSImageInterpolation.high])
    NSGraphicsContext.restoreGraphicsState()
}

// MARK: Product page header: the app (icon, name, subtitle) beside its live match clock,
// all inside the 1646 x 661 safe area.
try render(3840, 1646, to: "product-page-header.png") { w, h in
    let safe = NSRect(x: 1097, y: 493, width: 1646, height: 661)
    let ringRadius: CGFloat = 300
    let ring = NSPoint(x: safe.maxX - 30 - ringRadius, y: safe.midY)
    background(w, h, glowAt: NSPoint(x: safe.midX, y: safe.midY), radius: 1500)
    clockRing(center: ring, radius: ringRadius, remaining: 0.44, clock: "17:37", label: "FIRST HALF · H1")

    // Icon, name and subtitle, stacked and vertically centred on the left.
    let iconSize: CGFloat = 200, x = safe.minX + 40
    var y = safe.midY - 240
    let icon = NSRect(x: x, y: y, width: iconSize, height: iconSize)
    NSGraphicsContext.saveGraphicsState()
    NSBezierPath(roundedRect: icon, xRadius: iconSize * 0.2237, yRadius: iconSize * 0.2237).addClip()
    image("brand/app-icon-1024.png").draw(in: icon, from: .zero, operation: .sourceOver, fraction: 1,
                                          respectFlipped: true, hints: [.interpolation: NSImageInterpolation.high])
    NSGraphicsContext.restoreGraphicsState()
    rgb(0xFFFFFF, 0.12).setStroke()
    let rim = NSBezierPath(roundedRect: icon, xRadius: iconSize * 0.2237, yRadius: iconSize * 0.2237)
    rim.lineWidth = 3; rim.stroke()
    y += iconSize + 36
    text("RUGBY TIMER", .systemFont(ofSize: 150, weight: .black, width: .condensed), ice).draw(at: NSPoint(x: x - 6, y: y))
    y += 182
    text("Match clock, sin-bins & score", .systemFont(ofSize: 58, weight: .medium), outline).draw(at: NSPoint(x: x, y: y))
}

// MARK: Search results: say what it is, and show the iPhone and Watch screens, inside 2168 x 1030.
try render(3840, 2560, to: "search-results.png") { w, h in
    let safe = NSRect(x: 836, y: 765, width: 2168, height: 1030)
    background(w, h, glowAt: NSPoint(x: safe.midX + 300, y: safe.midY), radius: 1900)

    let left = safe.minX + 48
    var y = safe.minY + 150
    text("RUGBY TIMER", .systemFont(ofSize: 58, weight: .bold), emerald, kern: 14).draw(at: NSPoint(x: left, y: y))
    y += 100
    let headline = text("MATCH CLOCK\nFOR RUGBY\nREFEREES", .systemFont(ofSize: 150, weight: .black, width: .condensed), ice, lineHeight: 146)
    headline.draw(in: NSRect(x: left, y: y, width: 1000, height: 460))
    y += 480
    text("Clock, sin-bins and score on\niPhone and Apple Watch.", .systemFont(ofSize: 60, weight: .medium), outline, lineHeight: 76)
        .draw(in: NSRect(x: left, y: y, width: 900, height: 170))

    // iPhone: the live match clock. Its clock sits inside the safe area.
    let phoneH: CGFloat = 1150, phoneW = phoneH * 1320 / 2868
    let phone = NSRect(x: safe.minX + 1010, y: safe.midY - phoneH / 2, width: phoneW, height: phoneH)
    device(image("phone/match-clock.png"), screen: phone, radius: 66, bezel: 18)
    // Apple Watch in front, bottom right.
    // Case and crown stay inside the safe area: 34 px bezel, crown reaches ~31 px past the case.
    let watchScreen = NSRect(x: safe.maxX - 70 - 416 * 1.55, y: safe.maxY - 40 - 496 * 1.55, width: 416 * 1.55, height: 496 * 1.55)
    device(image("watch/match-clock.png"), screen: watchScreen, radius: 120, bezel: 34, crown: true)
}
