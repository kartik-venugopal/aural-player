//
//  HTMLWriter.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A utility that allows easy construction of an HTML document and its export to a file.
///
class HTMLWriter {
    
    private static let entities: [(text: String, entity: String)] = [
        
        ("&", "&amp;"),
        ("<", "&lt;"),
        (">", "&gt;"),
        ("\r", ""),
        ("\n", "<br>"),
        ("'", "&apos;"),
        ("©", "&copy;"),
        ("®", "&reg;"),
        ("™", "&tm;"),
        ("’", "&prime;"),
        ("´", "&acute;"),
        ("\"", "&quot;"),
        ("`", "&grave;"),
        ("—", "&#45;"),
        ("-", "&#8209;"),
        ("–", "&#8210;"),
        ("‘", "&backprime;")
        
        ]
    
    private var data: String = "<html>\n"
    
    func addTitle(_ title: String) {
        data.append(String(format: "\t<head><title>%@</title></head>\n", textToHTML(title)))
    }
    
    func addHeading(_ heading: String, _ size: Int, _ underlined: Bool = false) {
        
        if underlined {
            data.append(String(format: "\t<h%d><u>%@</u></h%d>\n", size, textToHTML(heading), size))
        } else {
            data.append(String(format: "\t<h%d>%@</h%d>\n", size, textToHTML(heading), size))
        }
    }
    
    func addParagraph(_ text: HTMLText) {
        
        let _text = String(format: "\t\t\t%@%@%@%@%@%@%@\n", text.underlined ? "<u>" : "", text.bold ? "<b>" : "", text.italic ? "<i>" : "", textToHTML(text.text), text.underlined ? "</u>" : "", text.bold ? "</b>" : "", text.italic ? "</i>" : "")
        
        data.append(String(format: "\t<p>%@</p>\n", _text))
    }
    
    func addImage(_ srcPath: String, _ altText: String) {
        data.append(String(format: "\t<img src=\"%@\" alt=\"%@\">\n", srcPath, altText))
    }
    
    private func textToHTML(_ string: String) -> String {
        
        var htmlString = string
        
        for (text, entity) in HTMLWriter.entities {
            htmlString = htmlString.replacingOccurrences(of: text, with: entity)
        }
        
        return htmlString
    }
    
    func addTable(_ heading: String, _ headingSize: Int, _ columnHeaders: [String]?, _ rows: [[HTMLText]],
                  _ horizPadding: Int = 0, _ vertPadding: Int = 0) {

        // Table heading
        data.append(String(format: "\t<h%d><u>%@</u></h%d>\n", headingSize, heading, headingSize))
        
        // Column headers
        data.append(String(format: "\t<table>\n"))
        
        if let headers = columnHeaders {
            
            data.append(String(format: "\t\t<tr>\n"))
            
            for header in headers {
                data.append(String(format: "\t\t\t<th>%@</th>\n", header))
            }
            
            data.append(String(format: "\t\t</tr>\n"))
        }
        
        // Table body
        for row in rows {
        
            data.append(String(format: "\t\t<tr>\n"))
            
            for column in row {
                
                let widthMarkup = column.width != nil ? String(format: "width:%dpx;", column.width!) : ""
                let hPaddingMarkup = horizPadding > 0 ? String(format: "padding-right:%dpx;", horizPadding) : ""
                let vPaddingMarkup = vertPadding > 0 ? String(format: "padding-bottom:%dpx", vertPadding) : ""
                
                let tdMarkup = String(format: " style=\"%@%@%@\"", widthMarkup, hPaddingMarkup, vPaddingMarkup)
                
                data.append(String(format: "\t\t\t<td%@>%@%@%@%@%@%@%@</td>\n", tdMarkup, column.underlined ? "<u>" : "", column.bold ? "<b>" : "", column.italic ? "<i>" : "", textToHTML(column.text), column.underlined ? "</u>" : "", column.bold ? "</b>" : "", column.italic ? "</i>" : ""))
            }
            
            data.append(String(format: "\t\t</tr>\n"))
        }
        
        data.append(String(format: "\t</table>\n"))
    }
    
    func writeToFile(_ file: URL, _ failSilently: Bool = false) throws {
        
        data.append("</html>")
        
        do {
            
            try data.write(to: file, atomically: false, encoding: String.Encoding.utf8)
            
        } catch let error as NSError {
            
            if failSilently {
                NSLog("Error writing HTML object to file: %@", error.description)
            } else {
                throw HTMLWriteError(description: error.description)
            }
        }
    }
}

struct HTMLText {
    
    let text: String
    
    let underlined: Bool
    let bold: Bool
    let italic: Bool
    
    let width: Int?
}


class HTMLWriteError: DisplayableError {
    
    var description: String
    
    init(description: String) {
        
        self.description = description
        super.init("Error writing HTML object to file")
    }
}
