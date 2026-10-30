import AVFoundation
let a = AVURLAsset(url: URL(fileURLWithPath: CommandLine.arguments[1]))
print("duration", CMTimeGetSeconds(a.duration))
for t in a.tracks {
    let fd = t.formatDescriptions.first as! CMFormatDescription
    let sub = CMFormatDescriptionGetMediaSubType(fd)
    let code = String(bytes: [24,16,8,0].map { UInt8((sub >> $0) & 0xff) }, encoding: .ascii) ?? "?"
    if t.mediaType == .video {
        print("video", code, t.naturalSize, "fps", t.nominalFrameRate, "bitrate", Int(t.estimatedDataRate), "enabled", t.isEnabled)
        if let ext = CMFormatDescriptionGetExtension(fd, extensionKey: "SampleDescriptionExtensionAtoms" as CFString) as? [String: Any], let avcC = ext["avcC"] as? Data {
            print("  avc profile", avcC[1], "level", avcC[3])
        }
    } else {
        let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(fd)!.pointee
        print("audio", code, "rate", asbd.mSampleRate, "ch", asbd.mChannelsPerFrame, "bitrate", Int(t.estimatedDataRate), "enabled", t.isEnabled)
    }
}
