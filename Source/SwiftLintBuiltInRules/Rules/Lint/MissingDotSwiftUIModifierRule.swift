import SwiftSyntax

@SwiftSyntaxRule
struct MissingDotSwiftUIModifierRule: Rule {
    
    var configuration = MissingDotSwiftUIModifierConfiguration()
    
    static let description = RuleDescription(
        identifier: "missing_dot_swiftui_modifier",
        name: "Missing Dot SwiftUI Modifier",
        description: "Missing leading dot in SwiftUI modifiers",
        kind: .lint,
        nonTriggeringExamples: [
            Example("""
            struct ContentView: View {
                var body: some View {
                    Text("Hello World")
                        .padding()
                }
            }
            """)
        ],
        triggeringExamples: [
            Example("""
            struct ContentView: View {
                var body: some View {
                    Text("Hello World")
                        padding()
                }
            }
            """)
        ].skipWrappingInCommentTests()
    )
    
}

private extension MissingDotSwiftUIModifierRule {
    
    final class Visitor: ViolationsSyntaxVisitor<ConfigurationType> {
        
        override var skippableDeclarations: [any DeclSyntaxProtocol.Type] {
            [
                ActorDeclSyntax.self,
                ClassDeclSyntax.self,
                InitializerDeclSyntax.self,
                ProtocolDeclSyntax.self,
                SubscriptDeclSyntax.self,
            ]
        }
        
        override func visit(_ node: DoStmtSyntax) -> SyntaxVisitorContinueKind {
            return .skipChildren
        }
        
        override func visit(_ node: CatchClauseSyntax) -> SyntaxVisitorContinueKind {
            return .skipChildren
        }
        
        override func visit(_ node: ConditionElementListSyntax) -> SyntaxVisitorContinueKind {
            return .skipChildren
        }
        
        override func visit(_ node: AwaitExprSyntax) -> SyntaxVisitorContinueKind {
            return .skipChildren
        }
        
        override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
            guard node.signature.returnClause?.type.trimmedDescription == "some View" else { return .skipChildren }
            report(node)
            return .visitChildren
            
        }
        
        override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
            guard node.bindings.first?.typeAnnotation?.type.trimmedDescription == "some View" else { return .skipChildren }
            report(node)
            return .visitChildren
        }
        
        //        override func visit(_ node: ClosureExprSyntax) -> SyntaxVisitorContinueKind {
        //            print("visit closure")
        //            isVisitingBlock = true
        //            lastVisitedTypeDeclReferenceExprSyntax = nil
        //            return .visitChildren
        //        }
        //
        //        override func visitPost(_ node: ClosureExprSyntax) {
        //            print("visit post closure")
        //            isVisitingBlock = false
        //        }
        //
        //        override func visit(_ node: AccessorBlockSyntax) -> SyntaxVisitorContinueKind {
        //            print("visit closure")
        //            isVisitingBlock = true
        //            lastVisitedTypeDeclReferenceExprSyntax = nil
        //            return .visitChildren
        //        }
        //
        //        override func visitPost(_ node: AccessorBlockSyntax) {
        //            print("visit post closure")
        //            isVisitingBlock = false
        //        }
        //
        //        override func visit(_ node: CodeBlockSyntax) -> SyntaxVisitorContinueKind {
        //            print("visit closure")
        //            isVisitingBlock = true
        //            lastVisitedTypeDeclReferenceExprSyntax = nil
        //            return .visitChildren
        //        }
        //
        //        override func visitPost(_ node: CodeBlockSyntax) {
        //            print("visit post closure")
        //            isVisitingBlock = false
        //        }
        
        override func visitPost(_ node: DeclReferenceExprSyntax) {
            
            report(node)
            
            guard checkDeclIsValid(node) else { return }
            
            if node.previousToken(viewMode: .sourceAccurate)?.text == "switch" { return }
            
            if node.previousToken(viewMode: .sourceAccurate)?.text != ".", node.previousToken(viewMode: .sourceAccurate)?.text != "(", node.previousToken(viewMode: .sourceAccurate)?.text != ":" {
                
                if node.nextToken(viewMode: .sourceAccurate)?.text != "(", node.nextToken(viewMode: .sourceAccurate)?.text != "{" { return }
                
                violations.append(
                    ReasonedRuleViolation(
                        position: node.positionAfterSkippingLeadingTrivia,
                        reason: "Missing '\(node.baseName.text)' leading dot"
                    )
                )
                
            }
            
        }
        
        func checkDeclIsValid(_ node: DeclReferenceExprSyntax) -> Bool {
            MissingDotSwiftUIModifierRule.swiftuiModifiers.contains(node.baseName.text) || Set(configuration.additionalModifiers).contains(node.baseName.text)
        }
        
        func report(_ node: some SyntaxProtocol) {
            violations.append(
                ReasonedRuleViolation(
                    position: node.positionAfterSkippingLeadingTrivia,
                    reason: "visited",
                    severity: .warning
                )
            )
        }
        
    }
    
}

