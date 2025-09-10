OCTANE_PARTS := \
   richards.js \
   deltablue.js \
   crypto.js \
   raytrace.js \
   earley-boyer.js \
   regexp.js \
   splay.js \
   navier-stokes.js \
   pdfjs.js \
   mandreel.js \
   gbemu-part1.js \
   gbemu-part2.js \
   code-load.js \
   box2d.js \
   zlib.js \
   zlib-data.js \
   typescript.js \
   typescript-input.js \
   typescript-compiler.js

OCTANE_TESTS := \
   richards.js \
   deltablue.js \
   crypto.js \
   raytrace.js \
   earley-boyer.js \
   regexp.js \
   splay.js \
   navier-stokes.js \
   pdfjs.js \
   mandreel.js \
   gbemu.js \
   code-load.js \
   box2d.js \
   zlib.js \
   typescript.js

all: v9.js

# Generate self-contained test files from octane benchmark
# with fixes to help buggy engines get through some tests.
v9.js: octane/zlib.js
	echo '// Single self-contained test from octane benchmark' >head.js
	echo '// https://github.com/chromium/octane' >>head.js
	echo 'if (typeof print === "undefined" && typeof "console" !== "undefined") print = console.log;' >>head.js
	# Some engines don't like undeclared variables.
	echo 'var alert=print, read, require, setupEngine, nValue, eValue, dValue, pValue, qValue, dmp1Value, dmq1Value, coeffValue, result, Mandreel_timeouts, Mandreel_XMLHttpRequest, Mandreel_document, Mandreel_window;' >>head.js
	echo '' >>head.js
	cat octane/base.js >>head.js
	# Don't print overall score for individual tests
	cat octane/run.js | sed -Ee 's|^load|//load|; s|^(function PrintScore.*)|\1 return;|' >tail.js
	for x in $(OCTANE_PARTS); do \
	  rm -f "_$$x"; \
	  cp -f "octane/$$x" "_$$x"; \
	done
	# QuickJS-NG triggered by `this.result` in checkResult()
	sed -Ei -e 's/this.result = 0/var result = 0/; s/this.result([^ ]=)/result\1/' _navier-stokes.js
	# Many engines complain about octal sequences
	sed -i -e 's/\\000/\\x00/g; s/\\001/\\x01/g; s/\\002/\\x02/g; s/\\003/\\x03/g; s/\\004/\\x04/g; s/\\005/\\x05/g; s/\\006/\\x06/g; s/\\007/\\x07/g; s/\\010/\\x08/g; s/\\011/\\x09/g; s/\\012/\\x0A/g; s/\\013/\\x0B/g; s/\\014/\\x0C/g; s/\\015/\\x0D/g; s/\\016/\\x0E/g; s/\\017/\\x0F/g; s/\\020/\\x10/g; s/\\021/\\x11/g; s/\\022/\\x12/g; s/\\023/\\x13/g; s/\\024/\\x14/g; s/\\025/\\x15/g; s/\\026/\\x16/g; s/\\027/\\x17/g; s/\\030/\\x18/g; s/\\031/\\x19/g; s/\\032/\\x1A/g; s/\\033/\\x1B/g; s/\\034/\\x1C/g; s/\\035/\\x1D/g; s/\\036/\\x1E/g; s/\\037/\\x1F/g; s/\\040/ /g; s/\\177/\\x7F/g;' _earley-boyer.js
	# Fix for kiesel
	sed -i -e 's/this.RTCHours -= 24$$/this.RTCHours -= 24;/' _gbemu-part2.js
	# Fix for duktape
	sed -i -e 's/if(typeof require === "function") {/if(typeof require === "function" && false) {/' _typescript-compiler.js
	# Generate self-contained single tests
	for x in richards.js deltablue.js crypto.js raytrace.js earley-boyer.js regexp.js splay.js navier-stokes.js pdfjs.js mandreel.js code-load.js box2d.js; do \
	  cat head.js "_$$x" tail.js >"$$x"; \
	done
	cat head.js _gbemu-part1.js _gbemu-part2.js tail.js >gbemu.js
	cat head.js _typescript.js _typescript-input.js _typescript-compiler.js tail.js >typescript.js
	cat head.js _zlib.js _zlib-data.js tail.js >zlib.js
	# QuickJS-NG fails some single tests without mandreel.js in the mix
	cat head.js _pdfjs.js _mandreel.js _gbemu-part1.js _gbemu-part2.js _code-load.js tail.js >mandreel-plus.js
	# Generated combined test: v9.js. Print overall score.
	cat octane/run.js | sed -Ee 's|^load|//load|' >tail.js
	cat head.js $(patsubst %,_%,$(OCTANE_PARTS)) tail.js >v9.js
	rm -rf head.js tail.js $(patsubst %,_%,$(OCTANE_PARTS))

octane/zlib.js:
	git submodule update --init --recursive

clean:
	rm -f head.js tail.js v9.js mandreel-plus.js $(OCTANE_TESTS) $(patsubst %,_%,$(OCTANE_PARTS))
