if (typeof console === "undefined") { console = {log: print}; };
var i, j, total, n, CACHE = new Array(80);
for (j = 0; j < CACHE.length; j += 10) { CACHE[j] = 0; for (i = 1; i < 10; i++) { CACHE[i + j] = Math.pow(i, i); } }
loop: for (i = 0; i < 440000000; i++) { total = 0; n = i; while (n > 0) { total += CACHE[n % 80]; if (total > i) { continue loop; } n = (n / 10) | 0; } if (total < i) continue loop; console.log(i); }
