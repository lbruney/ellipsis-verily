###
  A true plugin for text truncation with html support.

  @autor Lisa-Ann Bruney <lisabruney@yahoo.com>
  @year 2014
###

class EllipsisVerily

  constructor: (element, options) ->
    defaults =
      max: 450
      delimeter: '♠'
      nonEnglish:
        delimiter: '。'
        dividend: 1
      handler: '.ellipsis-handler'
      visible: '.visible-text'
      truncated: '.truncated-text'
      ellipsis: '.ellipsis-text'
      hiddenClass: 'display-none'
      showClass: 'display-inline'
      activeClass: 'is-open'
      moreText: 'Read more'
      lessText: 'Show less'
      parent: null
      tags: ['a', 'img', 'p', 'span', 'strong', 'em', 'label', 'br', 'h1', 'h2', 'h3', 'h4', 'b', 'code', 'ul', 'li']
      selfClosing: ['img', 'hr']

    @ops = $.extend(defaults, options)
    @el = $(element)
    @tags = @ops.tags

    @init()
    return this

  init: ->
    @placeHolderTags()
    @makeEllipsis()
    @setEvents()

  setEvents: ->
    that = @
    if (@ops.parent)
      $parentsUntil = @el.parentsUntil(@ops.parent)
      $parent = (if ($parentsUntil.length > 0) then $parentsUntil.parent() else @el.parent())
      @handler = $parent.find(@ops.handler)
    else 
      @handler = $(@ops.handler)

    @handler.click (e) =>
      $el = $(e.currentTarget)
      $el.toggleClass(@ops.activeClass)

      if ($el.hasClass(@ops.activeClass))
        $el.text(@ops.lessText)
      else
        $el.text(@ops.moreText)

      @el.find(@ops.ellipsis).toggleClass(@ops.hiddenClass).toggleClass(@ops.showClass)
      @el.find(@ops.truncated).toggleClass(@ops.hiddenClass).toggleClass(@ops.showClass)
      return false
    return

  placeHolderTags: ->
    # Normalize text
    @html = @el.html().replace(/%[A-F\d]{2}/g, 'U')
    @openTagsHtml = []
    @closeTagsHtml = []
    @tagsHtml = []
    i = 0
    while i < @tags.length
      @findTags(@tags[i])
      @findTags(@tags[i], false)
      i++

    @compressHtml(@openTagsHtml)
    @compressHtml(@closeTagsHtml)
    return

  getTag: (tag, open=true) ->
    if !open
      return '</'+tag+'>'
    else 
      return '<'+tag+'[^>]*>'

  findTags: (tag, open=true) ->
    regex = @getRegex(@getTag(tag, open))
    foundTags = @html.match(regex)
    if foundTags && foundTags.length
      if open
        @openTagsHtml = @openTagsHtml.concat(foundTags)
      else 
        @closeTagsHtml = @closeTagsHtml.concat(foundTags)

  compressHtml: (tags) ->
    i = 0
    while i < tags.length
      tag = tags[i]
      tagNoSpace = @getTagNoSpace(tag)
      @tagsHtml.push(tagNoSpace)
      @html = @html.replace(@getRegex(tag), tagNoSpace)
      i++

  makeEllipsis: ->

    if @tagsHtml.length
      max = @tagsHtml.toString().length + @ops.max 
    else 
      max = @ops.max 

    if @html.length < max
      return

    # Find non-English text
    if @html.match(/[\u3400-\u9FBF]/)
      splitLocation = @html.indexOf(@ops.nonEnglish.delimiter, (max/@ops.nonEnglish.dividend))
    else
      splitLocation = @html.indexOf(' ', max)
    if splitLocation > -1
      @half1 = @html.substr(0, splitLocation)
      @half2 = @html.substr(splitLocation, @html.length - 1)
      @findBreaks()
      @recreateHtml()
      @el.html(@finalHtml)
    else 
      return

  findBreaks: ->
    i = 0
    while i < @tags.length
      tag = @tags[i]
      if @ops.selfClosing.indexOf(tag) <= -1
        closeTag = @getTag(tag, false)
        fullTag = @getTag(tag)
        totalOpenTags = @countOccurrences(fullTag)
        totalCloseTags = @countOccurrences(closeTag)
        if (totalOpenTags > totalCloseTags)
          difference = totalOpenTags - totalCloseTags
          d = 0
          tagIndex = totalOpenTags - 1
          openTags = @half1.match(@getRegex(fullTag))
          while d < difference
            openTag = openTags[tagIndex]
            @appendToTruncated(openTag, closeTag)
            tagIndex--
            d++
      i++
    return

  recreateHtml: ->
    @finalHtml = '<div class="'+@ops.visible.substr(1)+'">'+@half1+'<span class="'+@ops.ellipsis.substr(1)+' '+@ops.showClass+'">...</span></div><div class="'+@ops.truncated.substr(1)+' '+@ops.hiddenClass+'" >'+@half2+'</div>'
    @replenishTags(@openTagsHtml)
    @replenishTags(@closeTagsHtml)

  replenishTags: (tags) ->
    i = 0
    while i < tags.length
      @replenishTag(tags[i])
      i++

  replenishTag: (tag) ->
    tagNoSpace = @getTagNoSpace(tag)
    @finalHtml = @finalHtml.replace(@getRegex(tagNoSpace), tag)

  getTagNoSpace: (tag) ->
    return tag.replace(' ', @ops.delimiter)

  appendToTruncated: (openTag, closeTag) ->
    @half1 = @half1 + closeTag
    @half2 = openTag + @half2

  countOccurrences: (tag) ->
    matches = @half1.match(@getRegex(tag))
    if matches
      return matches.length
    else 
      return 0

  getRegex: (tag) ->
    return new RegExp(tag, 'gi')


  $.fn.EllipsisVerily = (options) ->
    $(this).each (i, element) ->
      $(this).data 'ellipsis-verily', new EllipsisVerily(this, options)  unless $(this).data('ellipsis-verily')
    return
