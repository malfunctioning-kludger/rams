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
var Article, Expose, Perspective, Unexpose, article, copies, exposed, getChildren, i, j, layout, listener, order, palletes, shift, shifts;

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
  article.className = "padded horizontal x-aligned has-connector";
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
  exposed.style.opacity = '';
  exposed.classList.remove('exposed');
  document.removeEventListener('mousemove', listener);
  copied = copies.slice();
  for (j = 0, len = copied.length; j < len; j++) {
    copy = copied[j];
    if (!copy) {
      continue;
    }
    copy.parentNode.classList.remove('open');
  }
  xposed = exposed;
  if (typeof callback === "function") {
    callback(xposed, element);
  }
  setTimeout(function() {
    copy.parentNode.parentNode.removeChild(copy.parentNode);
    return xposed.style.zIndex = '';
  }, 600);
  return copies = exposed = null;
};

Perspective = function(element, e, rect) {
  var X, Y, diffX, diffY, ease, negateX, negateY, placeholder, totalHeight, totalWidth, x, y;
  if (!(placeholder = element.querySelectorAll('span.placeholder'))) {
    placeholder = document.createElement('span');
    placeholder.className = 'placeholder';
    placeholder.style.position = 'absolute';
    placeholder.style.top = '0';
    placeholder.style.left = '0';
    totalWidth = rect.width * 0.65 * 3;
    totalHeight = rect.height * 0.65 * 3;
    placeholder.style.width = totalWidth + 'px';
    placeholder.style.height = totalHeight + 'px';
    element.appendChild(placeholder);
  }
  ease = function(t) {
    return t * t;
  };
  x = Math.min(element.offsetWidth, Math.max(0, e.pageX - element.offsetLeft));
  negateX = (x / element.offsetWidth - 0.5) < 0;
  X = Math.max(0, Math.min(1, ease(Math.abs(x / element.offsetWidth - 0.5))));
  if (negateX) {
    X = -X;
  }
  y = Math.min(element.offsetHeight, ease(Math.max(0, e.pageY - element.offsetTop)));
  negateY = (y / element.offsetHeight - 0.5) < 0;
  Y = Math.max(0, Math.min(1, ease(Math.abs(y / element.offsetHeight - 0.5))));
  if (negateY) {
    Y = -Y;
  }
  x = '50%';
  y = '50%';
  totalWidth = rect.width * 0.65 * 3;
  totalHeight = rect.height * 0.65 * 3;
  if ((diffX = totalWidth - element.offsetWidth) > 0) {
    x = X * -diffX;
  }
  if ((diffY = totalHeight - element.offsetHeight) > 0) {
    y = Y * -diffY;
  }
  console.error([X, Y], [x, y], diffY, diffX, 666);
  element.scrollLeft = totalWidth / 2 - x;
  return element.scrollTop = totalHeight / 2 - y;
};

order = [0, 0, 0, 1, 1, 1, 2, 2, 2];

listener = null;

shift = '';

