# Create and Import a WebAssembly Memory
從前面的例子開始，我們重建程序代碼以導入它的內存而不是導出它。 然後我們使用它來簡化應用程序加載代碼。
Emscripten: https://kripken.github.io/emscripten-site/
### program.wast
```
(module
	(type $FUNCSIG$ii (func (param i32) (result i32)))
	(type $FUNCSIG$vi (func (param i32)))
	(import "env" "memory" (memory $mem 1))
	(import "env" "free" (func $free (param i32)))
	(import "env" "malloc" (func $malloc (param i32) (result i32)))
	(table 0 anyfunc)
	(export "createRecord" (func $createRecord))
	(export "deleteRecord" (func $deleteRecord))
	(func $createRecord (param $0 i32) (param $1 f32) (param $2 f32) (result i32)
		(local $3 i32)
		(f32.store offset=4
			(tee_local $3
				(call $malloc
					(i32.const 12)
				)
			)
			(get_local $1)
		)
		(i32.store
			(get_local $3)
			(get_local $0)
		)
		(f32.store offset=8
			(get_local $3)
			(get_local $2)
		)
		(get_local $3)
	)
	(func $deleteRecord (param $0 i32)
		(call $free
			(get_local $0)
		)
	)
)
```
### test.html
```
<!doctype html>
	<script>
		function fetchAndCompileWasmModules (urls) {
			return Promise.all(urls.map(url => {
				return fetch(url)
				.then(res => {
					if (res.ok)
						return res.arrayBuffer();
					throw new Error(`Unable to fetch Web Assembly file ${url}.`);
				})
				.then(bytes => WebAssembly.compile(bytes));
			}));
		}

		let mem = new WebAssembly.Memory({ initial: 1 });
		fetchAndCompileWasmModules([
			'./program.wasm',
			'./memory.wasm'
		])
		.then(([program, memory]) => {
			return WebAssembly.instantiate(memory, {
				env: {
					memory: mem
				}
			})
			.then(m => {
				return WebAssembly.instantiate(program, {
					env: {
						malloc: m.exports.malloc,
						free: m.exports.free,
						memory: mem
					}
				});
			})
			.then(m => {
				console.log(m.exports.createRecord(2, 1.1, 2.2));
			});
		});
	</script>
```
		在這個應用程序中加載程序和 memory.wasm 有一個相當複雜的實例化過程。 原因是程序正在導出其內存，然後內存需要導入相同的內存。

		我們先實例化程序，把它的內存導出，也就是m.exports.memory，在實例化內存的時候作為內存導入傳入。 另一種方法是在實例化 WebAssembly 模塊之前在 JavaScript 中創建內存。

		WebAssembly 內存構造函數採用單個參數，然後可以在 WebAssembly 頁面中設置初始內存大小。 WebAssembly 頁面為 64 kibibytes，或 2^16 字節。 對於此應用程序，一個就綽綽有餘了。

		有了現在在 JavaScript 中創建的內存，我們就可以在實例化內存模塊時將其傳遞到內存導入中。 我們也想對程序模塊的實例化做同樣的事情，因為在這個例子中我們需要所有的模塊共享相同的內存。

		不幸的是，程序沒有內存導入，因為它是用內存導出編譯的，根據定義，這意味著它有一個不同的、獨立的內存。 我們將需要重新編譯程序來支持這一點。

		從原始編譯中，我將獲取 WAST 輸出，並將其複製到 WebAssembly Explorer 中。 在 WebAssembly Explorer 中，我們可以編輯這個 WAST 輸出。 我將在定義它的地方找到該內存。 我將從模塊內部刪除內存定義，並將導出內存轉換為導入內存。

		我們需要從名為環境的模塊中導入內存，因為這是我們從中導入所有內容的地方。 然後我將用包含初始大小的內存聲明替換此內存聲明，這是第一個參數。

		然後我可以組裝並下載這個轉換後的二進製文件。 在本地編譯時，有一個導入內存標誌可以自動執行此操作。 返回到連接了新 program.wasm 的本地應用程序，它現在將在環境命名空間下接受內存導入。

		我現在可以通過首先實例化內存來簡化此實例化，然後使用我們取回的內存模塊，我們可以將 memory.export 的 .free 和 malloc 直接傳遞到程序導入中，因為它已經綁定到相同的 程序使用的內存。

		有了程序的結果和實例化，我們就得到了最終的模塊值，以及一個更簡單的實例化過程。 這裡需要做一些工作才能將這些 WebAssembly 模塊正確地連接在一起。

		好處是，我們能夠最終控制我們的應用程序的引導以滿足我們的確切需求。 如果您正在尋找一個管理 WebAssembly 設置的全面解決方案，我強烈建議您試用 Emscripten，它隨附標準 C、C++ 應用程序編譯，開箱即用，可自行處理所有佈線。 描述中有指向該項目的鏈接。