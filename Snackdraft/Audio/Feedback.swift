import AVFoundation
import UIKit

@MainActor
enum Feedback {
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func place() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warn() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}

enum SoundCue: Sendable {
    case select
    case place
    case undo
    case tip
    case recipeReady
    case serve
    case combo
    case unlock
    case result

    var intervals: [Int] {
        switch self {
        case .select: [0]
        case .place: [0, 5]
        case .undo: [5, 0]
        case .tip: [0, 7, 12]
        case .recipeReady: [0, 4, 7, 12]
        case .serve: [7, 12, 19]
        case .combo: [0, 7, 14]
        case .unlock: [0, 4, 7, 12, 16]
        case .result: [0, 7, 12, 19]
        }
    }

    var noteDuration: Double {
        switch self {
        case .select: 0.08
        case .place: 0.09
        case .undo: 0.11
        case .tip: 0.10
        case .recipeReady: 0.12
        case .serve, .unlock, .result: 0.15
        case .combo: 0.11
        }
    }
}

/// A tiny procedural soundscape: no downloaded samples, and each kitchen gets its own tonal center.
@MainActor
final class GameAudio {
    static let shared = GameAudio()

    private let engine = AVAudioEngine()
    private let effects = AVAudioPlayerNode()
    private let ambience = AVAudioPlayerNode()
    private let sampleRate = 44_100.0
    private var configured = false
    private var ambientWorld: WorldID?

    private var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("ui-testing")
    }

    private init() {}

    func play(_ cue: SoundCue, world: WorldID, enabled: Bool) {
        guard enabled, !isUITesting, prepare() else { return }
        effects.stop()
        guard let buffer = cueBuffer(cue, root: rootFrequency(for: world)) else { return }
        effects.scheduleBuffer(buffer)
        effects.play()
    }

    func startAmbient(world: WorldID, enabled: Bool) {
        guard enabled, !isUITesting, prepare() else {
            stopAmbient()
            return
        }
        guard ambientWorld != world || !ambience.isPlaying else { return }
        ambience.stop()
        guard let buffer = ambientBuffer(root: rootFrequency(for: world), world: world) else { return }
        ambientWorld = world
        ambience.volume = 0.18
        ambience.scheduleBuffer(buffer, at: nil, options: .loops)
        ambience.play()
    }

    func stopAmbient() {
        ambience.stop()
        ambientWorld = nil
    }

    private func prepare() -> Bool {
        if configured {
            if !engine.isRunning { try? engine.start() }
            return engine.isRunning
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)

            guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2) else { return false }
            engine.attach(effects)
            engine.attach(ambience)
            engine.connect(effects, to: engine.mainMixerNode, format: format)
            engine.connect(ambience, to: engine.mainMixerNode, format: format)
            effects.volume = 0.34
            engine.prepare()
            try engine.start()
            configured = true
            return true
        } catch {
            return false
        }
    }

    private func cueBuffer(_ cue: SoundCue, root: Double) -> AVAudioPCMBuffer? {
        let gap = cue.noteDuration + 0.025
        let duration = gap * Double(cue.intervals.count) + 0.08
        return makeBuffer(duration: duration) { time in
            let noteIndex = Int(time / gap)
            guard noteIndex < cue.intervals.count else { return 0 }
            let local = time - Double(noteIndex) * gap
            guard local < cue.noteDuration else { return 0 }
            let interval = cue.intervals[noteIndex]
            let frequency = root * pow(2, Double(interval) / 12)
            let attack = min(1, local / 0.012)
            let release = max(0, 1 - local / cue.noteDuration)
            let envelope = attack * release * release
            return envelope * (sin(2 * .pi * frequency * local) * 0.72
                + sin(2 * .pi * frequency * 2 * local) * 0.18)
        }
    }

    private func ambientBuffer(root: Double, world: WorldID) -> AVAudioPCMBuffer? {
        let intervals = ambientIntervals(for: world)
        let pulseEvery = 2.0
        return makeBuffer(duration: 8.0) { time in
            let noteIndex = min(Int(time / pulseEvery), intervals.count - 1)
            let local = time.truncatingRemainder(dividingBy: pulseEvery)
            guard local < 1.45 else { return 0 }
            let frequency = root * 0.5 * pow(2, Double(intervals[noteIndex]) / 12)
            let attack = min(1, local / 0.16)
            let release = max(0, 1 - local / 1.45)
            let envelope = attack * release * release * 0.11
            let fundamental = sin(2 * .pi * frequency * time)
            let shimmer = sin(2 * .pi * frequency * 2.01 * time) * 0.18
            return envelope * (fundamental + shimmer)
        }
    }

    private func makeBuffer(duration: Double, sample: (Double) -> Double) -> AVAudioPCMBuffer? {
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2) else { return nil }
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount),
              let channels = buffer.floatChannelData
        else { return nil }
        buffer.frameLength = frameCount
        for frame in 0..<Int(frameCount) {
            let time = Double(frame) / sampleRate
            let value = Float(max(-1, min(1, sample(time))))
            channels[0][frame] = value
            channels[1][frame] = value
        }
        return buffer
    }

    private func rootFrequency(for world: WorldID) -> Double {
        switch world {
        case .tea: 523.25
        case .bento: 440.00
        case .thai: 392.00
        case .israeli: 329.63
        case .italian: 349.23
        case .garden: 493.88
        case .kitchen: 261.63
        case .mexican: 392.00
        case .indian: 293.66
        }
    }

    private func ambientIntervals(for world: WorldID) -> [Int] {
        switch world {
        case .tea: [0, 7, 12, 4]
        case .bento: [0, 5, 9, 12]
        case .thai: [0, 3, 7, 10]
        case .israeli: [0, 2, 7, 9]
        case .italian: [0, 4, 7, 11]
        case .garden: [0, 4, 9, 12]
        case .kitchen: [0, 3, 7, 12]
        case .mexican: [0, 4, 7, 9]
        case .indian: [0, 2, 7, 10]
        }
    }
}
