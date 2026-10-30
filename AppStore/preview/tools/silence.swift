import AVFoundation
func make() {
    let settings: [String: Any] = [AVFormatIDKey: kAudioFormatLinearPCM, AVSampleRateKey: 44100, AVNumberOfChannelsKey: 2,
                                   AVLinearPCMBitDepthKey: 16, AVLinearPCMIsFloatKey: false, AVLinearPCMIsBigEndianKey: false]
    let file = try! AVAudioFile(forWriting: URL(fileURLWithPath: CommandLine.arguments[1]), settings: settings, commonFormat: .pcmFormatInt16, interleaved: true)
    let buf = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: 44100 * 31)!
    buf.frameLength = 44100 * 31
    try! file.write(from: buf)
    file.close()
}
make()
