* Summary:    Lightweight embeddable JavaScript engine by Fabrice Bellard and Charlie Gordon.
* URL:        https://bellard.org/quickjs/
* Repository: https://github.com/bellard/quickjs.git
* Standard:   ES2023
* Tech:       stack VM, hidden classes w/o PIC, refcounting GC
* Language:   C
* License:    MIT
* LOC:        73590 (`cloc *.c *.h`)
* Timeline:   2019-

VM: `JS_CallInternal()` at https://github.com/bellard/quickjs/blob/master/quickjs.c#L16845
