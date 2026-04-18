import SwiftUI

// Typography tokens. Falls back gracefully if Fraunces isn't installed.
// To use Fraunces, drop the .ttf into the project and list it in Info.plist UIAppFonts.
enum LunaType {
    // Serif display (Fraunces). Falls back to .serif system font.
    static let displayXL  = Font.custom("Fraunces-SemiBold",  size: 44, relativeTo: .largeTitle).weight(.semibold)
    static let displayL   = Font.custom("Fraunces-SemiBold",  size: 34, relativeTo: .title).weight(.semibold)
    static let displayM   = Font.custom("Fraunces-Medium",    size: 26, relativeTo: .title2).weight(.medium)
    static let displayS   = Font.custom("Fraunces-Medium",    size: 20, relativeTo: .title3).weight(.medium)

    // Body (Inter or SF Pro fallback). Inter not required.
    static let bodyL      = Font.custom("Inter-Regular", size: 17, relativeTo: .body)
    static let bodyM      = Font.custom("Inter-Regular", size: 15, relativeTo: .callout)
    static let bodyS      = Font.custom("Inter-Regular", size: 13, relativeTo: .footnote)

    // Metadata — tiny, confident.
    static let metaM      = Font.custom("Inter-Medium",   size: 12, relativeTo: .caption).weight(.medium)
    static let metaS      = Font.custom("Inter-Medium",   size: 11, relativeTo: .caption2).weight(.medium)

    // Emphasis variants
    static let emphasis   = Font.custom("Fraunces-Italic", size: 17, relativeTo: .body).italic()
}
