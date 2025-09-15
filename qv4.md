* Summary:    JavaScript engine of Qt's QML framework.
* URL:        https://wiki.qt.io/V4
* Repository: https://github.com/qt/qtdeclarative.git
  * Top-level: https://code.qt.io/qt/qt5.git
* Standard:   ES2016
* Tech:       register VM, JIT, YARR
* Language:   C++
* License:    LGPL, GPL, Qt
* Org:        Qt
* LOC:        50221 (`cloc qtdeclarative/src/{qml/{jsruntime,jsapi,jit}`)
   * +extra 50k in `qtdeclarative/src/3rdparty/masm` (JSC's masm/yarr)
* Timeline:   2012-
  * Started out in 2012 as V8 wrapper, then switched to a home-grown engine.
* VM: register-based VM with accumulator, 1-arg binary ops
  * https://github.com/qt/qtdeclarative/blob/dev/src/qml/jsruntime/qv4vme_moth.cpp
