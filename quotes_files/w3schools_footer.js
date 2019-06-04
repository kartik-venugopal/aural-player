if (typeof k42 == "undefined") {k42 = false;}
if (k42 == true) {
/*
  const debounce = (func, delay) => {
    let inDebounce
    return function() {
      const context = this
      const args = arguments
      clearTimeout(inDebounce)
      inDebounce = setTimeout(() => func.apply(context, args), delay)
    }
  }
*/
  var k42ResizeFunc;
  function k42Resizing() {
    clearTimeout(k42ResizeFunc);
    k42ResizeFunc = setTimeout(browserResize, 500);
  }
  
  if (window.addEventListener) {              
    window.addEventListener("resize", k42Resizing);
//  window.addEventListener("resize", debounce(browserResize, 500));
  } else if (window.attachEvent) {                 
    window.attachEvent("resize", k42Resizing);
//    window.attachEvent("resize", debounce(browserResize, 500));
  }
} else {
  if (window.addEventListener) {              
    window.addEventListener("resize", browserResize);
  } else if (window.attachEvent) {                 
    window.attachEvent("onresize", browserResize);
  }
}
var xbeforeResize = window.innerWidth;
var ybeforeResize = window.innerWidth;
var zbeforeResize = window.innerWidth;
var sbeforeResize = window.innerWidth;
var abeforeResize = window.innerWidth;
function skyscraperResize() {
  if (k42 == true) {
    if (window.innerWidth < 975 + 17 && document.getElementById("snhb-wide_skyscraper-0")) {
      document.getElementById("snhb-wide_skyscraper-0").style.minHeight="0";
    }
  } else {
    if (window.innerWidth < 975 + 17 && document.getElementById("div-gpt-ad-1422003450156-5")) {
      document.getElementById("div-gpt-ad-1422003450156-5").style.minHeight="0";
    }
  }
}
function browserResize() {
  if (k42 == true) {
    if (Number(w3_getStyleValue(document.getElementById("main"), "height").replace("px", "")) > 2200) {
      if (document.getElementById("snhb-mid_content-0")) {
        snhb.queue.push(function(){  snhb.startAuction(["main_leaderboard", "wide_skyscraper", "mid_content", "sidebar_sticky", "bottom_medium_rectangle", "right_bottom_medium_rectangle"]); });
      }
      else {
        snhb.queue.push(function(){  snhb.startAuction(["main_leaderboard", "wide_skyscraper", "sidebar_sticky", "bottom_medium_rectangle", "right_bottom_medium_rectangle"]); });
      }
    }
    else {
        if (document.getElementById("snhb-mid_content-0")) {
          snhb.queue.push(function(){  snhb.startAuction(["main_leaderboard", "wide_skyscraper", "mid_content", "bottom_medium_rectangle", "right_bottom_medium_rectangle"]); });
        }
      else {
        snhb.queue.push(function(){  snhb.startAuction(["main_leaderboard", "wide_skyscraper", "bottom_medium_rectangle", "right_bottom_medium_rectangle"]); });
      }
    }
  } else {
    var afterResize = window.innerWidth;
    if ((xbeforeResize < (1450 + 14) && afterResize >= (1450 + 14)) || (xbeforeResize >= (1450 + 14) && afterResize < (1450 + 14)) ||
      (xbeforeResize < (700 + 14) && afterResize >= (700 + 14)) || (xbeforeResize >= (700 + 14) && afterResize < (700 + 14)) ||
      (xbeforeResize < (480 + 17) && afterResize >= (480 + 17)) ||(xbeforeResize >= (480 + 17) && afterResize < (480 + 17))) {
      xbeforeResize = afterResize;
      googletag.cmd.push(function() {
        googletag.pubads().refresh([gptAdSlots[0]]);
      });
    }
    if ((ybeforeResize < (1675 + 14) && afterResize >= (1675 + 14)) || (ybeforeResize >= (1675 + 14) && afterResize < (1675 + 14)) ||
      (ybeforeResize < (1100 + 14) && afterResize >= (1100 + 14)) || (ybeforeResize >= (1100 + 14) && afterResize < (1100 + 14)) ||
      (ybeforeResize < (975 + 17) && afterResize >= (975 + 17)) || (ybeforeResize >= (975 + 17) && afterResize < (975 + 17))) {
      ybeforeResize = afterResize;
        skyscraperResize()
      googletag.cmd.push(function() {
        googletag.pubads().refresh([gptAdSlots[1]]);
      });
    }
    if ((zbeforeResize < (1240 + 14) && afterResize >= (1240 + 14)) || (zbeforeResize >= (1240 + 14) && afterResize < (1240 + 14))) {
      zbeforeResize = afterResize;
      googletag.cmd.push(function() {
        googletag.pubads().refresh([gptAdSlots[2], gptAdSlots[3]]);
      });
    }
    if ((sbeforeResize < (1675 + 14) && afterResize >= (1675 + 14)) || (sbeforeResize >= (1675 + 14) && afterResize < (1675 + 14)) ||
      (sbeforeResize < (1100 + 14) && afterResize >= (1100 + 14)) || (sbeforeResize >= (1100 + 14) && afterResize < (1100 + 14)) ||
      (sbeforeResize < (975 + 17) && afterResize >= (975 + 17)) || (sbeforeResize >= (975 + 17) && afterResize < (975 + 17))) {
      sbeforeResize = afterResize;
      googletag.cmd.push(function() {
        googletag.pubads().refresh([gptAdSlots[4]]);
      });
    }
    if ((abeforeResize < (1440 + 14) && afterResize >= (1440 + 14)) || (abeforeResize >= (1440 + 14) && afterResize < (1440 + 14)) ||
      (abeforeResize < (1135 + 14) && afterResize >= (1135 + 14)) || (abeforeResize >= (1135 + 14) && afterResize < (1135 + 14)) ||
      (abeforeResize < (993 + 14) && afterResize >= (993 + 14)) || (abeforeResize >= (993 + 14) && afterResize < (993 + 14)) ||
      (abeforeResize < (750 + 14) && afterResize >= (1135 + 14)) || (abeforeResize >= (750 + 14) && afterResize < (750 + 14)) ||
      (abeforeResize < (490 + 17) && afterResize >= (490 + 17)) || (abeforeResize >= (490 + 17) && afterResize < (490 + 17))) {
      abeforeResize = afterResize;
      googletag.cmd.push(function() {
        googletag.pubads().refresh([gptAdSlots[5]]);
      });
    }
  }
}
skyscraperResize();
function open_menu() {
  var x, m;
  m = (document.getElementById("leftmenu") || document.getElementById("sidenav"));
  if (m.style.display == "block") {
    close_menu();
  } else {
    w3_close_all_nav();  
    m.style.display = "block";
    if (document.getElementsByClassName) {
      x = document.getElementsByClassName("chapter")
      for (i = 0; i < x.length; i++) {
        x[i].style.visibility = "hidden";
      }
      x = document.getElementsByClassName("nav")
      for (i = 0; i < x.length; i++) {
        x[i].style.visibility = "hidden";
      }
      x = document.getElementsByClassName("sharethis")
      for (i = 0; i < x.length; i++) {
        x[i].style.visibility = "hidden";
      }
    }
    fix_sidemenu();
  }
}
function close_menu() {
  var m;
  m = (document.getElementById("leftmenu") || document.getElementById("sidenav"));
  m.style.display = "none";  
  if (document.getElementsByClassName) {
    x = document.getElementsByClassName("chapter")
    for (i = 0; i < x.length; i++) {
      x[i].style.visibility = "visible";
    }
    x = document.getElementsByClassName("nav")
    for (i = 0; i < x.length; i++) {
      x[i].style.visibility = "visible";
    }
    x = document.getElementsByClassName("sharethis")
    for (i = 0; i < x.length; i++) {
      x[i].style.visibility = "visible";
    }            
  }
}
if (window.addEventListener) {
  window.addEventListener("scroll", function () {fix_sidemenu(); });
  window.addEventListener("resize", function () {fix_sidemenu(); });  
  window.addEventListener("touchmove", function () {fix_sidemenu(); });  
  window.addEventListener("load", function () {fix_sidemenu(); });
} else if (window.attachEvent) {
  window.attachEvent("onscroll", function () {fix_sidemenu(); });
  window.attachEvent("onresize", function () {fix_sidemenu(); });  
  window.attachEvent("ontouchmove", function () {fix_sidemenu(); });
  window.attachEvent("onload", function () {fix_sidemenu(); });
}
function fix_sidemenu() {
  var w, top;
  w = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
  top = scrolltop()    
  if (w < 993 && w > 600) {
    if (top == 0) {
      document.getElementById("sidenav").style.top = "144px";
    }
    if (top > 0 && top < 100) {
      document.getElementById("sidenav").style.top = (144 - top) + "px";      
    }
    if (top > 100) {
      document.getElementById("sidenav").style.top = document.getElementById("topnav").offsetHeight + "px";
      document.getElementById("belowtopnav").style.paddingTop = "44px";    
      document.getElementById("topnav").style.position = "fixed";    
      document.getElementById("topnav").style.top = "0";
      document.getElementById("googleSearch").style.position = "fixed";
      document.getElementById("googleSearch").style.top = "0";
      document.getElementById("google_translate_element").style.position = "fixed";
      document.getElementById("google_translate_element").style.top = "0";
    } else {
      document.getElementById("belowtopnav").style.paddingTop = "0";
      document.getElementById("topnav").style.position = "relative";
      document.getElementById("googleSearch").style.position = "absolute";
      document.getElementById("googleSearch").style.top = "";
      document.getElementById("google_translate_element").style.position = "absolute";
      document.getElementById("google_translate_element").style.top = "";
    }
    document.getElementById("leftmenuinner").style.paddingTop = "0"; //SCROLLNYTT
  } else {
    if (top == 0) {
      document.getElementById("sidenav").style.top = "112px";      
    }
    if (top > 0 && top < 66) {
      document.getElementById("sidenav").style.top = (112 - top) + "px";      
    }
    if (top > 66) {
      document.getElementById("sidenav").style.top = "44px";
      if (w > 992) {document.getElementById("leftmenuinner").style.paddingTop = "44px";} //SCROLLNYTT
      document.getElementById("belowtopnav").style.paddingTop = "44px";    
      document.getElementById("topnav").style.position = "fixed";
      document.getElementById("topnav").style.top = "0";
      document.getElementById("googleSearch").style.position = "fixed";
      document.getElementById("googleSearch").style.top = "0";
      document.getElementById("google_translate_element").style.position = "fixed";
      document.getElementById("google_translate_element").style.top = "0";
    } else {
      if (w > 992) { document.getElementById("leftmenuinner").style.paddingTop = (112 - top) + "px";} //SCROLLNYTT
      document.getElementById("belowtopnav").style.paddingTop = "0";
      document.getElementById("topnav").style.position = "relative";
      document.getElementById("googleSearch").style.position = "absolute";
      document.getElementById("googleSearch").style.top = "";
      document.getElementById("google_translate_element").style.position = "absolute";
      document.getElementById("google_translate_element").style.top = "";
    }
  }
}
function sidemenuitemintoview() {
  var a, b, i = 0;
  a = document.getElementById("leftmenuinnerinner");
  if (!a || !a.getElementsByClassName) {return false;}
  b = a.getElementsByClassName("active");
  if (b.length < 1) {return false;}  
  while (!isIntoView(a, b[0])) {
    i++
    if (i > 1000) {break;}
    a.scrollTop += 10;
  }
}
function isIntoView(x, y) {
  var a = x.scrollTop;
  var b = a + window.innerHeight;
  var ytop = y.offsetTop;
  var ybottom = ytop + 140;
  return ((ybottom <= b) && (ytop >= a));
}
function scrolltop() {
  var top = 0;
  if (typeof(window.pageYOffset) == "number") {
    top = window.pageYOffset;
  } else if (document.body && document.body.scrollTop) {
    top = document.body.scrollTop;
  } else if (document.documentElement && document.documentElement.scrollTop) {
    top = document.documentElement.scrollTop;
  }
  return top;
}
function open_translate(elmnt) {
  var a = document.getElementById("google_translate_element");
  if (a.style.display == "") {
    a.style.display = "none";
    elmnt.innerHTML = "&#xe801;";
  } else {
    a.style.display = "";
    if (window.innerWidth > 500) {
      a.style.width = "40%";
    } else {
      a.style.width = "100%";
    }
    elmnt.innerHTML = "<span style='font-family:verdana;font-weight:bold;'>X</span>";
  }
}
function open_search(elmnt) {
  var a = document.getElementById("googleSearch");
  if (a.style.display == "") {
    a.style.display = "none";
    a.style.paddingRight = "";
    elmnt.innerHTML = "&#xe802;";    
  } else {
    a.style.display = "";  
    if (window.innerWidth > 700) {
      a.style.width = "40%";
    } else {
      a.style.width = "80%";
    }
    if (document.getElementById("gsc-i-id1")) {document.getElementById("gsc-i-id1").focus(); }
    elmnt.innerHTML = "<span style='font-family:verdana;font-weight:bold;'>X</span>";
  }
}
function w3_open_nav(x) {
  var contentNode, h, menuHeight;
  if (document.getElementById("nav_" + x).style.display == "block") {
    w3_close_nav(x);
  } else {
    w3_close_all_nav();
    document.getElementById("nav_" + x).style.display = "block";    
    if (document.getElementById("topnavbtn_" + x)) {
      document.getElementById("topnavbtn_" + x).getElementsByTagName("i")[0].style.display = "none";
      document.getElementById("topnavbtn_" + x).getElementsByTagName("i")[1].style.display = "inline";        
      //document.getElementById("nav_" + x).getElementsByTagName("h3")[0].focus();
    }
  }
  h = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
  menuHeight = document.getElementById("nav_" + x).offsetHeight;
  if (menuHeight > h) {
    document.getElementById("nav_" + x).style.height = (h - 106) + "px";
  }
}
function w3_close_nav(x) {
  document.getElementById("nav_" + x).style.display = "none";
  if (document.getElementById("topnavbtn_" + x)) {
    document.getElementById("topnavbtn_" + x).getElementsByTagName("i")[0].style.display = "inline";
    document.getElementById("topnavbtn_" + x).getElementsByTagName("i")[1].style.display = "none";        
    document.getElementById("nav_" + x).style.height = "";
  }
}
function w3_close_all_nav() {
  w3_close_all_topnav();
  close_menu();
}
function w3_close_all_topnav() {
  w3_close_nav("tutorials");
  w3_close_nav("references");
  w3_close_nav("examples");
}
(function () {
  var x, i, a, b, c, d, m;
  m = (document.getElementById("leftmenu") || document.getElementById("sidenav"));
  x = m.getElementsByTagName("A");
  d = document.location.href;
  for (i = 0; i < x.length; i++) {
    if (d.indexOf(x[i].href) >= 0) {
      x[i].className = "active";
      if (x[i].parentElement.className.indexOf("ref_overview") > -1) {
        x[i].parentElement.style.display="block";
      }
     } else if (d.indexOf("/tags/att_") > -1) {
       c = d.substring(d.indexOf("/tags/att_") + 10, d.lastIndexOf("_"));
       if (x[i].href == d.substr(0, d.indexOf("/tags/")) + "/tags/tag_" + c + ".asp") {
         x[i].className = "active";
       }
     } else if (d.indexOf("/howto/default_page") > -1) {
       if (x[i].href.indexOf("default.asp") > -1) {
         x[i].className = "active";
       }
     }
  }
  sidemenuitemintoview()
  x = document.getElementById("topnav").getElementsByTagName("A");
  for (i = 0; i < x.length; i++) {
    a = document.location.pathname;
    b = x[i].pathname;
    if ((x[i].parentNode.tagName == "LI" || x[i].parentNode.className.indexOf("w3-bar") > -1) && a.substr(0, a.indexOf("/",1)) ==  b.substr(0, b.indexOf("/",1))) {
      x[i].className += " active";
    }
  }
  if (window.addEventListener) { 
    document.getElementById("main").addEventListener("click", w3_close_all_nav, true);
    m.addEventListener("click", w3_close_all_topnav, true);
    document.getElementById("right").addEventListener("click", w3_close_all_nav, true);
    document.getElementById("main").addEventListener("wheel", w3_close_all_nav, true);
    document.getElementById("main").addEventListener("touchstart", w3_close_all_nav, true);
  } else if (window.attachEvent) {         
    document.getElementById("main").attachEvent("onclick", w3_close_all_nav);
    m.attachEvent("onclick", w3_close_all_topnav);
    document.getElementById("right").attachEvent("onclick", w3_close_all_nav);
  }
  if ('ontouchstart' in window || 'onmsgesturechange' in window) {
    document.getElementById("leftmenuinnerinner").style.overflowY = "scroll";
  }
})();
(function() {
  var cx = '012971019331610648934:m2tou3_miwy';
  var gcse = document.createElement('script'); gcse.type = 'text/javascript'; gcse.async = true;
  gcse.src = (document.location.protocol == 'https:' ? 'https:' : 'http:') +
      '//www.google.com/cse/cse.js?cx=' + cx;
  var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(gcse, s);
})();
function searchfield_focus(obj) {
  obj.style.color = "";
  obj.style.fontStyle = "";
  if (obj.value == "Search w3schools.com") {obj.value = "";}
}
var addr = document.location.href;
function displayError() {
  document.getElementById("err_url").value = addr;
  document.getElementById("err_form").style.display = "block";
  document.getElementById("err_email").focus();
  hideSent();
}
function hideError() {
  document.getElementById("err_form").style.display = "none";
}
function hideSent() {
  document.getElementById("err_sent").style.display = "none";
}
function sendErr() {
  var xmlhttp;
  var err_url = document.getElementById("err_url").value;
  var err_email = document.getElementById("err_email").value;
  var err_desc = document.getElementById("err_desc").value;
  if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
    xmlhttp = new XMLHttpRequest();
  } else {// code for IE6, IE5
    xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
  }
  xmlhttp.open("POST", "/err_sup.asp", true);
  xmlhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
  xmlhttp.send("err_url=" + err_url + "&err_email=" + err_email + "&err_desc=" + escape(err_desc));
  document.getElementById("err_desc").value = "";
  hideError();
  document.getElementById("err_sent").style.display = "block";
}
function clickFBLike() {
  document.getElementById("fblikeframe").style.display = 'block';
  document.getElementById("popupDIV").innerHTML = "<iframe src='/fblike.asp?r=" + Math.random() + "' frameborder='no' style='height:200px;width:250px;'></iframe><br><button onclick='hideFBLike()' class='w3-btn w3-black'>Close</button>";
}
function hideFBLike() {
  document.getElementById("fblikeframe").style.display = 'none';
}
function googleTranslateElementInit() {
  new google.translate.TranslateElement({
    pageLanguage: 'en',
    autoDisplay: false,
    gaTrack: true,
    gaId: 'UA-3855518-1',
    layout: google.translate.TranslateElement.InlineLayout.SIMPLE
  }, 'google_translate_element');
}
function printPage() {
  var content = document.getElementById("main").innerHTML;
  var css = "", i, j, c = document.getElementById("main").cloneNode(true);
  for (i = 0; i < c.childNodes.length; i++) {
    if (c.childNodes[i].nodeType == 1 && (c.childNodes[i].getAttribute("id") == "mainLeaderboard" || c.childNodes[i].getAttribute("id") == "midcontentadcontainer")) {
      c.removeChild(c.childNodes[i]);
      content = c.innerHTML;
    }
  }
  var head = document.getElementsByTagName("head")[0].innerHTML;
  var myWindow=window.open('','','');
  myWindow.document.write("<html><head>"+head+"<style>body{padding:15px;}@media print {.printbtn {display:none;}}</style></head><body><button class='printbtn' onclick='window.print()'>Print Page</button><br><br>"+content+"<p><a href='/about/about_copyright.asp'>Copyright 1999-2018</a> by Refsnes Data. All Rights Reserved.</p></body></html>");
}
function openGoogleTranslate() {
  var d = "text/javascript",
    e = "text/css",
    f = "stylesheet",
    g = "script",
    h = "link",
    k = "head",
    l = "complete",
    m = "UTF-8",
    n = ".";
  document.getElementById("google_translate_element").innerHTML = "";

  function p(b) {
    var a = document.getElementsByTagName(k)[0];
    a || (a = document.body.parentNode.appendChild(document.createElement(k)));
    a.appendChild(b)
  }

  function _loadJs(b) {
    var a = document.createElement(g);
    a.type = d;
    a.charset = m;
    a.src = b;
    p(a)
  }

  function _loadCss(b) {
    var a = document.createElement(h);
    a.type = e;
    a.rel = f;
    a.charset = m;
    a.href = b;
    p(a)
  }

  function _isNS(b) {
    b = b.split(n);
    for (var a = window, c = 0; c < b.length; ++c)
      if (!(a = a[b[c]])) return !1;
    return !0
  }

  function _setupNS(b) {
    b = b.split(n);
    for (var a = window, c = 0; c < b.length; ++c) a.hasOwnProperty ? a.hasOwnProperty(b[c]) ? a = a[b[c]] : a = a[b[c]] = {} : a = a[b[c]] || (a[b[c]] = {});
    return a
  }
  window.addEventListener && "undefined" == typeof document.readyState && window.addEventListener("DOMContentLoaded", function() {
    document.readyState = l
  }, !1);
  if (_isNS('google.translate.Element')) {
    return
  }(function() {
    var c = _setupNS('google.translate._const');
    c._cl = 'no';
    c._cuc = 'googleTranslateElementInit';
    c._cac = '';
    c._cam = '';
    var h = 'translate.googleapis.com';
    var s = (true ? 'https' : window.location.protocol == 'https:' ? 'https' : 'http') + '://';
    var b = s + h;
    c._pah = h;
    c._pas = s;
    c._pbi = b + '/translate_static/img/te_bk.gif';
    c._pci = b + '/translate_static/img/te_ctrl3.gif';
    c._pli = b + '/translate_static/img/loading.gif';
    c._plla = h + '/translate_a/l';
    c._pmi = b + '/translate_static/img/mini_google.png';
    c._ps = b + '/translate_static/css/translateelement.css';
    c._puh = 'translate.google.com';
    _loadCss(c._ps);
    _loadJs(b + '/translate_static/js/element/main_no.js');
  })();
}
/* w3codecolor ver 1.31 by w3schools.com */
(
function w3CodeColor() {
var x, i, j, k, l, modes = ["html", "js", "java", "css", "sql", "python"];
if (!document.getElementsByClassName) {return;}
k = modes.length;
for (j = 0; j < k; j++) {
  x = document.getElementsByClassName(modes[j] + "High");
  l = x.length;
  for (i = 0; i < l; i++) {
    x[i].innerHTML = w3CodeColorize(x[i].innerHTML + " ", modes[j]);
  }
}
function w3CodeColorize(x, lang) {
  var tagcolor = "mediumblue";
  var tagnamecolor = "brown";
  var attributecolor = "red";
  var attributevaluecolor = "mediumblue";
  var commentcolor = "green";
  var cssselectorcolor = "brown";
  var csspropertycolor = "red";
  var csspropertyvaluecolor = "mediumblue";
  var cssdelimitercolor = "black";
  var cssimportantcolor = "red";  
  var jscolor = "black";
  var jskeywordcolor = "mediumblue";
  var jsstringcolor = "brown";
  var jsnumbercolor = "red";
  var jspropertycolor = "black";
  var javacolor = "black";
  var javakeywordcolor = "mediumblue";
  var javastringcolor = "brown";
  var javanumbercolor = "red";
  var javapropertycolor = "black";
  var phptagcolor = "red";
  var phpcolor = "black";
  var phpkeywordcolor = "mediumblue";
  var phpglobalcolor = "goldenrod";
  var phpstringcolor = "brown";
  var phpnumbercolor = "red";  
  var pythoncolor = "black";
  var pythonkeywordcolor = "mediumblue";
  var pythonstringcolor = "brown";
  var pythonnumbercolor = "red";  
  var angularstatementcolor = "red";
  var sqlcolor = "black";
  var sqlkeywordcolor = "mediumblue";
  var sqlstringcolor = "brown";
  var sqlnumbercolor = "";  
  if (!lang) {lang = "html"; }
  if (lang == "html") {return htmlMode(x);}
  if (lang == "css") {return cssMode(x);}
  if (lang == "js") {return jsMode(x);}
  if (lang == "java") {return javaMode(x);}
  if (lang == "php") {return phpMode(x);}
  if (lang == "sql") {return sqlMode(x);}  
  if (lang == "python") {return pythonMode(x);}
  return x;
  function extract(str, start, end, func, repl) {
    var s, e, d = "", a = [];
    while (str.search(start) > -1) {
      s = str.search(start);
      e = str.indexOf(end, s);
      if (e == -1) {e = str.length;}
      if (repl) {
        a.push(func(str.substring(s, e + (end.length))));      
        str = str.substring(0, s) + repl + str.substr(e + (end.length));
      } else {
        d += str.substring(0, s);
        d += func(str.substring(s, e + (end.length)));
        str = str.substr(e + (end.length));
      }
    }
    this.rest = d + str;
    this.arr = a;
  }
  function htmlMode(txt) {
    var rest = txt, done = "", php, comment, angular, startpos, endpos, note, i;
    php = new extract(rest, "&lt;\\?php", "?&gt;", phpMode, "W3PHPPOS");
    rest = php.rest;
    comment = new extract(rest, "&lt;!--", "--&gt;", commentMode, "W3HTMLCOMMENTPOS");
    rest = comment.rest;
    while (rest.indexOf("&lt;") > -1) {
      note = "";
      startpos = rest.indexOf("&lt;");
      if (rest.substr(startpos, 9).toUpperCase() == "&LT;STYLE") {note = "css";}
      if (rest.substr(startpos, 10).toUpperCase() == "&LT;SCRIPT") {note = "javascript";}        
      endpos = rest.indexOf("&gt;", startpos);
      if (endpos == -1) {endpos = rest.length;}
      done += rest.substring(0, startpos);
      done += tagMode(rest.substring(startpos, endpos + 4));
      rest = rest.substr(endpos + 4);
      if (note == "css") {
        endpos = rest.indexOf("&lt;/style&gt;");
        if (endpos > -1) {
          done += cssMode(rest.substring(0, endpos));
          rest = rest.substr(endpos);
        }
      }
      if (note == "javascript") {
        endpos = rest.indexOf("&lt;/script&gt;");
        if (endpos > -1) {
          done += jsMode(rest.substring(0, endpos));
          rest = rest.substr(endpos);
        }
      }
    }
    rest = done + rest;
    angular = new extract(rest, "{{", "}}", angularMode);
    rest = angular.rest;
    for (i = 0; i < comment.arr.length; i++) {
        rest = rest.replace("W3HTMLCOMMENTPOS", comment.arr[i]);
    }
    for (i = 0; i < php.arr.length; i++) {
        rest = rest.replace("W3PHPPOS", php.arr[i]);
    }
    return rest;
  }
  function tagMode(txt) {
    var rest = txt, done = "", startpos, endpos, result;
    while (rest.search(/(\s|<br>)/) > -1) {    
      startpos = rest.search(/(\s|<br>)/);
      endpos = rest.indexOf("&gt;");
      if (endpos == -1) {endpos = rest.length;}
      done += rest.substring(0, startpos);
      done += attributeMode(rest.substring(startpos, endpos));
      rest = rest.substr(endpos);
    }
    result = done + rest;
    result = "<span style=color:" + tagcolor + ">&lt;</span>" + result.substring(4);
    if (result.substr(result.length - 4, 4) == "&gt;") {
      result = result.substring(0, result.length - 4) + "<span style=color:" + tagcolor + ">&gt;</span>";
    }
    return "<span style=color:" + tagnamecolor + ">" + result + "</span>";
  }
  function attributeMode(txt) {
    var rest = txt, done = "", startpos, endpos, singlefnuttpos, doublefnuttpos, spacepos;
    while (rest.indexOf("=") > -1) {
      endpos = -1;
      startpos = rest.indexOf("=");
      singlefnuttpos = rest.indexOf("'", startpos);
      doublefnuttpos = rest.indexOf('"', startpos);
      spacepos = rest.indexOf(" ", startpos + 2);
      if (spacepos > -1 && (spacepos < singlefnuttpos || singlefnuttpos == -1) && (spacepos < doublefnuttpos || doublefnuttpos == -1)) {
        endpos = rest.indexOf(" ", startpos);      
      } else if (doublefnuttpos > -1 && (doublefnuttpos < singlefnuttpos || singlefnuttpos == -1) && (doublefnuttpos < spacepos || spacepos == -1)) {
        endpos = rest.indexOf('"', rest.indexOf('"', startpos) + 1);
      } else if (singlefnuttpos > -1 && (singlefnuttpos < doublefnuttpos || doublefnuttpos == -1) && (singlefnuttpos < spacepos || spacepos == -1)) {
        endpos = rest.indexOf("'", rest.indexOf("'", startpos) + 1);
      }
      if (!endpos || endpos == -1 || endpos < startpos) {endpos = rest.length;}
      done += rest.substring(0, startpos);
      done += attributeValueMode(rest.substring(startpos, endpos + 1));
      rest = rest.substr(endpos + 1);
    }
    return "<span style=color:" + attributecolor + ">" + done + rest + "</span>";
  }
  function attributeValueMode(txt) {
    return "<span style=color:" + attributevaluecolor + ">" + txt + "</span>";
  }
  function angularMode(txt) {
    return "<span style=color:" + angularstatementcolor + ">" + txt + "</span>";
  }
  function commentMode(txt) {
    return "<span style=color:" + commentcolor + ">" + txt + "</span>";
  }
  function cssMode(txt) {
    var rest = txt, done = "", s, e, comment, i, midz, c, cc;
    comment = new extract(rest, /\/\*/, "*/", commentMode, "W3CSSCOMMENTPOS");
    rest = comment.rest;
    while (rest.search("{") > -1) {
      s = rest.search("{");
      midz = rest.substr(s + 1);
      cc = 1;
      c = 0;
      for (i = 0; i < midz.length; i++) {
        if (midz.substr(i, 1) == "{") {cc++; c++}
        if (midz.substr(i, 1) == "}") {cc--;}
        if (cc == 0) {break;}
      }
      if (cc != 0) {c = 0;}
      e = s;
      for (i = 0; i <= c; i++) {
        e = rest.indexOf("}", e + 1);
      }
      if (e == -1) {e = rest.length;}
      done += rest.substring(0, s + 1);
      done += cssPropertyMode(rest.substring(s + 1, e));
      rest = rest.substr(e);
    }
    rest = done + rest;
    rest = rest.replace(/{/g, "<span style=color:" + cssdelimitercolor + ">{</span>");
    rest = rest.replace(/}/g, "<span style=color:" + cssdelimitercolor + ">}</span>");
    for (i = 0; i < comment.arr.length; i++) {
        rest = rest.replace("W3CSSCOMMENTPOS", comment.arr[i]);
    }
    return "<span style=color:" + cssselectorcolor + ">" + rest + "</span>";
  }
  function cssPropertyMode(txt) {
    var rest = txt, done = "", s, e, n, loop;
    if (rest.indexOf("{") > -1 ) { return cssMode(rest); }
    while (rest.search(":") > -1) {
      s = rest.search(":");
      loop = true;
      n = s;
      while (loop == true) {
        loop = false;
        e = rest.indexOf(";", n);
        if (rest.substring(e - 5, e + 1) == "&nbsp;") {
          loop = true;
          n = e + 1;
        }
      }
      if (e == -1) {e = rest.length;}
      done += rest.substring(0, s);
      done += cssPropertyValueMode(rest.substring(s, e + 1));
      rest = rest.substr(e + 1);
    }
    return "<span style=color:" + csspropertycolor + ">" + done + rest + "</span>";
  }
  function cssPropertyValueMode(txt) {
    var rest = txt, done = "", s;
    rest = "<span style=color:" + cssdelimitercolor + ">:</span>" + rest.substring(1);
    while (rest.search(/!important/i) > -1) {
      s = rest.search(/!important/i);
      done += rest.substring(0, s);
      done += cssImportantMode(rest.substring(s, s + 10));
      rest = rest.substr(s + 10);
    }
    result = done + rest;    
    if (result.substr(result.length - 1, 1) == ";" && result.substr(result.length - 6, 6) != "&nbsp;" && result.substr(result.length - 4, 4) != "&lt;" && result.substr(result.length - 4, 4) != "&gt;" && result.substr(result.length - 5, 5) != "&amp;") {
      result = result.substring(0, result.length - 1) + "<span style=color:" + cssdelimitercolor + ">;</span>";
    }
    return "<span style=color:" + csspropertyvaluecolor + ">" + result + "</span>";
  }
  function cssImportantMode(txt) {
    return "<span style=color:" + cssimportantcolor + ";font-weight:bold;>" + txt + "</span>";
  }
  function jsMode(txt) {
    var rest = txt, done = "", esc = [], i, cc, tt = "", sfnuttpos, dfnuttpos, compos, comlinepos, keywordpos, numpos, mypos, dotpos, y;
    for (i = 0; i < rest.length; i++)  {
      cc = rest.substr(i, 1);
      if (cc == "\\") {
        esc.push(rest.substr(i, 2));
        cc = "W3JSESCAPE";
        i++;
      }
      tt += cc;
    }
    rest = tt;
    y = 1;
    while (y == 1) {
      sfnuttpos = getPos(rest, "'", "'", jsStringMode);
      dfnuttpos = getPos(rest, '"', '"', jsStringMode);
      compos = getPos(rest, /\/\*/, "*/", commentMode);
      comlinepos = getPos(rest, /\/\//, "<br>", commentMode);      
      numpos = getNumPos(rest, jsNumberMode);
      keywordpos = getKeywordPos("js", rest, jsKeywordMode);
      dotpos = getDotPos(rest, jsPropertyMode);
      if (Math.max(numpos[0], sfnuttpos[0], dfnuttpos[0], compos[0], comlinepos[0], keywordpos[0], dotpos[0]) == -1) {break;}
      mypos = getMinPos(numpos, sfnuttpos, dfnuttpos, compos, comlinepos, keywordpos, dotpos);
      if (mypos[0] == -1) {break;}
      if (mypos[0] > -1) {
        done += rest.substring(0, mypos[0]);
        done += mypos[2](rest.substring(mypos[0], mypos[1]));
        rest = rest.substr(mypos[1]);
      }
    }
    rest = done + rest;
    for (i = 0; i < esc.length; i++) {
      rest = rest.replace("W3JSESCAPE", esc[i]);
    }
    return "<span style=color:" + jscolor + ">" + rest + "</span>";
  }
  function jsStringMode(txt) {
    return "<span style=color:" + jsstringcolor + ">" + txt + "</span>";
  }
  function jsKeywordMode(txt) {
    return "<span style=color:" + jskeywordcolor + ">" + txt + "</span>";
  }
  function jsNumberMode(txt) {
    return "<span style=color:" + jsnumbercolor + ">" + txt + "</span>";
  }
  function jsPropertyMode(txt) {
    return "<span style=color:" + jspropertycolor + ">" + txt + "</span>";
  }
  function getDotPos(txt, func) {
    var x, i, j, s, e, arr = [".","<", " ", ";", "(", "+", ")", "[", "]", ",", "&", ":", "{", "}", "/" ,"-", "*", "|", "%"];
    s = txt.indexOf(".");
    if (s > -1) {
      x = txt.substr(s + 1);
      for (j = 0; j < x.length; j++) {
        cc = x[j];
        for (i = 0; i < arr.length; i++) {
          if (cc.indexOf(arr[i]) > -1) {
            e = j;
            return [s + 1, e + s + 1, func];
          }
        }
      }
    }
    return [-1, -1, func];
  }
  function getMinPos() {
    var i, arr = [];
    for (i = 0; i < arguments.length; i++) {
      if (arguments[i][0] > -1) {
        if (arr.length == 0 || arguments[i][0] < arr[0]) {arr = arguments[i];}
      }
    }
    if (arr.length == 0) {arr = arguments[i];}
    return arr;
  }
  function javaMode(txt) {
    var rest = txt, done = "", esc = [], i, cc, tt = "", sfnuttpos, dfnuttpos, compos, comlinepos, keywordpos, numpos, mypos, dotpos, y;
    for (i = 0; i < rest.length; i++)  {
      cc = rest.substr(i, 1);
      if (cc == "\\") {
        esc.push(rest.substr(i, 2));
        cc = "W3JSESCAPE";
        i++;
      }
      tt += cc;
    }
    rest = tt;
    y = 1;
    while (y == 1) {
      sfnuttpos = getPos(rest, "'", "'", javaStringMode);
      dfnuttpos = getPos(rest, '"', '"', javaStringMode);
      compos = getPos(rest, /\/\*/, "*/", commentMode);
      comlinepos = getPos(rest, /\/\//, "<br>", commentMode);      
      numpos = getNumPos(rest, javaNumberMode);
      keywordpos = getKeywordPos("java", rest, javaKeywordMode);
      dotpos = getDotPos(rest, javaPropertyMode);
      if (Math.max(numpos[0], sfnuttpos[0], dfnuttpos[0], compos[0], comlinepos[0], keywordpos[0], dotpos[0]) == -1) {break;}
      mypos = getMinPos(numpos, sfnuttpos, dfnuttpos, compos, comlinepos, keywordpos, dotpos);
      if (mypos[0] == -1) {break;}
      if (mypos[0] > -1) {
        done += rest.substring(0, mypos[0]);
        done += mypos[2](rest.substring(mypos[0], mypos[1]));
        rest = rest.substr(mypos[1]);
      }
    }
    rest = done + rest;
    for (i = 0; i < esc.length; i++) {
      rest = rest.replace("W3JSESCAPE", esc[i]);
    }
    return "<span style=color:" + javacolor + ">" + rest + "</span>";
  }
  function javaStringMode(txt) {
    return "<span style=color:" + javastringcolor + ">" + txt + "</span>";
  }
  function javaKeywordMode(txt) {
    return "<span style=color:" + javakeywordcolor + ">" + txt + "</span>";
  }
  function javaNumberMode(txt) {
    return "<span style=color:" + javanumbercolor + ">" + txt + "</span>";
  }
  function javaPropertyMode(txt) {
    return "<span style=color:" + javapropertycolor + ">" + txt + "</span>";
  }
  function sqlMode(txt) {
    var rest = txt, y, done = "", sfnuttpos, dfnuttpos, compos, comlinepos, keywordpos, numpos, mypos;
    y = 1;
    while (y == 1) {
      sfnuttpos = getPos(rest, "'", "'", sqlStringMode);
      dfnuttpos = getPos(rest, '"', '"', sqlStringMode);
      compos = getPos(rest, /\/\*/, "*/", commentMode);
      comlinepos = getPos(rest, /--/, "<br>", commentMode);      
      numpos = getNumPos(rest, sqlNumberMode);
      keywordpos = getKeywordPos("sql", rest, sqlKeywordMode);
      if (Math.max(numpos[0], sfnuttpos[0], dfnuttpos[0], compos[0], comlinepos[0], keywordpos[0]) == -1) {break;}
      mypos = getMinPos(numpos, sfnuttpos, dfnuttpos, compos, comlinepos, keywordpos);
      if (mypos[0] == -1) {break;}
      if (mypos[0] > -1) {
        done += rest.substring(0, mypos[0]);
        done += mypos[2](rest.substring(mypos[0], mypos[1]));
        rest = rest.substr(mypos[1]);
      }
    }
    rest = done + rest;
    return "<span style=color:" + sqlcolor + ">" + rest + "</span>";
  }
  function sqlStringMode(txt) {
    return "<span style=color:" + sqlstringcolor + ">" + txt + "</span>";
  }
  function sqlKeywordMode(txt) {
    return "<span style=color:" + sqlkeywordcolor + ">" + txt + "</span>";
  }
  function sqlNumberMode(txt) {
    return "<span style=color:" + sqlnumbercolor + ">" + txt + "</span>";
  }
  function phpMode(txt) {
    var rest = txt, done = "", sfnuttpos, dfnuttpos, compos, comlinepos, comhashpos, keywordpos, mypos, y;
    y = 1;
    while (y == 1) {
      sfnuttpos = getPos(rest, "'", "'", phpStringMode);
      dfnuttpos = getPos(rest, '"', '"', phpStringMode);
      compos = getPos(rest, /\/\*/, "*/", commentMode);
      comlinepos = getPos(rest, /\/\//, "<br>", commentMode);      
      comhashpos = getPos(rest, "#", "<br>", commentMode);
      numpos = getNumPos(rest, phpNumberMode);
      keywordpos = getKeywordPos("php", rest, phpKeywordMode);      
      if (Math.max(numpos[0], sfnuttpos[0], dfnuttpos[0], compos[0], comlinepos[0], comhashpos[0], keywordpos[0]) == -1) {break;}
      mypos = getMinPos(numpos, sfnuttpos, dfnuttpos, compos, comlinepos, comhashpos, keywordpos);
      if (mypos[0] == -1) {break;}
      if (mypos[0] > -1) {
        done += rest.substring(0, mypos[0]);
        done += mypos[2](rest.substring(mypos[0], mypos[1]));
        rest = rest.substr(mypos[1]);
      }
    }
    rest = done + rest;
    rest = "<span style=color:" + phptagcolor + ">&lt;" + rest.substr(4, 4) + "</span>" + rest.substring(8);
    if (rest.substr(rest.length - 5, 5) == "?&gt;") {
      rest = rest.substring(0, rest.length - 5) + "<span style=color:" + phptagcolor + ">?&gt;</span>";
    }
    return "<span style=color:" + phpcolor + ">" + rest + "</span>";
  }
  function phpStringMode(txt) {
    return "<span style=color:" + phpstringcolor + ">" + txt + "</span>";
  }
  function phpNumberMode(txt) {
    return "<span style=color:" + phpnumbercolor + ">" + txt + "</span>";
  }
  function phpKeywordMode(txt) {
    var glb = ["$GLOBALS","$_SERVER","$_REQUEST","$_POST","$_GET","$_FILES","$_ENV","$_COOKIE","$_SESSION"];
    if (glb.indexOf(txt.toUpperCase()) > -1) {
      if (glb.indexOf(txt) > -1) {
        return "<span style=color:" + phpglobalcolor + ">" + txt + "</span>";
      } else {
        return txt;
      }
    } else {
      return "<span style=color:" + phpkeywordcolor + ">" + txt + "</span>";
    }
  }
  function pythonMode(txt) {
    var rest = txt, done = "", sfnuttpos, dfnuttpos, compos, comlinepos, comhashpos, keywordpos, mypos, y;
    y = 1;
    while (y == 1) {
      sfnuttpos = getPos(rest, "'", "'", pythonStringMode);
      dfnuttpos = getPos(rest, '"', '"', pythonStringMode);
      compos = getPos(rest, /\/\*/, "*/", commentMode);
      comlinepos = getPos(rest, /\/\//, "<br>", commentMode);      
      comhashpos = getPos(rest, "#", "<br>", commentMode);
      numpos = getNumPos(rest, pythonNumberMode);
      keywordpos = getKeywordPos("python", rest, pythonKeywordMode);      
      if (Math.max(numpos[0], sfnuttpos[0], dfnuttpos[0], compos[0], comlinepos[0], comhashpos[0], keywordpos[0]) == -1) {break;}
      mypos = getMinPos(numpos, sfnuttpos, dfnuttpos, compos, comlinepos, comhashpos, keywordpos);
      if (mypos[0] == -1) {break;}
      if (mypos[0] > -1) {
        done += rest.substring(0, mypos[0]);
        done += mypos[2](rest.substring(mypos[0], mypos[1]));
        rest = rest.substr(mypos[1]);
      }
    }
    rest = done + rest;
    return "<span style=color:" + pythoncolor + ">" + rest + "</span>";
  }
  function pythonStringMode(txt) {
    return "<span style=color:" + pythonstringcolor + ">" + txt + "</span>";
  }
  function pythonNumberMode(txt) {
    return "<span style=color:" + pythonnumbercolor + ">" + txt + "</span>";
  }
  function pythonKeywordMode(txt) {
    return "<span style=color:" + pythonkeywordcolor + ">" + txt + "</span>";
  }
  function getKeywordPos(typ, txt, func) {
    var words, i, pos, rpos = -1, rpos2 = -1, patt;
    if (typ == "js") {
      words = ["abstract","arguments","boolean","break","byte","case","catch","char","class","const","continue","debugger","default","delete",
      "do","double","else","enum","eval","event","export","extends","false","final","finally","float","for","function","goto","if","implements","import",
      "in","instanceof","int","interface","let","long","NaN","native","new","null","package","private","protected","public","return","short","static",
      "super","switch","synchronized","this","throw","throws","transient","true","try","typeof","var","void","volatile","while","with","yield"];
    } else if (typ == "java") {
      words = ["abstract","arguments","boolean","break","byte","case","catch","char","class","const","continue","debugger","default","delete",
      "do","double","else","enum","eval","event","export","extends","false","final","finally","float","for","function","goto","if","implements","import",
      "instanceof","int","interface","let","long","NaN","native","new","null","package","private","protected","public","return","short","static",
      "super","switch","synchronized","this","throw","throws","transient","true","try","typeof","var","void","volatile","while","with","yield",
      "String"];
    } else if (typ == "php") {
      words = ["$GLOBALS","$_SERVER","$_REQUEST","$_POST","$_GET","$_FILES","$_ENV","$_COOKIE","$_SESSION",
      "__halt_compiler","abstract","and","array","as","break","callable","case","catch","class","clone","const","continue","declare","default",
      "die","do","echo","else","elseif","empty","enddeclare","endfor","endforeach","endif","endswitch","endwhile","eval","exit","extends","final","for",
      "foreach","function","global","goto","if","implements","include","include_once","instanceof","insteadof","interface","isset","list","namespace","new",
      "or","print","private","protected","public","require","require_once","return","static","switch","throw","trait","try","unset","use","var","while","xor"];
    } else if (typ == "sql") {
      words = ["ADD","EXTERNAL","PROCEDURE","ALL","FETCH","PUBLIC","ALTER","FILE","RAISERROR","AND","FILLFACTOR","READ","ANY","READTEXT","AS","FOREIGN",
      "RECONFIGURE","ASC","FREETEXT","REFERENCES","AUTHORIZATION","FREETEXTTABLE","REPLICATION","BACKUP","FROM","RESTORE","BEGIN","FULL","RESTRICT","BETWEEN",
      "FUNCTION","RETURN","BREAK","GOTO","REVERT","BROWSE","GRANT","REVOKE","BULK","GROUP","RIGHT","BY","HAVING","ROLLBACK","CASCADE","HOLDLOCK","ROWCOUNT",
      "CASE","IDENTITY","ROWGUIDCOL","CHECK","IDENTITY_INSERT","RULE","CHECKPOINT","IDENTITYCOL","SAVE","CLOSE","IF","SCHEMA","CLUSTERED","IN",
      "SECURITYAUDIT","COALESCE","INDEX","SELECT","COLLATE","INNER","SEMANTICKEYPHRASETABLE","COLUMN","INSERT","SEMANTICSIMILARITYDETAILSTABLE","COMMIT",
      "INTERSECT","SEMANTICSIMILARITYTABLE","COMPUTE","INTO","SESSION_USER","CONSTRAINT","IS","SET","CONTAINS","JOIN","SETUSER","CONTAINSTABLE","KEY",
      "SHUTDOWN","CONTINUE","KILL","SOME","CONVERT","LEFT","STATISTICS","CREATE","LIKE","SYSTEM_USER","CROSS","LINENO","TABLE","CURRENT","LOAD","TABLESAMPLE",
      "CURRENT_DATE","MERGE","TEXTSIZE","CURRENT_TIME","NATIONAL","THEN","CURRENT_TIMESTAMP","NOCHECK","TO","CURRENT_USER","NONCLUSTERED","TOP","CURSOR",
      "NOT","TRAN","DATABASE","NULL","TRANSACTION","DBCC","NULLIF","TRIGGER","DEALLOCATE","OF","TRUNCATE","DECLARE","OFF","TRY_CONVERT","DEFAULT","OFFSETS",
      "TSEQUAL","DELETE","ON","UNION","DENY","OPEN","UNIQUE","DESC","OPENDATASOURCE","UNPIVOT","DISK","OPENQUERY","UPDATE","DISTINCT","OPENROWSET",
      "UPDATETEXT","DISTRIBUTED","OPENXML","USE","DOUBLE","OPTION","USER","DROP","OR","VALUES","DUMP","ORDER","VARYING","ELSE","OUTER","VIEW","END",
      "OVER","WAITFOR","ERRLVL","PERCENT","WHEN","ESCAPE","PIVOT","WHERE","EXCEPT","PLAN","WHILE","EXEC","PRECISION","WITH","EXECUTE","PRIMARY",
      "WITHIN GROUP","EXISTS","PRINT","WRITETEXT","EXIT","PROC","LIMIT","MODIFY","COUNT","REPLACE"];
    } else if (typ == "python") {
      words = ["as", "assert", "break", "class", "continue", "def", "del", "elif", "else", "except", "finally", "for", "from", "global", "if", "import",
      "lambda", "pass", "raise", "return", "try", "while", "with", "yield", "in", "abs", "all", "any", "bin", "bool", "bytearray", "callable", "chr",
      "classmethod", "compile", "complex", "delattr", "dict", "dir", "divmod", "enumerate", "eval", "filter", "float", "format", "frozenset", "getattr",
      "globals", "hasattr", "hash", "help", "hex", "id", "input", "int", "isinstance", "issubclass", "iter", "len", "list", "locals", "map", "max",
      "memoryview", "min", "next", "object", "oct", "open", "ord", "pow", "print", "property", "range", "repr", "reversed", "round", "set", "setattr", "slice",
      "sorted", "staticmethod", "str", "sum", "super", "tuple", "type", "vars", "zip", "__import__", "NotImplemented", "Ellipsis", "__debug__"];
    }
    for (i = 0; i < words.length; i++) {
      if (typ == "php" || typ == "sql") {
        pos = txt.toLowerCase().indexOf(words[i].toLowerCase());
      } else {
        pos = txt.indexOf(words[i]);
      }
      if (pos > -1) {
        patt = /\W/g;
        if (txt.substr(pos + words[i].length,1).match(patt) && txt.substr(pos - 1,1).match(patt)) {
          if (pos > -1 && (rpos == -1 || pos < rpos)) {
            rpos = pos;
            rpos2 = rpos + words[i].length;
          }
        }
      } 
    }
    return [rpos, rpos2, func];
  }
  function getPos(txt, start, end, func) {
    var s, e;
    s = txt.search(start);
    e = txt.indexOf(end, s + (end.length));
    if (e == -1) {e = txt.length;}
    return [s, e + (end.length), func];
  }
  function getNumPos(txt, func) {
    var arr = ["<br>", " ", ";", "(", "+", ")", "[", "]", ",", "&", ":", "{", "}", "/" ,"-", "*", "|", "%", "="], i, j, c, startpos = 0, endpos, word;
    for (i = 0; i < txt.length; i++) {
      for (j = 0; j < arr.length; j++) {
        c = txt.substr(i, arr[j].length);
        if (c == arr[j]) {
          if (c == "-" && (txt.substr(i - 1, 1) == "e" || txt.substr(i - 1, 1) == "E")) {
            continue;
          }
          endpos = i;
          if (startpos < endpos) {
            word = txt.substring(startpos, endpos);
            if (!isNaN(word)) {return [startpos, endpos, func];}
          }
          i += arr[j].length;
          startpos = i;
          i -= 1;
          break;
        }
      }
    }  
    return [-1, -1, func];
  }  
}
}
)();