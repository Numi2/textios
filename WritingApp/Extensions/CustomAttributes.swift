/*
Custom attributes for the WritingApp text editor.
*/

import SwiftUI

// Define a custom attribute for marking text as a "concept"
struct ConceptAttribute: CodableAttributedStringKey {
    typealias Value = Bool
    static let name = "com.example.writingapp.concept"
    
    // Important: Add these constraints for proper behavior
    static let inheritedByAddedText = false
    static let invalidationConditions: Set<AttributedString.AttributeInvalidationCondition>? = [.textChanged]
}

// Extend AttributeScopes to include our custom attributes
extension AttributeScopes {
    struct CustomAttributes: AttributeScope {
        let concept: ConceptAttribute
    }
    
    var customAttributes: CustomAttributes.Type { CustomAttributes.self }
}

// Extend AttributeDynamicLookup to enable dynamic member lookup
extension AttributeDynamicLookup {
    subscript<T: AttributedStringKey>(dynamicMember keyPath: KeyPath<AttributeScopes.CustomAttributes, T>) -> T {
        self[T.self]
    }
} 