(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
module.exports = function() {
  var child, element, index, j, k, l, len, len1, len2, list, previous, ref, ref1;
  ref = document.querySelectorAll('.horizontal');
  for (j = 0, len = ref.length; j < len; j++) {
    element = ref[j];
    if (element.classList.contains('inverted')) {
      list = Array.prototype.reverse.call(Array.prototype.slice.call(element.children));
    } else {
      list = element.children;
    }
    for (index = k = 0, len1 = list.length; k < len1; index = ++k) {
      child = list[index];
      if (!(previous = list[index - 1])) {
        continue;
      }
      if (child.offsetTop >= previous.offsetTop + previous.offsetHeight) {
        element.classList.add('actually-vertical');
        break;
      }
    }
    module.exports.eachRow(layout, function(collection) {
      var article, basis, l, len2, picture, pictures;
      pictures = collection.map(function(item) {
        return item.getElementsByTagName('picture')[0];
      });
      console.log('ROW', collection);
      for (index = l = 0, len2 = collection.length; l < len2; index = ++l) {
        article = collection[index];
        picture = pictures[index];
        if (picture.offsetLeft > 0) {
          article.classList.add('partial-image');
        } else {
          article.classList.remove('partial-image');
        }
        if (collection.length === 1) {
          article.classList.add('full');
        } else {
          article.classList.remove('full');
        }
      }
      basis = parseFloat(picture.style.maxWidth);
      return console.log(basis, 44);
    });
  }
  ref1 = document.querySelectorAll('.x-aligned');
  for (l = 0, len2 = ref1.length; l < len2; l++) {
    element = ref1[l];
    if (element.offsetWidth !== layout.offsetWidth) {
      continue;
    }
    module.exports.eachRow(element, function(collection) {
      var left, offset, right, span;
      if (collection.length === 2) {
        left = collection[0].offsetLeft;
        right = element.offsetWidth - collection[1].offsetLeft - collection[1].offsetWidth;
        span = left + right;
        if (element.classList.contains('inverted')) {
          offset = collection[0].offsetWidth + collection[0].offsetLeft - element.offsetWidth / 2;
          if (span >= offset) {
            return element.style.paddingRight = Math.min(span, Math.abs(offset)) + 'px';
          }
        } else {
          offset = element.offsetWidth / 2 - collection[1].offsetWidth;
          if (span >= Math.abs(offset)) {
            return element.style.paddingLeft = Math.abs(offset) + 'px';
          }
        }
      }
    });
  }
};

module.exports.eachRow = function(element, callback) {
  var child, collection, i, index, j, len, list, previous;
  collection = null;
  if (element.classList.contains('inverted')) {
    list = Array.prototype.reverse.call(Array.prototype.slice.call(element.children));
  } else {
    list = element.children;
  }
  i = 0;
  for (index = j = 0, len = list.length; j < len; index = ++j) {
    child = list[index];
    if (!(previous = list[index - 1])) {
      continue;
    }
    collection || (collection = [previous]);
    if (child.offsetTop < previous.offsetTop + previous.offsetHeight) {
      collection.push(child);
    } else {
      callback(collection, i++);
      collection = [child];
    }
    if (list[index + 1]) {
      continue;
    }
    callback(collection, i++);
    collection = null;
  }
};

module.exports.reset = function() {
  var el, element, j, k, l, len, len1, len2, ref, ref1, ref2;
  ref = document.querySelectorAll('.x-aligned');
  for (j = 0, len = ref.length; j < len; j++) {
    element = ref[j];
    element.style.paddingLeft = element.style.paddingRight = '';
  }
  ref1 = document.querySelectorAll('article');
  for (k = 0, len1 = ref1.length; k < len1; k++) {
    el = ref1[k];
    el.style.webkitFlexBasis = el.style.flexBasis = '';
  }
  ref2 = document.querySelectorAll('.actually-horizontal, .actually-vertical');
  for (l = 0, len2 = ref2.length; l < len2; l++) {
    el = ref2[l];
    el.classList.remove('actually-vertical');
    el.classList.remove('actually-horizontal');
  }
  return module.exports();
};

window.addEventListener('resize', module.exports.reset);

window.addEventListener('load', module.exports);


},{}],2:[function(require,module,exports){
var article, i, j, layout;

module.exports = function() {
  var callback, image, j, len, ref, results;
  ref = document.getElementsByTagName('img');
  results = [];
  for (j = 0, len = ref.length; j < len; j++) {
    image = ref[j];
    callback = function() {
      var id, parent, style;
      while (parent = (parent || this).parentNode) {
        if (parent.tagName === 'ARTICLE') {
          id = parent.id || (parent.id = 'u-' + Math.floor(Math.random() * 10000000));
          break;
        }
      }
      style = document.createElement('style');
      style.textContent = Pallete(this)('DV+LV').toString('#' + id + ' ');
      return this.parentNode.appendChild(style);
    };
    if (image.complete) {
      results.push(callback.call(image));
    } else {
      results.push(image.onload = callback);
    }
  }
  return results;
};

module.exports.example = function(path, index) {
  var article, img;
  img = new Image();
  img.src = path;
  img.onload = function() {
    var picture;
    picture = article.getElementsByTagName('picture')[0];
    picture.style.flexBasis = img.width + 'px';
    picture.style.webkitFlexBasis = img.width + 'px';
    picture.style.maxWidth = img.width * 1.25 + 'px';
    if (img.width > img.height * 1.1) {
      picture.classList.add('portrait');
      article.classList.add('forced');
      article.classList.add('vertical');
      return article.classList.remove('horizontal');
    }
  };
  article = document.createElement('article');
  article.className = "padded horizontal x-aligned";
  article.classList.add(['inverted', 'uninverted', 'uninverted', 'inverted', 'inverted', 'uninverted'][index % 6]);
  article.innerHTML = "<div class=\"box padded vertical textual \">\n  <h1>Hello world</h1>\n  <p>This is a wonderful day to do the great art. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Vestibulum tortor quam, feugiat vitae, ultricies eget, tempor sit amet, ante. Donec eu libero sit amet quam egestas semper. Aenean ultricies mi vitae est. Mauris placerat eleifend leo.</p>\n\n  <div class=\"block padded vertical textual\">\n    <h1>This is a nested <span class=\"accent\">group</span></h1>\n    <p>This is a wonderful day to do the great art</p>\n  </div>\n</div>\n<picture class=\"graphical decorated\">\n  <img src=\"" + path + "\" />\n</picture>";
  return article;
};

require('./alignment.coffee');

layout = document.getElementById('layout');

for (i = j = 30; j <= 36; i = ++j) {
  article = module.exports.example("./images/" + i + ".jpg", i - 30);
  layout.appendChild(article);
}

module.exports();


},{"./alignment.coffee":1}]},{},[2]);