private extension MissingDotSwiftUIModifierRule {
    
    static let swiftuiModifiers: Set<String> = [
        "_addingBackgroundGroup",
        "_addingBackgroundLayer",
        "_automaticPadding",
        "_colorMatrix",
        "_colorMonochrome",
        "_containerShape",
        "_cover",
        "_defaultContext",
        "_detached",
        "_identified",
        "_ignoresAutomaticPadding",
        "_lineHeightMultiple",
        "_listLinkedGroup",
        "_navigationDestination",
        "_onBindingChange",
        "_onButtonGesture",
        "_onEnvironmentChange",
        "_prefersDefaultFocus",
        "_productDescriptionHidden",
        "_safeAreaInsets",
        "_scrollable",
        "_statusBar",
        "_statusBarHidden",
        "_tightPadding",
        "_trait",
        "_untagged",
        "accentColor",
        "accessibility",
        "accessibilityAction",
        "accessibilityActions",
        "accessibilityActivationPoint",
        "accessibilityAddTraits",
        "accessibilityAdjustableAction",
        "accessibilityChartDescriptor",
        "accessibilityChildren",
        "accessibilityCustomContent",
        "accessibilityDirectTouch",
        "accessibilityElement",
        "accessibilityFocused",
        "accessibilityHeading",
        "accessibilityHidden",
        "accessibilityHint",
        "accessibilityIdentifier",
        "accessibilityIgnoresInvertColors",
        "accessibilityInputLabels",
        "accessibilityLabel",
        "accessibilityLabeledPair",
        "accessibilityLinkedGroup",
        "accessibilityQuickAction",
        "accessibilityRemoveTraits",
        "accessibilityRepresentation",
        "accessibilityRespondsToUserInteraction",
        "accessibilityRotor",
        "accessibilityRotorEntry",
        "accessibilityScrollAction",
        "accessibilityShowsLargeContentViewer",
        "accessibilitySortPriority",
        "accessibilityTextContentType",
        "accessibilityValue",
        "accessibilityZoomAction",
        "actionSheet",
        "addPassToWalletButtonStyle",
        "alert",
        "alignmentGuide",
        "allowedDynamicRange",
        "allowsHitTesting",
        "allowsTightening",
        "alternatingRowBackgrounds",
        "anchorPreference",
        "animation",
        "appStoreOverlay",
        "aspectRatio",
        "autocapitalization",
        "autocorrectionDisabled",
        "background",
        "backgroundPreferenceValue",
        "backgroundStyle",
        "badge",
        "badgeProminence",
        "baselineOffset",
        "blendMode",
        "blur",
        "bold",
        "border",
        "brightness",
        "buttonBorderShape",
        "buttonRepeatBehavior",
        "buttonStyle",
        "clipShape",
        "clipped",
        "colorEffect",
        "colorInvert",
        "colorMultiply",
        "colorScheme",
        "compositingGroup",
        "confirmationDialog",
        "containerBackground",
        "containerRelativeFrame",
        "containerShape",
        "contentMargins",
        "contentShape",
        "contentTransition",
        "contextMenu",
        "contrast",
        "controlGroupStyle",
        "controlSize",
        "coordinateSpace",
        "copyable",
        "cornerRadius",
        "cuttable",
        "datePickerStyle",
        "defaultAppStorage",
        "defaultFocus",
        "defaultHoverEffect",
        "defaultScrollAnchor",
        "defaultWheelPickerItemHeight",
        "defersSystemGestures",
        "deleteDisabled",
        "dialogIcon",
        "dialogSeverity",
        "dialogSuppressionToggle",
        "digitalCrownAccessory",
        "digitalCrownRotation",
        "disableAutocorrection",
        "disabled",
        "disclosureGroupStyle",
        "distortionEffect",
        "draggable",
        "drawingGroup",
        "dropDestination",
        "dynamicTypeSize",
        "edgesIgnoringSafeArea",
        "environment",
        "environmentObject",
        "equatable",
        "exportableToServices",
        "exportsItemProviders",
        "fileDialogBrowserOptions",
        "fileDialogConfirmationLabel",
        "fileDialogCustomizationID",
        "fileDialogDefaultDirectory",
        "fileDialogImportsUnresolvedAliases",
        "fileDialogMessage",
        "fileExporter",
        "fileExporterFilenameLabel",
        "fileImporter",
        "fileMover",
        "findDisabled",
        "findNavigator",
        "fixedSize",
        "flipsForRightToLeftLayoutDirection",
        "focusEffectDisabled",
        "focusScope",
        "focusSection",
        "focusable",
        "focused",
        "focusedObject",
        "focusedSceneObject",
        "focusedSceneValue",
        "focusedValue",
        "font",
        "fontDesign",
        "fontWeight",
        "fontWidth",
        "foregroundColor",
        "foregroundStyle",
        "formStyle",
        "frame",
        "fullScreenCover",
        "gaugeStyle",
        "geometryGroup",
        "gesture",
        "grayscale",
        "gridCellAnchor",
        "gridCellColumns",
        "gridCellUnsizedAxes",
        "gridColumnAlignment",
        "groupBoxStyle",
        "handlesExternalEvents",
        "headerProminence",
        "help",
        "hidden",
        "highPriorityGesture",
        "horizontalRadioGroupLayout",
        "hoverEffect",
        "hoverEffectDisabled",
        "hueRotation",
        "id",
        "ignoresSafeArea",
        "imageScale",
        "importableFromServices",
        "importsItemProviders",
        "indexViewStyle",
        "inspector",
        "inspectorColumnWidth",
        "interactionActivityTrackingTag",
        "interactiveDismissDisabled",
        "invalidatableContent",
        "italic",
        "itemProvider",
        "kerning",
        "keyboardShortcut",
        "keyboardType",
        "labelStyle",
        "labeledContentStyle",
        "labelsHidden",
        "layerEffect",
        "layoutDirectionBehavior",
        "layoutPriority",
        "layoutValue",
        "lineLimit",
        "lineSpacing",
        "listItemTint",
        "listRowBackground",
        "listRowHoverEffect",
        "listRowHoverEffectDisabled",
        "listRowInsets",
        "listRowPlatterColor",
        "listRowSeparator",
        "listRowSeparatorTint",
        "listRowSpacing",
        "listSectionSeparator",
        "listSectionSeparatorTint",
        "listSectionSpacing",
        "listStyle",
        "lookAroundViewer",
        "luminanceToAlpha",
        "manageSubscriptionsSheet",
        "mapCameraKeyframeAnimator",
        "mapControlVisibility",
        "mapControls",
        "mapFeatureSelectionContent",
        "mapFeatureSelectionDisabled",
        "mapScope",
        "mapStyle",
        "mask",
        "matchedGeometryEffect",
        "menuActionDismissBehavior",
        "menuButtonStyle",
        "menuIndicator",
        "menuOrder",
        "menuStyle",
        "minimumScaleFactor",
        "modelContainer",
        "modelContext",
        "modifier",
        "monospaced",
        "monospacedDigit",
        "moveDisabled",
        "multilineTextAlignment",
        "musicSubscriptionOffer",
        "navigationBarBackButtonHidden",
        "navigationBarHidden",
        "navigationBarItems",
        "navigationBarTitle",
        "navigationBarTitleDisplayMode",
        "navigationDestination",
        "navigationDocument",
        "navigationSplitViewColumnWidth",
        "navigationSplitViewStyle",
        "navigationSubtitle",
        "navigationTitle",
        "navigationViewStyle",
        "offerCodeRedemption",
        "offset",
        "onAppear",
        "onChange",
        "onCommand",
        "onContinueUserActivity",
        "onContinuousHover",
        "onCopyCommand",
        "onCutCommand",
        "onDeleteCommand",
        "onDisappear",
        "onDrag",
        "onDrop",
        "onExitCommand",
        "onHover",
        "onKeyPress",
        "onLongPressGesture",
        "onLongTouchGesture",
        "onMapCameraChange",
        "onMoveCommand",
        "onOpenURL",
        "onPasteCommand",
        "onPlayPauseCommand",
        "onPreferenceChange",
        "onReceive",
        "onSubmit",
        "onTapGesture",
        "opacity",
        "ornament",
        "overlay",
        "overlayPreferenceValue",
        "padding",
        "pageCommand",
        "paletteSelectionEffect",
        "pasteDestination",
        "payLaterViewAction",
        "payLaterViewDisplayStyle",
        "payWithApplePayButtonStyle",
        "persistentSystemOverlays",
        "phaseAnimator",
        "photosPicker",
        "photosPickerAccessoryVisibility",
        "photosPickerDisabledCapabilities",
        "photosPickerStyle",
        "pickerStyle",
        "popover",
        "position",
        "preference",
        "preferredColorScheme",
        "prefersDefaultFocus",
        "presentationBackground",
        "presentationBackgroundInteraction",
        "presentationCompactAdaptation",
        "presentationContentInteraction",
        "presentationCornerRadius",
        "presentationDetents",
        "presentationDragIndicator",
        "presentedWindowStyle",
        "presentedWindowToolbarStyle",
        "previewContext",
        "previewDevice",
        "previewDisplayName",
        "previewInterfaceOrientation",
        "previewLayout",
        "privacySensitive",
        "productIconBorder",
        "productViewStyle",
        "progressViewStyle",
        "projectionEffect",
        "quickLookPreview",
        "redacted",
        "refundRequestSheet",
        "renameAction",
        "replaceDisabled",
        "rotation3DEffect",
        "rotationEffect",
        "safeAreaInset",
        "safeAreaPadding",
        "saturation",
        "scaleEffect",
        "scaledToFill",
        "scaledToFit",
        "scenePadding",
        "scrollBounceBehavior",
        "scrollClipDisabled",
        "scrollContentBackground",
        "scrollDisabled",
        "scrollDismissesKeyboard",
        "scrollIndicators",
        "scrollIndicatorsFlash",
        "scrollPosition",
        "scrollTargetBehavior",
        "scrollTargetLayout",
        "searchCompletion",
        "searchDictationBehavior",
        "searchScopes",
        "searchSuggestions",
        "searchable",
        "selectionDisabled",
        "sensoryFeedback",
        "shadow",
        "sheet",
        "shortcutsLinkStyle",
        "signInWithAppleButtonStyle",
        "simultaneousGesture",
        "siriTipViewStyle",
        "speechAdjustedPitch",
        "speechAlwaysIncludesPunctuation",
        "speechAnnouncementsQueued",
        "speechSpellsOutCharacters",
        "springLoadingBehavior",
        "statusBar",
        "statusBarHidden",
        "storeButton",
        "strikethrough",
        "submitLabel",
        "submitScope",
        "subscriptionStoreButtonLabel",
        "subscriptionStoreControlBackground",
        "subscriptionStoreControlIcon",
        "subscriptionStoreControlStyle",
        "subscriptionStorePickerItemBackground",
        "subscriptionStorePolicyDestination",
        "subscriptionStorePolicyForegroundStyle",
        "subscriptionStoreSignInAction",
        "swipeActions",
        "symbolEffect",
        "symbolEffectsRemoved",
        "symbolRenderingMode",
        "symbolVariant",
        "tabItem",
        "tabViewStyle",
        "tableColumnHeaders",
        "tableStyle",
        "tag",
        "textCase",
        "textContentType",
        "textEditorStyle",
        "textFieldStyle",
        "textInputAutocapitalization",
        "textScale",
        "textSelection",
        "tint",
        "toggleStyle",
        "toolbar",
        "toolbarBackground",
        "toolbarColorScheme",
        "toolbarRole",
        "toolbarTitleDisplayMode",
        "toolbarTitleMenu",
        "touchBar",
        "touchBarCustomizationLabel",
        "touchBarItemPresence",
        "touchBarItemPrincipal",
        "tracking",
        "transaction",
        "transformAnchorPreference",
        "transformEffect",
        "transformEnvironment",
        "transformPreference",
        "transition",
        "truncationMode",
        "typeSelectEquivalent",
        "typesettingLanguage",
        "underline",
        "unredacted",
        "userActivity",
        "verifyIdentityWithWalletButtonStyle",
        "workoutPreview",
        "zIndex",
    ]
    
}
