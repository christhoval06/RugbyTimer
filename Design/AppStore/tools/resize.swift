import AppKit

// Scales screenshots to another App Store size, filling the frame (aspect fill, centered crop).
// Usage: swift resize.swift <width> <height> <out dir> <file>...
// Run flatten.swift on the output afterwards: App Store Connect rejects images with alpha.
let args = CommandLine.arguments
let width = Int(args[1])!, height = Int(args[2])!
let outDir = URL(fileURLWithPath: args[3])
try FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)

for path in args.dropFirst(4) {
    let url = URL(fileURLWithPath: path)
    guard let src = CGImageSourceCreateWithURL(url as CFURL, nil),
          let image = CGImageSourceCreateImageAtIndex(src, 0, nil) else { print("skip", path); continue }
    let scale = max(CGFloat(width) / CGFloat(image.width), CGFloat(height) / CGFloat(image.height))
    let drawn = CGSize(width: CGFloat(image.width) * scale, height: CGFloat(image.height) * scale)
    let ctx = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
                        space: CGColorSpace(name: CGColorSpace.sRGB)!,
                        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    ctx.interpolationQuality = .high
    ctx.draw(image, in: CGRect(x: (CGFloat(width) - drawn.width) / 2, y: (CGFloat(height) - drawn.height) / 2,
                               width: drawn.width, height: drawn.height))
    let rep = NSBitmapImageRep(cgImage: ctx.makeImage()!)
    try rep.representation(using: .png, properties: [:])!.write(to: outDir.appendingPathComponent(url.lastPathComponent))
    print("wrote", url.lastPathComponent, width, "x", height)
}
