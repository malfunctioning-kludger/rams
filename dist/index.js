(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var Editor;

CKEDITOR.disableAutoInline = true;

CKEDITOR.plugins.add('structural', {
  init: function(editor) {
    var addButton;
    addButton = function(commandName, styles, forms, icon) {
      var style;
      editor.ui.addButton(commandName, {
        label: 'Add ' + commandName,
        command: commandName,
        toolbar: 'structural',
        icon: icon || 'italic'
      });
      style = new CKEDITOR.style(styles);
      editor.attachStyleStateChange(style, function(state) {
        !editor.readOnly && editor.getCommand(commandName).setState(state);
      });
      editor.addCommand(commandName, new CKEDITOR.styleCommand(style, {
        contentForms: forms
      }));
    };
    addButton('heading', {
      element: 'h1'
    }, ['h1']);
    addButton('subtitle', {
      element: 'h2'
    }, ['h2']);
    addButton('blockquote', {
      element: 'blockquote'
    }, ['blockquote'], 'blockquote');
  }
});

Editor = function(element) {
  element.setAttribute('contenteditable', 'true');
  return CKEDITOR.inline(element, {
    extraPlugins: 'structural',
    allowedContent: true
  });
};

module.exports = Editor;


},{}],2:[function(require,module,exports){
(function (global){
var Rams;

Rams = {
  Page: require('./page.coffee'),
  Editor: require('./editor.coffee')
};

if (typeof document !== "undefined" && document !== null) {
  window.addEventListener('load', function() {
    var opts;
    opts = {
      breakpoint: 'desktop'
    };
    opts.data = {
      items: Rams.Page(document),
      config: {
        "color": {
          "brandColors": ["#181d23", "#314b2a", "#49627f", "#5e8235", "#82a98d"],
          "brandStrength": 1,
          "lightness": 0.125,
          "saturation": 0.8125,
          "rhythmicContrast": 1
        },
        typography_spectrum: 1
      }
    };
    opts.onSerialize = function(breakpoint) {
      return typeof window.callPhantom === "function" ? window.callPhantom({
        event: 'screenshot',
        name: breakpoint,
        screenshot: 'screenshots/' + breakpoint + '.jpg'
      }) : void 0;
    };
    global.params = new Options(global.params, opts);
    return params.apply(Pipeline, function(result) {
      var article, i, iframe, len, ref, results;
      ref = document.getElementsByTagName('iframe');
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        iframe = ref[i];
        results.push((function() {
          var j, len1, ref1, results1;
          ref1 = iframe.contentWindow.document.getElementsByTagName('article');
          results1 = [];
          for (j = 0, len1 = ref1.length; j < len1; j++) {
            article = ref1[j];
            results1.push(Rams.Editor(article));
          }
          return results1;
        })());
      }
      return results;
    });
  });
}


}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{"./editor.coffee":1,"./page.coffee":3}],3:[function(require,module,exports){
var Article, Page;

Page = function(element) {
  var article, i, len, ref, results;
  if (element.nodeType === 9) {
    element = element.body;
  }
  ref = element.getElementsByTagName('article');
  results = [];
  for (i = 0, len = ref.length; i < len; i++) {
    article = ref[i];
    results.push(Article(article));
  }
  return results;
};

Article = function(element) {
  var item;
  item = {
    metadata: {
      author: {},
      publisher: {}
    }
  };
  item.blocks = Array.prototype.map.call(element.children, function(child) {
    var ref, ref1;
    switch (child.tagName) {
      case 'H1':
        return {
          title: child.innerHTML
        };
      case 'H2':
        return {
          subtitle: child.innerHTML
        };
      case 'P':
        return {
          text: child.innerHTML
        };
      case 'UL':
      case 'OL':
        return {
          list: child.innerHTML
        };
      case 'IMG':
        return {
          cover: {
            src: child.src,
            height: (ref = child.getAttribute('height')) != null ? ref : child.naturalHeight,
            width: (ref1 = child.getAttribute('width')) != null ? ref1 : child.naturalWidth
          }
        };
    }
  });
  return item;
};

module.exports = Page;


},{}]},{},[2]);
