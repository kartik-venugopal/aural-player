function charsetTryit(tryitCol, decimalCol, entityCol, hexadecimalCol) {
    var trs, l, ll, ent, dec, hexa;
    var tables = document.getElementsByClassName("charset-tryit");
    for (i = 0; i < tables.length; i++) {
        trs = tables[i].getElementsByTagName("tr");
        ll = trs.length;
        for (ii = 0; ii < ll; ii++) {
            if (trs[ii].getElementsByTagName("td").length > 0) {
                if (decimalCol != -1) {
                    dec = trs[ii].getElementsByTagName("td")[decimalCol].innerHTML;
                    if (dec.indexOf("-") > -1) {continue; }
                    dec = dec.replace("&amp;", "");
                    dec = dec.replace("#", "");
                    dec = dec.replace(";", "");
                }
                if (entityCol != -1) {
                    ent = trs[ii].getElementsByTagName("td")[entityCol].innerHTML;
                }
                if (hexadecimalCol != -1) {
                    hexa = trs[ii].getElementsByTagName("td")[hexadecimalCol].innerHTML;
                    if (hexa.indexOf("+") > -1) { hexa = "";}
                    if (hexa.indexOf(" ") > -1) { hexa = "";}
                }
                //alink = '<a target="_blank" class="w3-btn btnsmall" href="tryit.asp?filename='
                alink = '<a target="_blank" class="w3-btn btnsmall" href="tryit.asp?deci=';
                if (dec && dec != "" && dec != "&nbsp;") {
                    alink += dec;
                }
                if (ent && ent != "" && ent != "&nbsp;") {
                    ent = ent.replace("&amp;", "");
                    ent = ent.replace(";", "");                    
                    alink += '&ent=' + ent;
                }
                if (decimalCol == -1 && hexa != "" && hexa != "&nbsp;") {
                    alink += '&hexa=' + hexa;
                }
                alink += '">Try it</a>'; 
                trs[ii].getElementsByTagName("td")[tryitCol].innerHTML = trs[ii].getElementsByTagName("td")[tryitCol].innerHTML + alink;
            }
        }
    }
}