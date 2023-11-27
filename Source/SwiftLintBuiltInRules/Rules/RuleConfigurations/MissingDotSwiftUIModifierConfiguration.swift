import SwiftLintCore

@AutoApply
struct MissingDotSwiftUIModifierConfiguration: SeverityBasedRuleConfiguration {
    
    typealias Parent = MissingDotSwiftUIModifierRule

    @ConfigurationElement(key: "severity")
    private(set) var severityConfiguration = SeverityConfiguration<Parent>(.error)
    
    @ConfigurationElement(key: "additional_modifiers")
    private(set) var additionalModifiers: [String] = []
    
}
