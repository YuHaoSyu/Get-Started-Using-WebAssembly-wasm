### Examples: Introduction to WebAssembly

Course examples from the Introduction to WebAssembly egghead.io course.

### Plunkr Links

1. [Creating and Running a Native WebAssembly Function](https://embed.plnkr.co/tFyR689ChxLsH6QtRiS8?autoCloseSidebar=true&show=test.wast,index.html)
2. [Compiling C Code into Web Assembly](https://embed.plnkr.co/U2Xr87qBo2gZxbthKexo?autoCloseSidebar=true&show=program.c,index.html)
3. [Calling a JavaScript Function from WebAssembly](https://embed.plnkr.co/nXJcTfVrztxSLqo8iN0a?autoCloseSidebar=true&show=program.c,index.html)
4. [Reading WebAssembly Memory](https://embed.plnkr.co/Sb6oQl4Y0zcqWLVKjWb5?autoCloseSidebar=true&show=program.c,index.html)
5. [Writing WebAssembly Memory](https://embed.plnkr.co/SnBwi3sUmcFQhh0FPIsR?autoCloseSidebar=true&show=program.c,index.html)
6. [Dynamic Memory Allocation in WebAssembly with malloc](https://embed.plnkr.co/hpV47vbXw32RtMjtoQGM?autoCloseSidebar=true&show=program.c,index.html)
7. [Creating and Importing a WebAssembly Memory](https://embed.plnkr.co/oeypCwihZ3C2SsnIud6v?autoCloseSidebar=true&show=program.wast,index.html)


### Demo Project: Introduction to WebAssembly

Demo project from the Introduction to WebAssembly egghead.io course.

__Due to the use of ES Modules and WebGL 2, these demos are currently only supported in Chrome Canary with the [Experimental Web Platform Flag](chrome://flags/#enable-experimental-web-platform-features) enabled from chrome://flags.__

1. [demo-js.html](https://embed.plnkr.co/FFN9MY6gcpnh3PPR0Qya?autoCloseSidebar=true): Introduction to the renderer.
2. [demo-wasm.html](https://embed.plnkr.co/V14384GNZsGtwZJZNt1O?autoCloseSidebar=true&show=demo.c,index.html,preview): Used in the JS to WASM conversion step-by-step example.
3. [demo-js-coll.html](https://embed.plnkr.co/DI8imAG2fpKwqqAMxqWS?autoCloseSidebar=true): Includes collisions between circles.
4. [demo-wasm-coll.html](https://embed.plnkr.co/cN4q3f6EdCCSpM8U1MV3?autoCloseSidebar=true&show=demo-coll.c,preview): Used to compare performance between JS and WASM.
5. [demo-js-opt.html](https://embed.plnkr.co/HjBosWsN4YNi8M1cJt7h?autoCloseSidebar=true): Optimized grid-based collision algorithm.
6. [demo-wasm-opt.html](https://embed.plnkr.co/jsMi5oltGnT0Jn38js3v?autoCloseSidebar=true&show=demo-opt.c,preview): WebAssembly conversion demonstrating the faster-performing grid of linked-lists.

### Build

`make` is structured assuming `../llvm-wasm/bin/clang`, `../binaryen/bin/s2wast` and `../wabt/out/wast2wasm` executables.

See the setup lessons for a direct install command, and for installing LLVM, Binaryen and WABT.

#### License

MIT