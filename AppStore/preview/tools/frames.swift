import AVFoundation
import AppKit
// 使い方: frames <動画> <出力の接頭辞> <間隔秒> [列数]
let a = CommandLine.arguments
let asset = AVURLAsset(url: URL(fileURLWithPath: a[1]))
let gen = AVAssetImageGenerator(asset: asset)
gen.appliesPreferredTrackTransform = true
gen.maximumSize = CGSize(width: 240, height: 520)
gen.requestedTimeToleranceBefore = .zero; gen.requestedTimeToleranceAfter = .zero
let dur = CMTimeGetSeconds(asset.duration)
let step = Double(a[3])!
let cols = a.count > 4 ? Int(a[4])! : 8
// ラベルは取り出した時刻そのもの（取り出せないコマがあっても、あとのラベルがずれないように）
var imgs: [(CGImage, Double)] = []
var t = 0.0
while t < dur { if let i = try? gen.copyCGImage(at: CMTime(seconds: t, preferredTimescale: 600), actualTime: nil) { imgs.append((i, t)) }; t += step }
guard let first = imgs.first?.0 else { print("コマを取り出せませんでした"); exit(1) }
let w = first.width, h = first.height
let rows = (imgs.count + cols - 1) / cols
let ctx = CGContext(data: nil, width: w * cols, height: (h + 20) * rows, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
ctx.setFillColor(.white); ctx.fill(CGRect(x: 0, y: 0, width: w * cols, height: (h + 20) * rows))
let ns = NSGraphicsContext(cgContext: ctx, flipped: false); NSGraphicsContext.current = ns
for (k, (im, at)) in imgs.enumerated() {
    let x = (k % cols) * w, y = (rows - 1 - k / cols) * (h + 20)
    ctx.draw(im, in: CGRect(x: x, y: y + 20, width: w, height: h))
    NSString(string: String(format: "%.1fs", at)).draw(at: CGPoint(x: x + 4, y: y + 2), withAttributes: [.font: NSFont.boldSystemFont(ofSize: 14)])
}
let rep = NSBitmapImageRep(cgImage: ctx.makeImage()!)
try! rep.representation(using: .jpeg, properties: [.compressionFactor: 0.7])!.write(to: URL(fileURLWithPath: a[2] + ".jpg"))
print("duration", dur, "frames", imgs.count)
