function getSelectedText() {
  var txt = '';
  if (window.getSelection)
  {
    txt = window.getSelection();
  }
  else if (document.getSelection)
  {
    txt = document.getSelection();
  }
  else if (document.selection)
  {
    txt = document.selection.createRange().text;
  }
  
  return txt;
}

function getRangeObject(selectionObject) {
	if (selectionObject.getRangeAt) {
		return selectionObject.getRangeAt(0);
  } else { // Safari!
		var range = document.createRange();
		range.setStart(selectionObject.anchorNode,selectionObject.anchorOffset);
		range.setEnd(selectionObject.focusNode,selectionObject.focusOffset);
		return range;
	}
}

(function(){
var st = getSelectedText();
var to = getRangeObject(st);
var nearestId = "";
var p = to.startContainer;
while(p = p.parentNode) {
  if (p != null && p.id && p.id.length > 0) {
    nearestId = p.id;
    break;
  }
  s = p;
  while(s = s.previousSibling) {
    if (s != null && s.id && s.id.length > 0) {
      nearestId = s.id;
      break;
    }
  }
  if (s != null) break;
}

if (st != '') {
  hashPos = window.location.href.indexOf("#");
  if (hashPos > 0 && nearestId.length > 0) var wl = window.location.href.substr(0, hashPos);
  else var wl = window.location.href;
  wl = wl + (nearestId.length > 0 ? "#" + nearestId : "");
  var wl = "http://bot.fm/add_to_rss?text="+encodeURIComponent(getSelectedText())+"&url="+encodeURIComponent(wl);
  window.location = wl;
} else {
  alert("Вам необходимо выделить какой-либо текст!");
}
})()

