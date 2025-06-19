/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
The document type.
*/

import SwiftUI
import UniformTypeIdentifiers

struct WritingAppDocument: FileDocument {

    // Define the document type this app loads.
    // - Tag: ContentType
    static var readableContentTypes: [UTType] { [.writingAppArchive] }
    
    var story: AttributedString

    init(text: AttributedString = AttributedString()) {
        self.story = text
    }

    // Load a file's contents into the document.
    // - Tag: DocumentInit
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        // Try to decode as our custom archive format
        let decoder = JSONDecoder()
        do {
            story = try decoder.decode(AttributedString.self, from: data)
        } catch {
            // Fallback: try to read as plain text
            if let string = String(data: data, encoding: .utf8) {
                story = AttributedString(string)
            } else {
                throw CocoaError(.fileReadCorruptFile)
            }
        }
    }

    // Saves the document's data to a file.
    // - Tag: FileWrapper
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(story)
        return .init(regularFileWithContents: data)
    }
}

