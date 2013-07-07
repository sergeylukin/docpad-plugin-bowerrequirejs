# bower-requirejs Plugin for [DocPad](http://docpad.org)
DocPad plugin that wires-up installed Bower components into RequireJS config



## Install

It's not available for neat installation yet. But you can grab
[source](https://github.com/sergeylukin/docpad-plugin-bowerrequirejs/archive/master.zip)
and extract it into `plugins/` inside your docpad project

Hopefully soon it will be available via:

```
docpad install bowerrequirejs
```



## TODO

..just so many things:) some of them are:

- Let server know about the file changed and fetch it next time it's requested
  (currently file from memory is loaded)
- Copy `bower_components` to anywhere accessible via web and route paths to it.
  Right now paths are unreachable via web which is useless.
- Provide configuration API (currently stuff is hard-coded)



## History
You can discover the history inside the `History.md` file



## License

MIT: [sergey.mit-license.org](http://sergey.mit-license.org)
