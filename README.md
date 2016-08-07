Ellipsis Verily 2
================

JQuery plugin for text truncation supporting inner tags. Also supports Chinese text. See [demo](http://lbruney.github.io/ellipsis-verily/demo/index.html).


Usage
================
* Add JQuery script to page
* Add Ellipsis Verily script to page
* Add CSS styles to page:
```
.display-none {
  display: none;
}
.display-inline {
  display: inline;
}
```
* Call plugin on the to be truncated element, examples:
```
  $('.to-be-truncated').EllipsisVerily();
  $('.to-be-truncated').EllipsisVerily({ min: 200, tags: ['span', 'p'] });
  $('.to-be-truncated').EllipsisVerily({ min: 50, handler: '#toggle-truncated'});
```

Warning
================
This has been changed from the previous versions 1.x.x, however it contains some significant bug fixes, including:  
- Fix truncation of attributed tags  
- Added Chinese text truncation support  
- Fixed dumping of tags separated by truncation  

Changelog from v1.x.x
================
The following API options were removed or refactored:  
- `max` - This was renamed, now called min since max name was semantically incorrect.  
- `normalTags` and `attributedTags` - These were removed and replaced with one list `tags`   
- `.ellipsis-handler` - This default classname was renamed to `.js-ellipsis-handler`  


API
================
`min (int)`:              Minimum onscreen characters. The point of truncation is dependent on the first occurence of the delimiter; default is `300`   
`tags (array)`:           List of tags to support  
`moreText (string)`:      The text to show on the handler when text is truncated; default is `Read more`   
`lessText (string)`:      The text to show on the handler when all text is visible; default is `Show less`  
`parent (string)`:        The element selector (class/id) of the parent where the handler can be found. This is useful if multiple containers on the same page are to be truncated which all have the same handler class name. default is `null`; (Do not set this if the text to be truncated and the handler do not have the same parent container)  
`delimiters (object)`:    An object of 3 delimiters:  
- `tag (string)` :        An internal delimiter used to replace the space between tag attributes (don't set this if you don't know what it does)
- `break (string)`:       After the first `min` characters, the first occurrence of this creates the truncation point; default is ` ` (space)
- `nonEnglishBreak (string)`: Additional break delimiter for non-English texts; e.g. Chinese texts do not contain English character spaces, so we can break at `。`  
   

Other API
================
`handler (string)`:       The element selector (class/id) that toggles between the truncation; default is `.js-ellipsis-handler`   
`visible (string)`:       The element selector (class/id) that is visible after truncation; default is `.visible-text`  
`truncated (string)`:     The element selector (class/id) that is truncated; default is `.truncated-text`      
`ellipsis (string)`:      The element selector (class/id) that holds the ellipsis symbol; default is `.ellipsis-text`    
`hiddenClass (string)`:   The class name (do not include the `.`) whose style is set to `display: none;`; default is `display-none`      
`showClass (string)`:     The class name (do not include the `.`) whose style is set to `display: inline-block;`; default is `display-block`   

Troubleshoot
================
* Make sure you added the `hiddenClass` and `showClass` styles to your page. If you change these two default class names in the plugin options, make sure the change is reflected in the CSS.
* As `hiddenClass` and `showClass` will be applied as classes, they should not have the `.` in the name. `handler`, `visible`, `truncated` and `ellipsis` could either be a class or id selector and should include either `.` or `#` respectively.

Limitations
================
* Html attributes like: alt="a>b" not supported. Attributes should not have > or < included.

## License

[MIT](LICENSE)
