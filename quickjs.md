# QuickJS

* Summary:    Lightweight embeddable JavaScript engine by Fabrice Bellard and Charlie Gordon.
* URL:        https://bellard.org/quickjs/
* Repository: https://github.com/bellard/quickjs.git
* LOC:        73590 (`cloc *.c *.h`)
* Language:   C
* License:    MIT
* Standard:   ES2023
* Tech:       stack VM, hidden classes w/o PIC, refcounting GC
* Years:      2019-

## Components

VM: `JS_CallInternal()` at https://github.com/bellard/quickjs/blob/master/quickjs.c#L16845
