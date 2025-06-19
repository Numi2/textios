/*

Abstract:
The main entry point into this app.
*/

import SwiftUI

// - Tag : AppBody
@main
struct WritingApp: App {
    var body: some Scene {
        #if os(iOS)
        DocumentGroupLaunchScene("Writing App") {
            NewDocumentButton("Start Writing")
        } background: {
            Image(.pinkJungle)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        } overlayAccessoryView: { _ in
            AccessoryView()
        }
        #endif
        DocumentGroup(newDocument: createNewDocument()) { file in
            StoryView(document: file.$document)
        }
    }
    
    private func createNewDocument() -> WritingAppDocument {
        var welcomeText = AttributedString("Welcome to Writing App! ")
        welcomeText.font = .largeTitle
        var startWriting = AttributedString("Start writing your story...")
        startWriting.foregroundColor = .secondary
        welcomeText += startWriting
        return WritingAppDocument(text: welcomeText)
    }
}
