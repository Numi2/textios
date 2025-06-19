# WWDC25 Text Editor Enhancements Tasks
Our design system embraces Apple's modern glass morphism aesthetic while maintaining clarity and usability. We focus on creating a warm, trustworthy, and professional experience 
This document outlines the tasks to enhance the `textios` app with rich text editing capabilities using the new SwiftUI features for `TextEditor` and `AttributedString`.

## Task 1: Update Document Model for Rich Text

1.  Open `WritingApp/WritingAppDocument.swift`.
2.  Change the `story` property from `var story: String` to `var story: AttributedString`.
3.  Update the `init(text:)` initializer to accept an `AttributedString`. The default value should be an empty `AttributedString`.
4.  Update `init(configuration:)` to decode `AttributedString`. A simple approach is to try to initialize from RTF or a plain string as a fallback. For this exercise, we will use a custom `com.example.writingapp.archive` format using `Codable` support for `AttributedString`.
    - You'll need to register a new `UTType` for this format.
    - The new type should conform to `public.data`.
5.  Update `fileWrapper(configuration:)` to encode the `AttributedString` into data.

## Task 2: Update Views to Use AttributedString

1.  In `WritingApp/Views/StoryView.swift`, ensure the `TextEditor` is correctly bound to the `story` `AttributedString` in the document.
2.  In `WritingApp/Views/StorySheet.swift`, modify the `story` property to be of type `AttributedString` and update the `Text` view to display it.
3.  In `WritingApp/WritingApp.swift`, when creating a new document, it should be initialized with some default styled text using `AttributedString`.

## Task 3: Define Custom Attributes

1.  Create a new file `WritingApp/Extensions/CustomAttributes.swift`.
2.  In this file, define a new `struct` called `ConceptAttribute` that conforms to `CodableAttributedStringKey`. Its `Value` should be a `Bool` and `name` should be `"com.example.writingapp.concept"`.
3.  Extend `AttributeScopes` with a `CustomAttributes` struct that includes the new `concept` attribute.
4.  Extend `AttributeDynamicLookup` to make the custom attribute available via dynamic member lookup.

## Task 4: Create a Formatting Toolbar

1.  Create a new SwiftUI View file `WritingApp/Views/FormattingToolbar.swift`.
2.  This view will contain buttons to apply formatting. For a start, add a button to toggle "bold" and a button to mark text as a "concept" using the `ConceptAttribute`.
3.  The toolbar will need bindings to the `AttributedString` and the `AttributedTextSelection`.

## Task 5: Integrate Formatting Toolbar

1.  In `WritingApp/Views/StoryView.swift`, add a ` @State private var selection = AttributedTextSelection()`
2.  Pass the selection to the `TextEditor` via the `selection` parameter.
3.  Add the `FormattingToolbar` to the view hierarchy, passing the necessary bindings (`$document.story` and `$selection`). A good place would be as an `inputAccessoryView` on iOS or as part of the toolbar on macOS. For simplicity, you can add it in the `VStack`.
4.  Implement the logic in `FormattingToolbar.swift` to apply attributes to the selected text range. Use `text.transform(updating: &selection)` to ensure selection is updated correctly after modification.

## Task 6: Define Custom Formatting Rules

1.  Create a new file `WritingApp/Formatting/RecipeFormattingDefinition.swift`.
2.  Define a `struct` `StoryFormattingDefinition` that conforms to `AttributedTextFormattingDefinition`.
3.  Inside, define a `Scope` that includes `SwiftUIAttributes` and our `CustomAttributes`.
4.  Create a value constraint `ConceptHighlight` that conforms to `AttributedTextValueConstraint`. This constraint will set the `foregroundColor` to `.orange` if the `concept` attribute is present.
5.  Add `ConceptHighlight` to the body of `StoryFormattingDefinition`.
6.  In `StoryView.swift`, apply this definition to the `TextEditor` using the `.attributedTextFormattingDefinition()` view modifier.

## Task 7: Add OpenAI Dependency

dependencies: [
    .package(url: "https://github.com/MacPaw/OpenAI.git", branch: "main")
]

## Task 8: Implement OpenAI Service

1.  Create a new directory `WritingApp/Services`.
2.  Create a new file `WritingApp/Services/OpenAIService.swift`.
3.  In this file, create a class `OpenAIService` to handle communication with the OpenAI API.
4.  Add a method `getCompletion(for text: String, completion: @escaping (Result<String, Error>) -> Void)`.
5.  let openAI = OpenAI(apiToken: "YOUR_TOKEN_HERE")
6.  Use the non-streaming Basic (closure-based non-streaming) would look like this:

let client = OpenAI(apiToken: "")
let response = client.responses.createResponse(query: query) { (result: Result<ResponseObject, Error>) in
    switch result {
    case .success(let responseObject):
        break
    case .failure(let error):
        break
    }
}
client.responses is a an instance of ResponsesEndpointProtocol type. It has streaming/non-streaming methods, that have closure-based/async/Combine variations. See more information in Chats section, as createResponse and createResponseStreaming methods of ResponsesEndpointProtocol are following the design and form of chats and chatsStream methods of OpenAIProtocol.



## Task 9: Integrate Autocomplete Feature

1.  In `WritingApp/Views/FormattingToolbar.swift`, add a new "Complete" button.
2.  This button will be responsible for triggering the AI-powered autocompletion.
3.  In `FormattingToolbar.swift`, add a new method to handle the autocomplete action.
    -   When the button is tapped, get the plain string content of the `AttributedString`.
    -   Call the `OpenAIService` to fetch the completion.
    -   On receiving a successful response, create an `AttributedString` from the result.
    -   Use `text.transform(updating: &selection)` to insert the new `AttributedString` at the current selection point. This will ensure the cursor moves to the end of the newly inserted text.
    -   Handle any potential errors from the API call, for example, by showing an alert to the user.
4.  The `FormattingToolbar` will need a way to present alerts, so it might need to be adjusted to support that (e.g., via a binding). 