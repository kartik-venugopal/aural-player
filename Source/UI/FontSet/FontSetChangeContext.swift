import Foundation

/*
    An object that temporarily holds font settings used when applying a new customized font set to the app. It is used by the font set customization dialog when the user makes changes and clicks "Apply changes".
 */
class FontSetChangeContext {
    
    var textFontName: String = Fonts.Standard.mainFont_8.fontName
    var headingFontName: String = Fonts.Standard.captionFont_13.fontName
}
