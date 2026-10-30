import AVFoundation
import CoreImage
// 使い方: compose <出力.mp4> <音声.wav> <録画.mp4> <開始-終了> [<開始-終了> …]
// 録画のいくつかの区間をつなぎ、886×1920・30fps・H.264 High 4.0、AAC 256kbps ステレオで書き出す（slash の compose.swift と同じ作り）。
// 映像は 1/30 秒ごとに「その時刻に録画の画面に映っている絵」を取り出して並べる
// （シミュレータの録画は画面が止まっているあいだコマがないので、区間で切るだけだと止まった画面が抜ける）
let args = CommandLine.arguments
guard args.count >= 5 else { print("compose <出力.mp4> <音声.wav> <録画.mp4> <開始-終了>…"); exit(1) }
let out = URL(fileURLWithPath: args[1])
let audioURL = URL(fileURLWithPath: args[2])
let source = URL(fileURLWithPath: args[3])
let cuts: [(Double, Double)] = args[4...].map { s in
    let p = s.split(separator: "-").map { Double($0)! }
    return (p[0], p[1])
}
let W = 886, H = 1920, FPS = 30
func T(_ s: Double) -> CMTime { CMTime(seconds: s, preferredTimescale: 600) }

// 区間ごとのコマ数（小数の誤差で1コマ欠けないよう四捨五入）。全体の長さはその合計
let counts = cuts.map { Int((($0.1 - $0.0) * Double(FPS)).rounded()) }
let frameCount = counts.reduce(0, +)
let totalSec = Double(frameCount) / Double(FPS)
let total = CMTime(value: CMTimeValue(frameCount), timescale: CMTimeScale(FPS))
print("total", CMTimeGetSeconds(total))
guard totalSec >= 15, totalSec <= 30 else { print("長さは 15〜30 秒にすること（いま \(totalSec) 秒）"); exit(1) }

// 音声：素材を繰り返して長さに合わせる（無音でも音声トラックは必須）
let comp = AVMutableComposition()
let at = comp.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
let aAsset = AVURLAsset(url: audioURL)
guard let aSrc = aAsset.tracks(withMediaType: .audio).first, aAsset.duration > .zero else { print("音声が読めません: \(audioURL.path)"); exit(1) }
var ac = CMTime.zero
while ac < total {
    let len = min(aAsset.duration, total - ac)
    try! at.insertTimeRange(CMTimeRange(start: .zero, duration: len), of: aSrc, at: ac)
    ac = ac + len
}
let reader = try! AVAssetReader(asset: comp)
reader.timeRange = CMTimeRange(start: .zero, duration: total)
let aOut = AVAssetReaderAudioMixOutput(audioTracks: [at], audioSettings: [AVFormatIDKey: kAudioFormatLinearPCM, AVSampleRateKey: 44100, AVNumberOfChannelsKey: 2,
    AVLinearPCMBitDepthKey: 16, AVLinearPCMIsFloatKey: false, AVLinearPCMIsBigEndianKey: false, AVLinearPCMIsNonInterleaved: false])
reader.add(aOut)

try? FileManager.default.removeItem(at: out)
let writer = try! AVAssetWriter(outputURL: out, fileType: .mp4)
let vIn = AVAssetWriterInput(mediaType: .video, outputSettings: [AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: W, AVVideoHeightKey: H,
    AVVideoColorPropertiesKey: [AVVideoColorPrimariesKey: AVVideoColorPrimaries_ITU_R_709_2, AVVideoTransferFunctionKey: AVVideoTransferFunction_ITU_R_709_2,
                                AVVideoYCbCrMatrixKey: AVVideoYCbCrMatrix_ITU_R_709_2],
    AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: 12_000_000, AVVideoProfileLevelKey: AVVideoProfileLevelH264High40,
                                      AVVideoExpectedSourceFrameRateKey: FPS, AVVideoMaxKeyFrameIntervalKey: FPS, AVVideoAllowFrameReorderingKey: true]])
let aIn = AVAssetWriterInput(mediaType: .audio, outputSettings: [AVFormatIDKey: kAudioFormatMPEG4AAC, AVSampleRateKey: 44100, AVNumberOfChannelsKey: 2, AVEncoderBitRateKey: 256_000])
vIn.expectsMediaDataInRealTime = false; aIn.expectsMediaDataInRealTime = false
writer.add(vIn); writer.add(aIn)
let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: vIn, sourcePixelBufferAttributes: [
    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA, kCVPixelBufferWidthKey as String: W, kCVPixelBufferHeightKey as String: H])
guard reader.startReading(), writer.startWriting() else { print("読み書きを始められません", reader.error as Any, writer.error as Any); exit(1) }
writer.startSession(atSourceTime: .zero)

let g = DispatchGroup()
g.enter()
aIn.requestMediaDataWhenReady(on: DispatchQueue(label: "a")) {
    while aIn.isReadyForMoreMediaData {
        if let sb = aOut.copyNextSampleBuffer() { aIn.append(sb) } else { aIn.markAsFinished(); g.leave(); return }
    }
}

// 色は sRGB として扱う（タグのない色空間だと、淡い色がくすんで見えることがある）
let srgb = CGColorSpace(name: CGColorSpace.sRGB)!
let ci = CIContext(options: [.workingColorSpace: srgb, .outputColorSpace: srgb])
let asset = AVURLAsset(url: source)
let gen = AVAssetImageGenerator(asset: asset)
gen.appliesPreferredTrackTransform = true
gen.requestedTimeToleranceBefore = CMTime(value: 1, timescale: 30)   // その時刻に映っている（直前の）コマ
gen.requestedTimeToleranceAfter = .zero
var k = 0
var last: CGImage?
for ((a, _), n) in zip(cuts, counts) {
    for i in 0..<n {
        let src = a + Double(i) / Double(FPS)
        // 取り出せなかったコマは前のコマで埋める（飛ばすと、そのあとが全部ずれる）
        guard let img = (try? gen.copyCGImage(at: T(src), actualTime: nil)) ?? last else { print("no frame", src); exit(1) }
        last = img
        // 横幅を 886 に合わせ、はみ出す上下を同じだけ切る（1206×2622 → 886×1926 → 886×1920）
        let c = CIImage(cgImage: img)
        let s = CGFloat(W) / c.extent.width
        let scaled = c.transformed(by: CGAffineTransform(scaleX: s, y: s))
        let dy = (scaled.extent.height - CGFloat(H)) / 2
        let placed = scaled.transformed(by: CGAffineTransform(translationX: 0, y: -dy))
        var pb: CVPixelBuffer?
        CVPixelBufferPoolCreatePixelBuffer(nil, adaptor.pixelBufferPool!, &pb)
        ci.render(placed, to: pb!, bounds: CGRect(x: 0, y: 0, width: W, height: H), colorSpace: srgb)
        while !vIn.isReadyForMoreMediaData {
            if writer.status == .failed { print("書き出しに失敗しました", writer.error as Any); exit(1) }
            usleep(2000)
        }
        guard adaptor.append(pb!, withPresentationTime: CMTime(value: CMTimeValue(k), timescale: CMTimeScale(FPS))) else {
            print("コマを書けませんでした", writer.error as Any); exit(1)
        }
        k += 1
    }
}
vIn.markAsFinished()
g.wait()
writer.endSession(atSourceTime: total)
let sem = DispatchSemaphore(value: 0)
writer.finishWriting { sem.signal() }
sem.wait()
print("frames", k, "status", writer.status.rawValue, writer.error as Any)
