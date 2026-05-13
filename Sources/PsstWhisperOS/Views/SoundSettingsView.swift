import SwiftUI
import AppKit

struct SoundSettingsView: View {
    @AppStorage(StorageKeys.playStartSound) private var playStartSound = true
    @AppStorage(StorageKeys.playStopSound) private var playStopSound = true
    @AppStorage(StorageKeys.soundVolume) private var soundVolume: Double = 1.0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Sound")
                    .font(.title2)
                    .fontWeight(.semibold)

                SettingsCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recording sounds")
                            .font(.headline)

                        SettingsRow(
                            title: "Play sound when recording starts",
                            subtitle: nil
                        ) {
                            HStack(spacing: 8) {
                                Toggle("", isOn: $playStartSound)
                                    .labelsHidden()
                                    .toggleStyle(.switch)
                                Button("Test") {
                                    playTestSound(named: "Tink")
                                }
                                .controlSize(.small)
                                .disabled(!playStartSound)
                            }
                        }

                        SettingsRow(
                            title: "Play sound when recording stops",
                            subtitle: nil
                        ) {
                            HStack(spacing: 8) {
                                Toggle("", isOn: $playStopSound)
                                    .labelsHidden()
                                    .toggleStyle(.switch)
                                Button("Test") {
                                    playTestSound(named: "Pop")
                                }
                                .controlSize(.small)
                                .disabled(!playStopSound)
                            }
                        }
                    }
                }

                SettingsCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Volume")
                            .font(.headline)
                        HStack {
                            Image(systemName: "speaker.fill")
                                .foregroundColor(.secondary)
                            Slider(value: $soundVolume, in: 0...1.0, step: 0.01)
                            Image(systemName: "speaker.wave.3.fill")
                                .foregroundColor(.secondary)
                            Text("\(Int(soundVolume * 100))%")
                                .monospacedDigit()
                                .frame(width: 40, alignment: .trailing)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(24)
        }
    }

    private func playTestSound(named name: String) {
        if let sound = NSSound(named: .init(name)) {
            sound.volume = Float(soundVolume)
            sound.play()
        }
    }
}
