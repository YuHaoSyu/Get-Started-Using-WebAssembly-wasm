# Allocate Dynamic Memory in WebAssembly with Malloc
我們演示瞭如何構建依賴於 malloc 的 WebAssembly 模塊，在運行時鏈接預構建的 malloc 實現，使用 JS 綁定技巧來處理兩個 WebAssembly 模塊之間的循環引用。 然後我們優化加載過程以確保我們並行獲取這些模塊。

Malloc implementation: https://github.com/guybedford/wasm-stdlib-hack/blob/master/dist/memory.wasm
***
### program.c
```
#include <stdlib.h>

struct Record {
	int id;
	float x;
	float y;
};

struct Record* createRecord (int id, float x, float y) {
	struct Record* record = malloc(sizeof(struct Record));
	record->id = id;
	record->x = x;
	record->y = y;
	return record;
}

void deleteRecord (struct Record* record) {
	free(record);
}
```
### test.html
```
<!doctype html>
	<script>
		function fetchAndCompileWasmModules (urls) {
			return Promise.all(urls.map(url => {
				return fetch(url)
				.then(res => {
					if (res.ok) return res.arrayBuffer();
					throw new Error(`Unable to fetch Web Assembly file ${url}.`);
				})
				.then(bytes => WebAssembly.compile(bytes));
			}));
		}

		let wasmMalloc, wasmFree;
		// https://github.com/guybedford/wasm-stdlib-hack/blob/master/dist/memory.wasm
		fetchAndCompileWasmModules(['./program.wasm', './memory.wasm'
		])
		.then(([program, memory]) => {
			return WebAssembly.instantiate(program, {
				env: {
					malloc: len => wasmMalloc(len),
					free: addr => wasmFree(addr)
				}
			})
			.then(m => {
				return WebAssembly.instantiate(memory, {
					env: {
						memory: m.exports.memory
					}
				})
				.then(m => {
					wasmMalloc = m.exports.malloc;
					wasmFree = m.exports.free;
				})
				.then(() => {
					console.log(m.exports.createRecord(2, 1.1, 2.2));
				});
			});
		});
	</script>
```
對於 WebAssembly 中動態內存分配的一個簡單示例，讓我們考慮我們有一個記錄數據類型，它具有一些與之關聯的任意字段。 例如，一個 ID、一個 X 和一個 Y 值。

為了動態創建這些記錄之一，我們將使用 createRecord 函數，它將其字段作為參數。 然後我們可以在這個函數中使用 malloc 來為每條記錄創建內存。 我們需要將記錄的大小（以字節為單位）傳遞給 malloc，以便我們可以在此處使用 sizeof 運算符。

我們得到的值是新記錄的內存地址，因此是指向記錄的指針。 我們現在可以使用這個指針將 ID X 和 Y 值直接設置到新的內存地址中。 最後，我們將從 createRecord 函數返回內存地址，因此該函數返回一個指向記錄的指針。

要創建一個 deleteRecord 函數，這將是一個沒有返回值的函數，它在內存中獲取一個記錄地址，然後對該內存地址調用 free。 當然，還有更有效和更好的方法來做到這一點，但這只是一個例子。 為了使用 malloc 和 free，我還將包括標準庫。

查看生成的 WebAssembly 代碼，我們可以看到 free 和 malloc 函數都被視為導入函數。 由我們自己將它們聯繫起來。 正在導出內存，然後我們定義了 createRecord 和 deleteRecord 函數。

查看 deleteRecord 函數，我們可以看到它以一個 32 位整數作為參數，這是 WebAssembly 中的內存地址。 然後使用局部參數中的參數編號調用自由函數。

簡要查看 createRecord 函數，我們還可以看到它正在調用 malloc，將其存儲在局部變量中，編號為 3，在此處定義。 然後它使用 F32.store、I32.store 和 F32.store 調用在內存中保存作為參數傳遞的 ID X 和 Y 值的記錄，最後返回存儲在局部變量中的內存地址 .

讓我們下載 WebAssembly 代碼，並將其連接起來。在我的本地項目中，我包含了獲取和實例化 WASM 幫助程序，我將把它轉到我們剛剛下載的本地 program.wasm 文件。

對於導入對象，我將需要傳遞一個環境導入，其中包含 malloc 和 free 實現。 稍後我會談到這一點。 這個承諾解決了 WebAssembly 模塊導出，其中包含我們的 createRecord 函數。

我將用任意值調用它，然後記錄結果。 為了在 malloc 和 free 中鏈接，我實際上已經從 C 預構建到 WebAssembly 中，一個 malloc 和 free 實現，我只是要從 memory.wasm 中的現有文件加載它。

該文件的鏈接包含在課程描述中。 這個 memory.wasm 文件採用單個環境導入，它設置了內存。 之所以會這樣，是因為malloc和free都需要作用於程序的內存，這個是程序自己定義的，因為它導出了自己的內存。

在 WebAssembly 中，我們一次只能處理一個內存，至少目前是這樣，所以我們想將該程序的內存傳遞到內存的內存中。 我將從導出它的 m.memory 訪問它。

然後，我們從 memory.wasm 返回的模塊值包含我們的 malloc 和綁定到程序內存的自由函數。 我們如何將這些 malloc 和 free 函數放入 program.wasm 的導入中？

我將在這里通過為這些稱為 WASMmalloc 和 WASMfree 的函數創建臨時佔位符來使用間接尋址。 在導入到 program.wasm 的環境中，我實際上將創建一個 malloc 的 JavaScript 實現，並返回應用於該長度的 WASMmalloc 結果。

free 函數也是如此，它將獲取一個地址，並返回該地址的 WASMfree。 我們現在只需要從我們從內存中取回的版本分配 WASMmalloc，對於 WASMfree 實現也是如此。

最後，我將確保僅在所有設置完成後才調用我們的 createRecord 函數。 當我們運行它時，我們可以看到我們正在獲得一個動態分配的內存地址。

我已經進行了性能測量，以查看這些 JS 綁定的成本是多少。 因為我們沒有直接鏈接到 WebAssembly，我們跳過了 JavaScript，在我的測試中，性能開銷非常非常小，在其他方面非常高效的代碼上大約只有 5%。

如果這讓您擔心，那麼在這裡要做的更好的事情是讓 program.wasm 也導入它的內存。 這段代碼中還有另一個性能問題，那就是我們正在獲取 program.wasm，然後只有在獲取和編譯後，我們才會獲取 memory.wasm。

我們真正想做的是並行獲取，以便我們盡可能地利用網絡。 我們可以調整這個獲取和實例化 WASM 函數，將其轉換為並行獲取和編譯函數，該函數將取一個 URL 數組來獲取和編譯。

我們用它來並行獲取程序和內存。 然後我們需要自己調用 WebAssembly.instantiate。 這將 imports 對像作為它的第二個參數，所以其餘的代碼實際上是一樣的。 我會把所有的東西都複製進去。

最後的區別是 WebAssembly.instantiate 的返回值是一個模塊對象，所以我們需要直接訪問它的 exports 屬性。 這給了我們並行加載器。