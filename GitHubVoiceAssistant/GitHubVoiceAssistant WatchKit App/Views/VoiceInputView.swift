import SwiftUI

struct VoiceInputView: View {
    @StateObject private var speechService = SpeechRecognitionService()
    @State private var showingConfirmation = false
    
    let onTranscriptionComplete: (String) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            if showingConfirmation {
                confirmationView
            } else {
                recordingView
            }
        }
        .padding()
        .onAppear {
            speechService.clearTranscription()
        }
    }
    
    private var recordingView: some View {
        VStack(spacing: 20) {
            Text("Voice Input")
                .font(.headline)
            
            // Recording indicator
            ZStack {
                Circle()
                    .fill(speechService.isRecording ? Color.red : Color.blue)
                    .frame(width: 80, height: 80)
                    .scaleEffect(speechService.isRecording ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: speechService.isRecording)
                
                Image(systemName: "mic.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
            }
            
            if speechService.isRecording {
                Text("Listening...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Tap to speak")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Live transcription
            if !speechService.transcriptionResult.isEmpty {
                ScrollView {
                    Text(speechService.transcriptionResult)
                        .font(.caption)
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                .frame(maxHeight: 60)
            }
            
            // Control buttons
            HStack(spacing: 20) {
                Button(action: {
                    if speechService.isRecording {
                        speechService.stopRecording()
                        if !speechService.transcriptionResult.isEmpty {
                            showingConfirmation = true
                        }
                    } else {
                        startRecording()
                    }
                }) {
                    Text(speechService.isRecording ? "Stop" : "Record")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(speechService.isRecording ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(!speechService.isAuthorized)
            }
            
            if let errorMessage = speechService.errorMessage {
                Text(errorMessage)
                    .font(.caption2)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var confirmationView: some View {
        VStack(spacing: 15) {
            Text("Confirm Request")
                .font(.headline)
            
            ScrollView {
                Text(speechService.transcriptionResult)
                    .font(.caption)
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            .frame(maxHeight: 80)
            
            HStack(spacing: 10) {
                Button("Cancel") {
                    showingConfirmation = false
                    speechService.clearTranscription()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(20)
                .buttonStyle(PlainButtonStyle())
                
                Button("Send") {
                    onTranscriptionComplete(speechService.transcriptionResult)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(20)
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private func startRecording() {
        do {
            try speechService.startRecording()
        } catch {
            speechService.errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    VoiceInputView { transcription in
        print("Transcription: \(transcription)")
    }
}