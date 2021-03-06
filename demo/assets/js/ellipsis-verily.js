/*
  A true plugin for text truncation with html support.
  https://github.com/lbruney/ellipsis-verily
  
  @autor L. Bruney <859763852@qq.com>
  @version 2.0.5
  @year 2016
 */

(function() {
  var EllipsisVerily;

  EllipsisVerily = (function() {
    function EllipsisVerily(element, options) {
      var defaults;
      defaults = {
        min: 300,
        delimiters: {
          tag: '♠',
          "break": ' ',
          nonEnglishBreak: '。'
        },
        handler: '.js-ellipsis-handler',
        visible: '.visible-text',
        truncated: '.truncated-text',
        ellipsis: '.ellipsis-text',
        hiddenClass: 'display-none',
        showClass: 'display-inline',
        activeClass: 'is-open',
        moreText: 'Read more',
        lessText: 'Show less',
        parent: null,
        tags: ['a', 'img', 'p', 'span', 'strong', 'em', 'label', 'br', 'h1', 'h2', 'h3', 'h4', 'b', 'code', 'ul', 'li'],
        selfClosingTags: ['img', 'hr', 'br']
      };
      this.ops = $.extend(defaults, options);
      this.el = $(element);
      this.tags = this.ops.tags;
      this.init();
      return this;
    }

    EllipsisVerily.prototype.init = function() {
      this.testIndexOf();
      this.makePlaceHolderTags();
      this.makeEllipsis();
      return this.setEvents();
    };

    EllipsisVerily.prototype.testIndexOf = function() {
      if (!Array.prototype.indexOf) {
        return Array.prototype.indexOf = function(elt) {
          var from, len;
          len = this.length >>> 0;
          from = Number(arguments[1]) || 0;
          from = from < 0 ? Math.ceil(from) : Math.floor(from);
          if (from < 0) {
            from += len;
          }
          while (from < len) {
            if (from in this && this[from] === elt) {
              return from;
            }
            from++;
          }
          return -1;
        };
      }
    };

    EllipsisVerily.prototype.setEvents = function() {
      var $parent, $parentsUntil, that;
      that = this;
      if (this.ops.parent) {
        $parentsUntil = this.el.parentsUntil(this.ops.parent);
        $parent = $parentsUntil.length ? $parentsUntil.parent() : this.el.parent();
        this.handler = $parent.find(this.ops.handler);
      } else {
        this.handler = $(this.ops.handler);
      }
      this.handler.click((function(_this) {
        return function(e) {
          var $el;
          $el = $(e.currentTarget);
          $el.toggleClass(_this.ops.activeClass);
          if ($el.hasClass(_this.ops.activeClass)) {
            $el.text(_this.ops.lessText);
          } else {
            $el.text(_this.ops.moreText);
          }
          _this.el.find(_this.ops.ellipsis).toggleClass(_this.ops.hiddenClass).toggleClass(_this.ops.showClass);
          _this.el.find(_this.ops.truncated).toggleClass(_this.ops.hiddenClass).toggleClass(_this.ops.showClass);
          return false;
        };
      })(this));
    };

    EllipsisVerily.prototype.stripOtherTags = function() {
      return this.html = this.html.replace(/(<([^>]+)>)/ig, '');
    };

    EllipsisVerily.prototype.makePlaceHolderTags = function() {
      var i;
      this.html = this.el.html().replace(/%[A-F\d]{2}/g, 'U');
      this.openTagsHtml = [];
      this.closeTagsHtml = [];
      this.tagsHtml = [];
      i = 0;
      while (i < this.tags.length) {
        this.findTags(this.tags[i]);
        if (this.isNotSelfClosingTag(this.tags[i])) {
          this.findTags(this.tags[i], false);
        }
        i++;
      }
      this.compressHtml(this.openTagsHtml);
      this.compressHtml(this.closeTagsHtml);
      this.stripOtherTags();
    };

    EllipsisVerily.prototype.getTag = function(tag, open) {
      if (open == null) {
        open = true;
      }
      if (!open) {
        return '</' + tag + '>';
      } else {
        return '<' + tag + '[^>]*>';
      }
    };

    EllipsisVerily.prototype.getPlaceholderTag = function(tag, open) {
      if (open == null) {
        open = true;
      }
      if (!open) {
        return '〚/' + tag + '〛';
      } else {
        return '〚' + tag + '[^〛]*〛';
      }
    };

    EllipsisVerily.prototype.findTags = function(tag, open) {
      var foundTags, regex;
      if (open == null) {
        open = true;
      }
      regex = this.getRegex(this.getTag(tag, open));
      foundTags = this.html.match(regex);
      if (foundTags && foundTags.length) {
        if (open) {
          return this.openTagsHtml = this.openTagsHtml.concat(foundTags);
        } else {
          return this.closeTagsHtml = this.closeTagsHtml.concat(foundTags);
        }
      }
    };

    EllipsisVerily.prototype.compressHtml = function(tags) {
      var i, tag, tagNoSpace, _results;
      i = 0;
      _results = [];
      while (i < tags.length) {
        tag = tags[i];
        tagNoSpace = this.getTagNoSpace(tag);
        this.tagsHtml.push(tagNoSpace);
        this.html = this.html.replace(this.getRegex(tag), tagNoSpace);
        _results.push(i++);
      }
      return _results;
    };

    EllipsisVerily.prototype.makeEllipsis = function() {
      var min, splitLocation;
      if (this.tagsHtml.length) {
        min = this.tagsHtml.toString().length + this.ops.min;
      } else {
        min = this.ops.min;
      }
      if (this.html.length < min) {
        return;
      }
      if (this.html.match(/[\u3400-\u9FBF]/)) {
        splitLocation = this.html.indexOf(this.ops.delimiters.nonEnglishBreak, min);
      } else {
        splitLocation = this.html.indexOf(this.ops.delimiters["break"], min);
      }
      if (splitLocation > -1) {
        this.half1 = this.html.substr(0, splitLocation);
        this.half2 = this.html.substr(splitLocation, this.html.length - 1);
        this.findBreaks();
        this.recreateHtml();
        return this.el.html(this.finalHtml);
      } else {

      }
    };

    EllipsisVerily.prototype.isNotSelfClosingTag = function(tag) {
      return this.ops.selfClosingTags.indexOf(tag) <= -1;
    };

    EllipsisVerily.prototype.findBreaks = function() {
      var closeTag, d, difference, fullTag, i, openTag, openTags, tag, tagIndex, totalCloseTags, totalOpenTags;
      i = 0;
      while (i < this.tags.length) {
        tag = this.tags[i];
        if (this.isNotSelfClosingTag(tag)) {
          closeTag = this.getPlaceholderTag(tag, false);
          fullTag = this.getPlaceholderTag(tag);
          totalOpenTags = this.countOccurrences(fullTag);
          totalCloseTags = this.countOccurrences(closeTag);
          if (totalOpenTags > totalCloseTags) {
            difference = totalOpenTags - totalCloseTags;
            d = 0;
            tagIndex = totalOpenTags - 1;
            openTags = this.half1.match(this.getRegex(fullTag));
            while (d < difference) {
              openTag = openTags[tagIndex];
              this.appendToTruncated(openTag, closeTag);
              tagIndex--;
              d++;
            }
          }
        }
        i++;
      }
    };

    EllipsisVerily.prototype.recreateHtml = function() {
      this.finalHtml = '<div class="' + this.ops.visible.substr(1) + '">' + this.half1 + '<span class="' + this.ops.ellipsis.substr(1) + ' ' + this.ops.showClass + '">...</span></div><div class="' + this.ops.truncated.substr(1) + ' ' + this.ops.hiddenClass + '" >' + this.half2 + '</div>';
      this.replenishTags(this.openTagsHtml);
      return this.replenishTags(this.closeTagsHtml);
    };

    EllipsisVerily.prototype.replenishTags = function(tags) {
      var i, _results;
      i = 0;
      _results = [];
      while (i < tags.length) {
        this.replenishTag(tags[i]);
        _results.push(i++);
      }
      return _results;
    };

    EllipsisVerily.prototype.replenishTag = function(tag) {
      var tagNoSpace;
      tagNoSpace = this.getTagNoSpace(tag);
      return this.finalHtml = this.finalHtml.replace(this.getRegex(tagNoSpace), tag);
    };

    EllipsisVerily.prototype.getTagNoSpace = function(tag) {
      return tag = tag.replace(this.getRegex(' '), this.ops.delimiters.tag).replace(this.getRegex('<'), '{').replace(this.getRegex('>'), '}');
    };

    EllipsisVerily.prototype.appendToTruncated = function(openTag, closeTag) {
      this.half1 = this.half1 + closeTag;
      return this.half2 = openTag + this.half2;
    };

    EllipsisVerily.prototype.countOccurrences = function(tag) {
      var matches;
      matches = this.half1.match(this.getRegex(tag));
      if (matches) {
        return matches.length;
      } else {
        return 0;
      }
    };

    EllipsisVerily.prototype.getRegex = function(tag) {
      return new RegExp(tag, 'gi');
    };

    $.fn.EllipsisVerily = function(options) {
      $(this).each(function(i, element) {
        if (!$(this).data('ellipsis-verily')) {
          return $(this).data('ellipsis-verily', new EllipsisVerily(this, options));
        }
      });
    };

    return EllipsisVerily;

  })();

}).call(this);
