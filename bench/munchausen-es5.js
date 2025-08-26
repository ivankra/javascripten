// https://github.com/jabbalaci/SpeedTests/blob/master/javascript/main2.js
if (typeof console === "undefined") { console = {log: print}; };
/*
MIT License

Copyright (c) 2020-2022 Jabba Laci

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
//var i, j, total, n, CACHE
CACHE = new Array(80);

for (j = 0; j < CACHE.length; j += 10) {
    CACHE[j] = 0;
    for (i = 1; i < 10; i++) {
        CACHE[i + j] = Math.pow(i, i);
    }
}

loop: for (i = 0; i < 440000000; i++) {
    total = 0;
    n = i;
    while (n > 0) {
        total += CACHE[n % 80];
        if (total > i) {
            continue loop;
        }
        n = (n / 10) | 0;
    }
    if (total < i) continue loop;
    console.log(i);
}
