import Foundation

class LanguageCodes {
    
    private init() {}
    
    static func languageNameForCode(_ code: String) -> String? {
        return map[code]
    }
    
    private static let map: [String: String] = {
        
        var map: [String: String] = [:]
        
        map["af"] = "Afrikaans"
        map["ar-ae"] = "Arabic (U.A.E.)"
        map["ar-bh"] = "Arabic (Kingdom of Bahrain)"
        map["ar-dz"] = "Arabic (Algeria)"
        map["ar-eg"] = "Arabic (Egypt)"
        map["ar-iq"] = "Arabic (Iraq)"
        map["ar-jo"] = "Arabic (Jordan)"
        map["ar-kw"] = "Arabic (Kuwait)"
        map["ar-lb"] = "Arabic (Lebanon)"
        map["ar-ly"] = "Arabic (Libya)"
        map["ar-ma"] = "Arabic (Morocco)"
        map["ar-om"] = "Arabic (Oman)"
        map["ar-qa"] = "Arabic (Qatar)"
        map["ar-sa"] = "Arabic (Saudi Arabia)"
        map["ar-sy"] = "Arabic (Syria)"
        map["ar-tn"] = "Arabic (Tunisia)"
        map["ar-ye"] = "Arabic (Yemen)"
        map["ar"] = "Arabic"
        map["as"] = "Assamese"
        map["az"] = "Azerbaijani"
        map["be"] = "Belarusian"
        map["bg"] = "Bulgarian"
        map["bn"] = "Bangla"
        map["ca"] = "Catalan"
        map["cs"] = "Czech"
        map["da"] = "Danish"
        map["de-at"] = "German (Austria)"
        map["de-ch"] = "German (Switzerland)"
        map["de-li"] = "German (Liechtenstein)"
        map["de-lu"] = "German (Luxembourg)"
        map["de"] = "German (Germany)"
        map["div"] = "Divehi"
        map["el"] = "Greek"
        map["en-au"] = "English (Australia)"
        map["en-bz"] = "English (Belize)"
        map["en-ca"] = "English (Canada)"
        map["en-gb"] = "English (United Kingdom)"
        map["en-ie"] = "English (Ireland)"
        map["en-jm"] = "English (Jamaica)"
        map["en-nz"] = "English (New Zealand)"
        map["en-ph"] = "English (Philippines)"
        map["en-tt"] = "English (Trinidad)"
        map["en-us"] = "English (United States)"
        map["en-za"] = "English (South Africa)"
        map["en-zw"] = "English (Zimbabwe)"
        map["en"] = "English"
        map["es-ar"] = "Spanish (Argentina)"
        map["es-bo"] = "Spanish (Bolivia)"
        map["es-cl"] = "Spanish (Chile)"
        map["es-co"] = "Spanish (Colombia)"
        map["es-cr"] = "Spanish (Costa Rica)"
        map["es-do"] = "Spanish (Dominican Republic)"
        map["es-ec"] = "Spanish (Ecuador)"
        map["es-gt"] = "Spanish (Guatemala)"
        map["es-hn"] = "Spanish (Honduras)"
        map["es-mx"] = "Spanish (Mexico)"
        map["es-ni"] = "Spanish (Nicaragua)"
        map["es-pa"] = "Spanish (Panama)"
        map["es-pe"] = "Spanish (Peru)"
        map["es-pr"] = "Spanish (Puerto Rico)"
        map["es-py"] = "Spanish (Paraguay)"
        map["es-sv"] = "Spanish (El Salvador)"
        map["es-us"] = "Spanish (United States)"
        map["es-uy"] = "Spanish (Uruguay)"
        map["es-ve"] = "Spanish (Venezuela)"
        map["es"] = "Spanish"
        map["et"] = "Estonian"
        map["eu"] = "Basque (Basque)"
        map["fa"] = "Persian"
        map["fi"] = "Finnish"
        map["fo"] = "Faeroese"
        map["fr-be"] = "French (Belgium)"
        map["fr-ca"] = "French (Canada)"
        map["fr-ch"] = "French (Switzerland)"
        map["fr-lu"] = "French (Luxembourg)"
        map["fr-mc"] = "French (Monaco)"
        map["fr"] = "French (France)"
        map["gd"] = "Scottish Gaelic"
        map["gl"] = "Galician"
        map["gu"] = "Gujarati"
        map["he"] = "Hebrew"
        map["hi"] = "Hindi"
        map["hr"] = "Croatian"
        map["hu"] = "Hungarian"
        map["hy"] = "Armenian"
        map["id"] = "Indonesian"
        map["is"] = "Icelandic"
        map["it-ch"] = "Italian (Switzerland)"
        map["it"] = "Italian (Italy)"
        map["ja"] = "Japanese"
        map["ka"] = "Georgian"
        map["kk"] = "Kazakh"
        map["kn"] = "Kannada"
        map["ko"] = "Korean"
        map["kok"] = "Konkani"
        map["kz"] = "Kyrgyz"
        map["lt"] = "Lithuanian"
        map["lv"] = "Latvian"
        map["mk"] = "Macedonian (FYROM)"
        map["ml"] = "Malayalam"
        map["mn"] = "Mongolian (Cyrillic)"
        map["mr"] = "Marathi"
        map["ms"] = "Malay"
        map["mt"] = "Maltese"
        map["nb-no"] = "Norwegian (Bokmal)"
        map["ne"] = "Nepali (India)"
        map["nl-be"] = "Dutch (Belgium)"
        map["nl"] = "Dutch (Netherlands)"
        map["nn-no"] = "Norwegian (Nynorsk)"
        map["no"] = "Norwegian (Bokmal)"
        map["or"] = "Odia"
        map["pa"] = "Punjabi"
        map["pl"] = "Polish"
        map["pt-br"] = "Portuguese (Brazil)"
        map["pt"] = "Portuguese (Portugal)"
        map["rm"] = "Rhaeto-Romanic"
        map["ro-md"] = "Romanian (Moldova)"
        map["ro"] = "Romanian"
        map["ru-md"] = "Russian (Moldova)"
        map["ru"] = "Russian"
        map["sa"] = "Sanskrit"
        map["sb"] = "Sorbian"
        map["sk"] = "Slovak"
        map["sl"] = "Slovenian"
        map["sq"] = "Albanian"
        map["sr"] = "Serbian"
        map["sv-fi"] = "Swedish (Finland)"
        map["sv"] = "Swedish"
        map["sw"] = "Swahili"
        map["sx"] = "Sutu"
        map["syr"] = "Syriac"
        map["ta"] = "Tamil"
        map["te"] = "Telugu"
        map["th"] = "Thai"
        map["tn"] = "Tswana"
        map["tr"] = "Turkish"
        map["ts"] = "Tsonga"
        map["tt"] = "Tatar"
        map["uk"] = "Ukrainian"
        map["ur"] = "Urdu"
        map["uz"] = "Uzbek"
        map["vi"] = "Vietnamese"
        map["xh"] = "Xhosa"
        map["yi"] = "Yiddish"
        map["zh-cn"] = "Chinese (China)"
        map["zh-hk"] = "Chinese (Hong Kong SAR)"
        map["zh-mo"] = "Chinese (Macao SAR)"
        map["zh-sg"] = "Chinese (Singapore)"
        map["zh-tw"] = "Chinese (Taiwan)"
        map["zh"] = "Chinese"
        map["zu"] = "Zulu"
        
        return map
        
    }()
}
