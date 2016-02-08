(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var getChildren;

module.exports = function() {
  var child, element, index, j, k, l, len, len1, len2, list, previous, ref, ref1;
  ref = document.querySelectorAll('.horizontal');
  for (j = 0, len = ref.length; j < len; j++) {
    element = ref[j];
    list = getChildren(element);
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
      return basis = parseFloat(picture.style.maxWidth);
    });
  }
  ref1 = document.querySelectorAll('.x-aligned');
  for (l = 0, len2 = ref1.length; l < len2; l++) {
    element = ref1[l];
    if (element.classList.contains('actually-vertical') || element.classList.contains('vertical')) {
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
            if (offset > 0) {
              return element.style.paddingRight = Math.min(span, Math.abs(offset)) + 'px';
            } else {
              return element.style.paddingLeft = Math.min(span, Math.abs(offset)) + 'px';
            }
          }
        } else {
          offset = element.offsetWidth / 2 - collection[0].offsetWidth;
          if (span >= Math.abs(offset)) {
            if (offset > 0) {
              return element.style.paddingLeft = Math.abs(offset) + 'px';
            } else {
              return element.style.paddingRight = Math.abs(offset) + 'px';
            }
          }
        }
      }
    });
  }
};

module.exports.eachRow = function(element, callback) {
  var child, collection, i, index, j, len, list, previous;
  collection = null;
  list = getChildren(element);
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

getChildren = function(element) {
  var list;
  if (element.classList.contains('inverted')) {
    list = Array.prototype.reverse.call(Array.prototype.slice.call(element.children));
  } else {
    list = Array.prototype.slice.call(element.children);
  }
  return list.filter(function(el) {
    return el.tagName !== 'STYLE';
  });
};

window.addEventListener('resize', module.exports.reset);

window.addEventListener('load', module.exports);


},{}],2:[function(require,module,exports){
var Expose, Unexpose, article, copies, exposed, getChildren, i, j, layout, order, palletes, shifts;

palletes = {};

module.exports = function(element, image, x, y) {
  var name, pallete, style;
  style = element.getElementsByTagName('style')[0] || document.createElement('style');
  image || (image = element.getElementsByTagName('img')[0]);
  image.id || (image.id = 'u-' + Math.random());
  pallete = palletes[name = image.id] || (palletes[name] = Pallete(image));
  style.textContent = pallete(null, x, y).toString('#' + element.id + ' ');
  if (style.parentNode !== element) {
    return element.appendChild(style);
  }
};

module.exports.find = function() {
  var callback, image, j, len, ref, results;
  ref = document.getElementsByTagName('img');
  results = [];
  for (j = 0, len = ref.length; j < len; j++) {
    image = ref[j];
    callback = function() {
      var id, parent;
      while (parent = (parent || this).parentNode) {
        if (parent.tagName === 'ARTICLE') {
          id = parent.id || (parent.id = 'u-' + Math.floor(Math.random() * 10000000));
          break;
        }
      }
      parent.setAttribute('color-x', 4);
      parent.setAttribute('color-y', 4);
      return module.exports(parent, this, parseFloat(parent.getAttribute('color-x')), parseFloat(parent.getAttribute('color-y')));
    };
    if (image.complete) {
      results.push(callback.call(image));
    } else {
      results.push(image.onload = callback);
    }
  }
  return results;
};

exposed = null;

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

copies = null;

Unexpose = function(element, callback) {
  var copied, copy, j, len, xposed;
  document.body.classList.remove('exposing');
  exposed.style.transform = '';
  copied = copies.slice();
  for (j = 0, len = copied.length; j < len; j++) {
    copy = copied[j];
    if (copy === element) {
      copy.style.transform = 'scale(1)';
      copy.style.zIndex = '1';
      copy.style.opacity = 0;
      copy.style.clip = 'rect(' + 0 + 'px,' + copy.offsetWidth + 'px,' + copy.offsetHeight + 'px,' + 0 + 'px)';
    } else {
      copy.style.transform = 'scale(0.5)';
      copy.style.zIndex = '';
      copy.style.opacity = 0;
    }
  }
  xposed = exposed;
  if (typeof callback === "function") {
    callback(xposed);
  }
  setTimeout(function() {
    var k, len1, ref, results;
    xposed.style.zIndex = '';
    results = [];
    for (k = 0, len1 = copied.length; k < len1; k++) {
      copy = copied[k];
      results.push((ref = copy.parentNode) != null ? ref.removeChild(copy) : void 0);
    }
    return results;
  }, 800);
  return copies = exposed = null;
};

order = [2, 1, 0, 2, 1, 0, 2, 1, 0];

Expose = function(element, callback) {
  var copy, i, j, k, len, parent, rect, shift, totalLeft;
  if (copies) {
    Unexpose();
  }
  document.body.classList.add('exposing');
  exposed = element;
  copies = [];
  if (rect = Expose.getRectangle(element)) {
    console.log(rect, rect.toString());
    element.style.clip = rect.toString();
  }
  for (i = j = 0; j < 9; i = ++j) {
    copy = element.cloneNode(true);
    copy.setAttribute('id', 'copy' + element.id + '-' + i);
    if ((typeof callback === "function" ? callback(copy, i) : void 0) === false) {
      continue;
    }
    copy.classList.add('copy');
    copy.style.position = 'absolute';
    copy.style.width = element.offsetWidth + 'px';
    copy.style.height = element.offsetHeight + 'px';
    copy.style.top = element.offsetTop + 'px';
    copy.style.left = element.offsetLeft + 'px';
    copy.style.transform = 'scale(0.5)';
    copy.style.zIndex = 3 + (8 - order[i]);
    copy.style.opacity = 0;
    copy.style.transform = 'scale(0.75)';
    copy.style.transition = 'clip 0.3s, opacity 0.4s ' + parseFloat((0.05 * order[i]).toFixed(3)) + 's, transform 0.3s ease-in ' + parseFloat((0.04 * order[i]).toFixed(3)) + 's';
    copies.push(copy);
    console.log(i, order[i]);
  }
  totalLeft = 0;
  while (parent || (parent = element)) {
    totalLeft += parent.offsetLeft || 0;
    if (!(parent = parent.offsetParent)) {
      break;
    }
  }
  shift = 'translateX(' + (window.innerWidth / 2 - totalLeft - element.offsetWidth / 2) + 'px) ';
  for (k = 0, len = copies.length; k < len; k++) {
    copy = copies[k];
    element.parentNode.insertBefore(copy, element.nextSibling);
  }
  return requestAnimationFrame(function() {
    return requestAnimationFrame(function() {
      var l, len1, p, results;
      results = [];
      for (i = l = 0, len1 = copies.length; l < len1; i = ++l) {
        copy = copies[i];
        copy.style.opacity = 1;
        copy.style.transform = 'scale(0.5)';
        p = 3;
        switch (i) {
          case 0:
            results.push(copy.style.transform = shift + 'translateY(' + (rect.bottom + rect.top - p) / 2 + 'px) translateX(' + (rect.right + rect.left - p) / 2 + 'px) ' + 'scale(0.5) translateX(-100%) translateY(-100%)');
            break;
          case 1:
            results.push(copy.style.transform = shift + 'translateY(' + (rect.bottom + rect.top - p) / 2 + 'px)  scale(0.5) translateY(-100%)');
            break;
          case 2:
            results.push(copy.style.transform = shift + 'translateY(' + (rect.bottom + rect.top - p) / 2 + 'px) translateX(' + (-rect.left - rect.right + p) / 2 + 'px) ' + 'scale(0.5) translateX(100%) translateY(-100%)');
            break;
          case 3:
            results.push(copy.style.transform = shift + 'translateX(' + (rect.right + rect.left - p) / 2 + 'px) ' + 'scale(0.5) translateX(-100%)');
            break;
          case 4:
            results.push(copy.style.transform = shift + 'translateX(0px) ' + 'scale(0.5)');
            break;
          case 5:
            results.push(copy.style.transform = shift + 'translateX(' + (-rect.left - rect.right + p) / 2 + 'px) ' + 'scale(0.5) translateX(100%)');
            break;
          case 6:
            results.push(copy.style.transform = shift + 'translateY(' + (-rect.bottom - rect.top + p) / 2 + 'px) ' + 'translateX(' + (rect.right + rect.left - p) / 2 + 'px) scale(0.5) translateX(-100%) translateY(100%)');
            break;
          case 7:
            results.push(copy.style.transform = shift + 'translateY(' + (-rect.bottom - rect.top + p) / 2 + 'px) ' + 'scale(0.5) translateY(100%)');
            break;
          case 8:
            results.push(copy.style.transform = shift + 'translateY(' + (-rect.bottom - rect.top + p) / 2 + 'px) ' + 'translateX(' + (-rect.left - rect.right + p) / 2 + 'px) scale(0.5) translateX(100%) translateY(100%)');
            break;
          default:
            results.push(void 0);
        }
      }
      return results;
    });
  });
};

getChildren = function(element) {
  var list;
  if (element.classList.contains('inverted')) {
    list = Array.prototype.reverse.call(Array.prototype.slice.call(element.children));
  } else {
    list = Array.prototype.slice.call(element.children);
  }
  return list.filter(function(el) {
    return el.tagName !== 'STYLE';
  });
};

Expose.getRectangle = function(element) {
  var child, j, k, len, len1, list, offsetHeight, offsetLeft, offsetTop, offsetWidth;
  list = getChildren(element);
  if (element.classList.contains('vertical') || element.classList.contains('actually-vertical')) {
    offsetWidth = 0;
    offsetLeft = 0;
    for (j = 0, len = list.length; j < len; j++) {
      child = list[j];
      if (offsetWidth < child.offsetWidth) {
        offsetWidth = child.offsetWidth;
        offsetLeft = child.offsetLeft;
      }
    }
    offsetTop = list[0].offsetTop;
    if (list[0].tagName === 'PICTURE') {
      offsetTop += list[0].offsetHeight - 200;
    }
    offsetHeight = list[list.length - 1].offsetTop + list[list.length - 1].offsetHeight - offsetTop;
    if (list[1].tagName === 'PICTURE') {
      offsetHeight -= list[1].offsetHeight - 200;
    }
  } else {
    offsetHeight = 0;
    offsetTop = 0;
    for (k = 0, len1 = list.length; k < len1; k++) {
      child = list[k];
      if (offsetHeight < child.offsetHeight) {
        offsetHeight = child.offsetHeight;
        offsetTop = child.offsetTop;
      }
    }
    offsetLeft = list[0].offsetLeft;
    offsetWidth = list[list.length - 1].offsetLeft + list[list.length - 1].offsetWidth - offsetLeft;
  }
  return {
    top: offsetTop,
    left: offsetLeft,
    right: element.offsetWidth - offsetWidth - offsetLeft,
    bottom: element.offsetHeight - offsetHeight - offsetTop,
    height: offsetHeight,
    width: offsetWidth,
    toString: function() {
      return 'rect(' + this.top + 'px,' + (this.left + this.width) + 'px,' + (this.top + this.height) + 'px,' + this.left + 'px)';
    }
  };
};

shifts = [[-1, -1], [0, -1], [1, -1], [-1, 0], [0, 0], [1, 0], [-1, 1], [0, 1], [1, 1]];

document.addEventListener('click', function(e) {
  var parent, results;
  parent = e.target;
  results = [];
  while (parent) {
    if (parent.tagName === 'ARTICLE') {
      e.preventDefault();
      if (parent.classList.contains('copy')) {
        Unexpose(parent, function(element) {
          element.setAttribute('color-x', parent.getAttribute('color-x'));
          element.setAttribute('color-y', parent.getAttribute('color-y'));
          return module.exports(element, null, parseFloat(element.getAttribute('color-x')), parseFloat(element.getAttribute('color-y')));
        });
      } else if (parent === exposed) {
        Unexpose();
      } else {
        Expose(parent, function(element, i) {
          var error, ref, x, y;
          ref = shifts[i], x = ref[0], y = ref[1];
          element.setAttribute('color-x', parseFloat(parent.getAttribute('color-x')) + x);
          element.setAttribute('color-y', parseFloat(parent.getAttribute('color-y')) + y);
          try {
            return module.exports(element, null, parseFloat(element.getAttribute('color-x')), parseFloat(element.getAttribute('color-y')));
          } catch (error) {
            e = error;
            return false;
          }
        });
      }
      break;
    }
    if ((parent = parent.parentNode).nodeType !== 1) {
      break;
    } else {
      results.push(void 0);
    }
  }
  return results;
});

layout = document.getElementById('layout');

for (i = j = 30; j <= 36; i = ++j) {
  article = module.exports.example("./images/" + i + ".jpg", i - 30);
  layout.appendChild(article);
}

module.exports.find();


},{"./alignment.coffee":1}]},{},[2]);
