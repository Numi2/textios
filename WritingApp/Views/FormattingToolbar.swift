/*
Formatting toolbar for the text editor.
*/

import SwiftUI

struct FormattingToolbar: View {
    @Binding var text: AttributedString
    @Binding var selection: AttributedTextSelection
    @StateObject private var openAI = OpenAIService()
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        HStack {
            // Bold button
            Button("Bold") {
                toggleBold()
            }
            .buttonStyle(.bordered)
            
            // Concept button
            Button("Concept") {
                toggleConcept()
            }
            .buttonStyle(.bordered)
            
            // Complete button
            Button("Complete") {
                Task {
                    await performCompletion()
                }
            }
            .buttonStyle(.bordered)
            .disabled(isLoading)
            
            if isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private func toggleBold() {
        // Important: Use transform to maintain selection
        text.transform(updating: &selection) { text in
            let selectedText = text[selection]
            
            // Check if the selected text already has bold
            var hasBold = false
            if let fontAttribute = selectedText.runs.first?.font {
                #if os(macOS)
                let boldFont = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
                #else
                let boldFont = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
                #endif
                hasBold = fontAttribute == Font(boldFont as CTFont)
            }
            
            // Toggle bold on the selection
            for run in selectedText.runs {
                let range = run.range
                if hasBold {
                    text[range].font = nil
                } else {
                    text[range].font = .body.bold()
                }
            }
        }
    }
    
    private func toggleConcept() {
        // Use transform to maintain selection
        text.transform(updating: &selection) { text in
            let selectedText = text[selection]
            
            // Check if the selected text already has concept attribute
            let hasConcept = selectedText.runs.first?.concept ?? false
            
            // Toggle concept on the selection
            for run in selectedText.runs {
                let range = run.range
                text[range].concept = !hasConcept
            }
        }
    }
    
    private func performCompletion() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Get the text from start to cursor position or selected text
            let plainText: String
            if let range = selection.range {
                // If there's a selection, use text up to the selection
                let textUpToCursor = text[text.startIndex..<range.upperBound]
                plainText = String(textUpToCursor.characters)
            } else {
                // Use the entire text
                plainText = String(text.characters)
            }
            
            let completion = try await openAI.complete(text: plainText)
            
            // Insert at cursor position
            await MainActor.run {
                text.transform(updating: &selection) { text in
                    let insertionPoint = selection.range?.upperBound ?? text.endIndex
                    text.insert(AttributedString(completion), at: insertionPoint)
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
} 