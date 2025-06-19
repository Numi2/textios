/*
Custom formatting rules for the story editor.
*/

import SwiftUI

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
    
    func constrain(_ container: inout AttributeContainer<Scope>) {
        if container.concept == true {
            container.foregroundColor = .orange
        }
    }
} 