Expose = function(element, callback, e) {
  var cY, centerY, chosen, copy, i, j, k, len, mid, p, parent, rect, ref, scale, totalHeight, totalWidth;
  if (copies) {
    Unexpose();
  }
  element.classList.add('exposed');
  exposed = element;
  copies = [];
  if (rect = Expose.getRectangle(element)) {
    element.style.transform = 'scale(0.65)';
    element.style.opacity = '0';
  }
  totalWidth = rect.width * 3;
  totalHeight = rect.height * 3;
  centerY = element.offsetHeight / 2;
  cY = rect.top + rect.height / 2;
  shift = 'translateY(' + (centerY - cY) + 'px)' + 'translateX(' + totalWidth / 2 + 'px) translateY(' + totalHeight / 2 + 'px)';
  element.style.clip = rect.toString();
  for (i = j = 0; j < 9; i = ++j) {
    copy = element.cloneNode(true);
    if ((ref = copy.getElementsByTagName('h1')[0]) != null) {
      ref.innerHTML;
    }
    if (i === 4) {
      copy.style.clip = rect.toString(20);
      mid = copy;
    } else {
      copy.onmouseover = function() {
        return this.style.clip = rect.toString(20);
      };
      copy.onmouseout = function() {
        return this.style.clip = rect.toString(0);
      };
    }
    copy.setAttribute('id', 'copy-' + element.id + '-' + i);
    if ((typeof callback === "function" ? callback(copy, i) : void 0) === false) {
      continue;
    }
    copy.classList.add('copy');
    copy.style.position = 'absolute';
    copy.style.width = element.offsetWidth + 'px';
    copy.style.height = element.offsetHeight + 'px';
    copy.style.top = 0 + 'px';
    copy.style.left = 0 + 'px';
    copy.style.zIndex = 3 + (8 - order[i]);
    if (i === 4) {
      copy.style.opacity = 0;
    }
    copy.style.transition = 'clip 0.7s, opacity 0.35s ' + parseFloat((0.1 * Math.floor(Math.random() * 3)).toFixed(3)) + 's, transform 0.35s  ';
    copies[i] = copy;
    scale = 0.65;
    p = 4;
    switch (i) {
      case 0:
        copy.style.transform = 'scale(' + scale + ') ' + shift + 'translateY(' + (rect.bottom + rect.top - p) + 'px) translateX(' + (rect.right + rect.left - p) + 'px) ' + 'translateX(-120%) translateY(-120%)';
        break;
      case 1:
        copy.style.transform = 'scale(' + scale + ') ' + shift + 'translateY(' + (rect.bottom + rect.top - p) + 'px)  translateY(-120%)';
        break;
      case 2:
        copy.style.transform = 'scale(' + scale + ') ' + shift + 'translateY(' + (rect.bottom + rect.top - p) + 'px) translateX(' + (-rect.left - rect.right + p) + 'px) ' + 'translateX(120%) translateY(-120%)';
        break;
      case 3:
        copy.style.transform = 'scale(' + scale + ') ' + shift + 'translateX(' + (rect.right + rect.left - p) + 'px) ' + 'translateX(-120%)';
        break;
      case 4:
        copy.style.transform = 'scale(' + scale + ') ' + shift + 'translateX(0px) ';
        break;
      case 5:
        copy.style.transform = 'scale(' + scale + ') ' + shift + 'translateX(' + (-rect.left - rect.right + p) + 'px) ' + 'translateX(120%)';
        break;
      case 6:
        copy.style.transform = 'scale(' + scale + ') ' + shift + 'translateY(' + (-rect.bottom - rect.top + p) + 'px) ' + 'translateX(' + (rect.right + rect.left - p) + 'px) translateX(-120%) translateY(120%)';
        break;
      case 7:
        copy.style.transform = 'scale(' + scale + ') ' + shift + 'translateY(' + (-rect.bottom - rect.top + p) + 'px) ' + 'translateY(120%)';
        break;
      case 8:
        copy.style.transform = 'scale(' + scale + ') ' + shift + 'translateY(' + (-rect.bottom - rect.top + p) + 'px) ' + 'translateX(' + (-rect.left - rect.right + p) + 'px) translateX(120%) translateY(120%)';
    }
    copy.setAttribute('original-transform', copy.style.transform);
  }
  parent = document.createElement('div');
  chosen = null;
  listener = function(e) {
    var hover;
    Perspective(parent, e, rect);
    if ((hover = Article(e.target))) {
      if (chosen && hover !== chosen) {
        chosen.classList.remove('selected');
      }
      chosen = hover;
      return chosen.classList.add('selected');
    }
  };
  document.addEventListener('mousemove', listener);
  parent.classList.add('copies');
  parent.style.overflow = 'hidden';
  parent.style.perspective = '1px';
  parent.style.position = 'absolute';
  parent.style.left = element.offsetLeft + 'px';
  parent.style.top = element.offsetTop + 'px';
  parent.style.width = element.offsetWidth + 'px';
  parent.style.height = element.offsetHeight + 'px';
  parent.style.overflow = 'hidden';
  for (k = 0, len = copies.length; k < len; k++) {
    copy = copies[k];
    if (copy) {
      parent.appendChild(copy);
    }
  }
  element.parentNode.insertBefore(parent, element.nextSibling);
  return requestAnimationFrame(function() {
    document.body.classList.add('exposing');
    parent.classList.add('open');
    Perspective(parent, e, rect);
    return requestAnimationFrame(function() {
      var l, len1, midScale, resize, results;
      results = [];
      for (i = l = 0, len1 = copies.length; l < len1; i = ++l) {
        copy = copies[i];
        if (!copy) {
          continue;
        }
        copy.style.opacity = 1;
        p = 3;
        scale = 0.65;
        resize = 'scale(0.65)';
        midScale = 1 - 22 / rect.width;
        switch (i) {
          case 0:
            results.push(copy.style.transform = resize + shift + 'translateY(' + (rect.bottom + rect.top - p) + 'px) translateX(' + (rect.right + rect.left - p) + 'px) ' + 'translateX(-100%) translateY(-100%)');
            break;
          case 1:
            results.push(copy.style.transform = resize + shift + 'translateY(' + (rect.bottom + rect.top - p) + 'px) translateY(-100%)');
            break;
          case 2:
            results.push(copy.style.transform = resize + shift + 'translateY(' + (rect.bottom + rect.top - p) + 'px) translateX(' + (-rect.left - rect.right + p) + 'px) ' + 'translateX(100%) translateY(-100%)');
            break;
          case 3:
            results.push(copy.style.transform = resize + shift + 'translateX(' + (rect.right + rect.left - p) + 'px) ' + 'translateX(-100%)');
            break;
          case 4:
            results.push(copy.style.transform = resize + shift);
            break;
          case 5:
            results.push(copy.style.transform = resize + shift + 'translateX(' + (-rect.left - rect.right + p) + 'px) ' + 'translateX(100%)');
            break;
          case 6:
            results.push(copy.style.transform = resize + shift + 'translateY(' + (-rect.bottom - rect.top + p) + 'px) ' + 'translateX(' + (rect.right + rect.left - p) + 'px) translateX(-100%) translateY(100%)');
            break;
          case 7:
            results.push(copy.style.transform = resize + shift + 'translateY(' + (-rect.bottom - rect.top + p) + 'px) ' + 'translateY(100%)');
            break;
          case 8:
            results.push(copy.style.transform = resize + shift + 'translateY(' + (-rect.bottom - rect.top + p) + 'px) ' + 'translateX(' + (-rect.left - rect.right + p) + 'px) translateX(100%) translateY(100%)');
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
  var child, imageHeight, j, k, len, len1, list, offsetHeight, offsetLeft, offsetTop, offsetWidth, space;
  list = getChildren(element);
  imageHeight = 150;
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
    offsetHeight = list[list.length - 1].offsetTop + list[list.length - 1].offsetHeight - offsetTop;
    if (list[0].tagName === 'PICTURE') {
      space = element.offsetHeight - offsetHeight + list[0].offsetHeight;
      offsetTop += list[0].offsetHeight - space / 3;
      offsetHeight = list[list.length - 1].offsetTop + list[list.length - 1].offsetHeight - offsetTop;
    }
    if (list[1].tagName === 'PICTURE') {
      space = element.offsetHeight - offsetHeight + list[1].offsetHeight;
      offsetHeight -= list[1].offsetHeight - space / 3;
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
    toString: function(offset) {
      if (offset == null) {
        offset = 0;
      }
      return 'rect(' + (this.top + offset) + 'px,' + (this.left + this.width - offset) + 'px,' + (this.top + this.height - offset) + 'px,' + (this.left + offset) + 'px)';
    }
  };
};

shifts = [[-1, -1], [0, -1], [1, -1], [-1, 0], [0, 0], [1, 0], [-1, 1], [0, 1], [1, 1]];

Article = function(parent) {
  while ((parent != null ? parent.nodeType : void 0) === 1) {
    if (parent.tagName === 'ARTICLE') {
      return parent;
    }
    parent = parent.parentNode;
  }
};

document.addEventListener('click', function(e) {
  var parent, results;
  parent = e.target;
  results = [];
  while (parent) {
    if (parent.tagName === 'ARTICLE') {
      e.preventDefault();
      if (parent.classList.contains('copy')) {
        if (exposed) {
          parent;
        }
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
        }, e);
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
