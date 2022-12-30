compile: lib/dynamics.wasm lib/dynamics-coll.wasm lib/dynamics-opt.wasm

./12-/dynamics.wasm:
	@../llvm-wasm/bin/clang -S --target=wasm32 -Oz -Wno-logical-op-parentheses native/demo.c -c -o native/demo.s
	@../binaryen/bin/s2wasm native/demo.s > native/demo.wast
	@rm native/demo.s
	@../wabt/out/wast2wasm native/demo.wast -o ./12-/dynamics.wasm

./13-/dynamics-coll.wasm:
	@../llvm-wasm/bin/clang -S --target=wasm32 -Oz -Wno-logical-op-parentheses native/demo-coll.c -c -o native/demo-coll.s -I../wasm-stdlib-hack/include/libc
	@../binaryen/bin/s2wasm native/demo-coll.s > native/demo-coll.wast
	@rm native/demo-coll.s
	@../wabt/out/wast2wasm native/demo-coll.wast -o ./13-/dynamics-coll.wasm

./15-/dynamics-opt.wasm:
	@../llvm-wasm/bin/clang -S --target=wasm32 -Oz -Wno-logical-op-parentheses native/demo-opt.c -c -o native/demo-opt.s -I../wasm-stdlib-hack/include/libc
	@../binaryen/bin/s2wasm native/demo-opt.s > native/demo-opt.wast
	@rm native/demo-opt.s
	@../wabt/out/wast2wasm native/demo-opt.wast -o ./15-/dynamics-opt.wasm

clean:
	rm native/demo.s native/demo-coll.s native/demo-opt.s native/demo.wast native/demo-coll.wast native/demo-opt.wast

.PHONY: ./12-/dynamics.wasm ./13-/dynamics-coll.wasm ./15-/dynamics-opt.wasm
