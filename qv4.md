# QV4

* Summary:    JavaScript engine of Qt's QML framework (QJSEngine).
* URL:        https://wiki.qt.io/V4
* Repository: https://github.com/qt/qtdeclarative.git
* LOC:        50221 (`cloc qtdeclarative/src/{qml/{jsruntime,jsapi,jit}`, +extra 50k in qtdeclarative/src/3rdparty - JSC's macroassembler and YARR)
* Language:   C++
* License:    LGPL, GPL, Qt
* Org:        Qt
* Regex:      YARR
* Standard:   ES2016
* Tech:       register VM, JIT
* VM:         register-based VM with accumulator ([qv4vme_moth.cpp](https://github.com/qt/qtdeclarative/blob/dev/src/qml/jsruntime/qv4vme_moth.cpp))
* Years:      2012-

## History

Started out in 2012 as V8 wrapper, then switched to a home-grown engine.

## Components

* Top-level repository: https://code.qt.io/qt/qt5.git
* Engine code in [qtdeclarative/src/qml](https://github.com/qt/qtdeclarative/tree/dev/src/qml)

## Users

* [Okular](https://github.com/KDE/okular)
