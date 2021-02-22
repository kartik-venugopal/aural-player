import Foundation

/*
    An object that temporarily holds font settings used when applying a new customized font scheme to the app. It is used by the font scheme customization dialog when the user makes changes and clicks "Apply changes".
 */
class FontSchemeChangeContext {
    
    var textFontName: String = Fonts.Standard.mainFont_8.fontName
    var headingFontName: String = Fonts.Standard.captionFont_13.fontName
}
