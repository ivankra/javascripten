# QV4

* Summary:    JavaScript engine of Qt's QML framework.
* URL:        https://wiki.qt.io/V4
* Repository: https://github.com/qt/qtdeclarative.git
* LOC:        50221 (`cloc qtdeclarative/src/{qml/{jsruntime,jsapi,jit}`)
* Language:   C++
* License:    LGPL, GPL, Qt
* Org:        Qt
* Standard:   ES2016
* Tech:       register VM, JIT, YARR
* Years:      2012-

## History

Started out in 2012 as V8 wrapper, then switched to a home-grown engine.

## Components

Top-level repository: https://code.qt.io/qt/qt5.git

Code in qtdeclarative: https://github.com/qt/qtdeclarative/tree/dev/src/qml

qtdeclarative/src/3rdparty: JSC's macroassembler and YARR regex engine (+extra ~50k LOC)

VM ("Moth"): register-based VM with accumulator, 1-arg binary ops.
  * https://github.com/qt/qtdeclarative/blob/dev/src/qml/jsruntime/qv4vme_moth.cpp
