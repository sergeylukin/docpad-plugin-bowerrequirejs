# bower-requirejs Plugin for [DocPad](http://docpad.org)
DocPad plugin that wires-up installed Bower components into RequireJS config

Useful for statically generated assets


## Why?

Assuming you've installed `jquery` via `bower`, like so:

```
bower install jquery
```

and set it as a dependency in one of your AMD modules:

```
define(['jquery'], function($) {
  console.log('hooray I have jquery available: ' + $);
});
```

If you're using `r.js` optimizer to bundle your JS files and you want `jquery`
to be part of a bundle, you'd have to provide it's `path` in rjsConfig file.

This plugin does that automagically


## Install

```
npm install docpad-plugin-bowerrequirejs --save-dev
```




## History
You can discover the history inside the `History.md` file



## License

MIT: [sergey.mit-license.org](http://sergey.mit-license.org)
