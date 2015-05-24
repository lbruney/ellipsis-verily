Ellipsis Verily
================

JQuery plugin for text truncation supporting inner tags. See [demo](http://lbruney.github.io/ellipsis-verily/demo/index.html).

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
  display: inline-block;
}
```
* Call plugin on the to be truncated element, examples:
```
  $('.to-be-truncated').EllipsisVerily();
  $('.to-be-truncated').EllipsisVerily({ max: 200, normalTags: ['span', 'p'] });
  $('.to-be-truncated').EllipsisVerily({ max: 50, handler: '#toggle-truncated'});
```


API
================
`max (int)`:              maximum number of characters  
`handler (string)`:       the element class/id that toggles between the truncation  
`visible (string)`:       the element class/id that is visible after truncation  
`truncated (string)`:     the element class/id that is truncated  
`ellipsis (string)`:      the element class/id that holds the ellipsis symbol  
`hiddenClass (string)`:   the class name whose style is set to `display: none;` - default is `display-none`; do not include the `.`   
`showClass (string)`:     the class name whose style is set to `display: inline-block;` - default is `display-block`; do not include the `.`   
`moreText (string)`:      the text to show on the handler when text is truncated  
`lessText (string)`:      the text to show on the handler when all text is visible  
`parent (string)`:        the element class/id of the parent where the handler can be found (useful if multiple containers on the same page are to be truncated which all have the same handler class name) - default is `null`; do not set this if the text to be truncated and the handler do not have the same parent container  
`normalTags (array)`:     list of tags that are to be included but attributes are to be stripped  
`attributedTags (array)`: list of tags that are to be included but attributes are not to be stripped  


Troubleshoot
================
* Make sure you added the `hiddenClass` and `showClass` styles to your page. If you change the default class names in the plugin options, make sure the change is reflected in the CSS.
* As `hiddenClass` and `showClass` will be applied as classes, they should not have the `.` in the name. `handler`, `visible`, `truncated` and `ellipsis` could either be a class or id and should include either `.` or `#`

Limitations
================
* Html attributes like: alt="a>b" not supported. Attributes should not have > or < included.
* Tags separated by the truncation point are moved into the truncated container.

## License

[MIT](LICENSE)
