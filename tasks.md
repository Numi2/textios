# WWDC25 Text Editor Enhancements Tasks
Our design system embraces Apple's modern glass morphism aesthetic while maintaining clarity and usability. We focus on creating a warm, trustworthy, and professional experience 
This document outlines the tasks to enhance the `textios` app with rich text editing capabilities using the new SwiftUI features for `TextEditor` and `AttributedString`.

## Task 1: Fix Document Model UTType Implementation

1. Open `WritingApp/Extensions/UTType+WritingApp.swift`
2. Remove the unused `writingAppDocument` UTType definition
3. Ensure `writingAppArchive` properly declares it conforms to `.data` and has a unique identifier
4. In `WritingApp/WritingAppDocument.swift`, the implementation is already correct but verify that `readableContentTypes` uses `[.writingAppArchive]`

## Task 2: Update Views to Use AttributedString

1. In `WritingApp/Views/StoryView.swift`:
   - The TextEditor binding is incorrect. Based on WWDC25 documentation, TextEditor now supports AttributedString binding
   - Add: `@State private var selection = AttributedTextSelection()`
   - Change TextEditor to: `TextEditor(text: $document.story, selection: $selection)`

2. In `WritingApp/Views/StorySheet.swift`:
   - Change `var story: String` to `var story: AttributedString`
   - Change `Text(story)` to handle AttributedString (Text view supports AttributedString)

3. In `WritingApp/WritingApp.swift`:
   - When creating a new document, initialize with styled text:
   ```swift
   var welcomeText = AttributedString("Welcome to Writing App! ")
   welcomeText.font = .largeTitle
   var startWriting = AttributedString("Start writing your story...")
   startWriting.foregroundColor = .secondary
   welcomeText += startWriting
   ```

## Task 3: Define Custom Attributes

1. Create a new file `WritingApp/Extensions/CustomAttributes.swift`
2. Define `ConceptAttribute` following the WWDC25 pattern:
   ```swift
   struct ConceptAttribute: CodableAttributedStringKey {
       typealias Value = Bool
       static let name = "com.example.writingapp.concept"
       
       // Important: Add these constraints for proper behavior
       static let inheritedByAddedText = false
       static let invalidationConditions: Set<AttributedString.AttributeInvalidationCondition>? = [.textChanged]
   }
   ```
3. Extend `AttributeScopes` with `CustomAttributes` struct that includes the `concept` attribute
4. Extend `AttributeDynamicLookup` to enable dynamic member lookup (following the WWDC25 example exactly)

## Task 4: Create a Formatting Toolbar

1. Create `WritingApp/Views/FormattingToolbar.swift`
2. Structure:
   ```swift
   struct FormattingToolbar: View {
       @Binding var text: AttributedString
       @Binding var selection: AttributedTextSelection
       
       var body: some View {
           HStack {
               // Bold button
               Button("Bold") {
                   toggleBold()
               }
               
               // Concept button  
               Button("Concept") {
                   toggleConcept()
               }
           }
           .buttonStyle(GlassButtonStyle()) // Use design system
       }
       
       private func toggleBold() {
           // Important: Use transform to maintain selection
           text.transform(updating: &selection) { text in
               let selectedText = text[selection]
               // Toggle bold attribute logic
           }
       }
   }
   ```

## Task 5: Integrate Formatting Toolbar

1. In `WritingApp/Views/StoryView.swift`:
   - Add `@State private var selection = AttributedTextSelection()` (if not already added in Task 2)
   - Update TextEditor: `TextEditor(text: $document.story, selection: $selection)`
   
2. Add FormattingToolbar to the view:
   ```swift
   VStack {
       FormattingToolbar(text: $document.story, selection: $selection)
           .padding(.horizontal)
       
       TextEditor(text: $document.story, selection: $selection)
           // ... existing modifiers
   }
   ```
   
3. For iOS, consider using `.toolbar` with `.keyboard` placement for better UX

## Task 6: Define Custom Formatting Rules

1. Create `WritingApp/Formatting/StoryFormattingDefinition.swift`
2. Follow the WWDC25 pattern exactly:
   ```swift
   struct StoryFormattingDefinition: AttributedTextFormattingDefinition {
       struct Scope: AttributeScope {
           let foregroundColor: AttributeScopes.SwiftUIAttributes.ForegroundColorAttribute
           let font: AttributeScopes.SwiftUIAttributes.FontAttribute
           let concept: ConceptAttribute
       }
       
       var body: some AttributedTextFormattingDefinition<Scope> {
           ConceptHighlight()
       }
   }
   
   struct ConceptHighlight: AttributedTextValueConstraint {
       typealias Scope = StoryFormattingDefinition.Scope
       typealias AttributeKey = AttributeScopes.SwiftUIAttributes.ForegroundColorAttribute
       
       func constrain(_ container: inout Attributes) {
           if container.concept == true {
               container.foregroundColor = .orange
           }
       }
   }
   ```
3. Apply using `.attributedTextFormattingDefinition(StoryFormattingDefinition())`

## Task 7: Add OpenAI Dependency (Completed)
This has been added to Package.swift
dependencies: [
    .package(url: "https://github.com/MacPaw/OpenAI.git", branch: "main")
]

## Task 8: Implement OpenAI Service

1. Create `WritingApp/Services/OpenAIService.swift`
2. Use environment variable or secure storage for API key:
   ```swift
   class OpenAIService: ObservableObject {
       private let client: OpenAI
       
       init() {
           // Never hardcode API keys
           guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
               fatalError("Set OPENAI_API_KEY environment variable")
           }
           self.client = OpenAI(apiToken: apiKey)
       }
       
       func complete(text: String) async throws -> String {
           // Use chat completions, not responses endpoint
           let query = ChatQuery(messages: [
               .init(role: .user, content: text)
           ], model: .gpt3_5Turbo)
           
           let result = try await client.chats(query: query)
           return result.choices.first?.message.content ?? ""
       }
   }
   ```

## Task 9: Integrate Autocomplete Feature

1. Update FormattingToolbar with async handling:
   ```swift
   @StateObject private var openAI = OpenAIService()
   @State private var isLoading = false
   @State private var errorMessage: String?
   
   Button("Complete") {
       Task {
           await performCompletion()
       }
   }
   .disabled(isLoading)
   
   private func performCompletion() async {
       isLoading = true
       defer { isLoading = false }
       
       do {
           let plainText = String(text[selection].characters)
           let completion = try await openAI.complete(text: plainText)
           
           // Insert at cursor position
           await MainActor.run {
               text.transform(updating: &selection) { text in
                   let insertionPoint = selection.range?.upperBound ?? text.endIndex
                   text.insert(AttributedString(completion), at: insertionPoint)
               }
           }
       } catch {
           errorMessage = error.localizedDescription
       }
   }
   ``` 