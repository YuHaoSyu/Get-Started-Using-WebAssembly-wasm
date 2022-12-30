# Call a JavaScript Function from WebAssembly
使用 WASM Fiddle，我們展示瞭如何編寫一個簡單的數字記錄器函數，該函數調用在 JavaScript 中定義的 consoleLog 函數。 然後我們在本地項目中下載並運行相同的函數。
### program.c
```
#include <math.h>

void consoleLog (float num);

float getSqrt (float num) {
	consoleLog(num);
	return sqrt(num);
}
```
### test.html
```
<!doctype html>
	<title>WASM Test</title>
	<script>
		function fetchAndInstantiateWasm (url, imports) {
			return fetch(url)
			.then(res => {
				if (res.ok) return res.arrayBuffer();
				throw new Error(`Unable to fetch Web Assembly file ${url}.`);
			})
			.then(bytes => WebAssembly.compile(bytes))
			.then(module => WebAssembly.instantiate(module, imports || {}))
			.then(instance => instance.exports);
		}

		fetchAndInstantiateWasm('./program.wasm', {
			env: {
				consoleLog: num => console.log(num)
			}
		})
		.then(m => {
			console.log(m.getSqrt(5));
		});
	</script>
```
		在編寫 WebAssembly 時，我們遇到的問題之一是調試工作流。 我們實際上可以在瀏覽器控制台中獲取這種原始的 WebAssembly 格式並逐步執行它，但它通常對於發現問題不是很有用。

		源映射即將到來，但與此同時，不幸的是我們不得不退回到一些舊的 JavaScript 技巧。 要調試此 get_square_root 函數，我要做的是創建一個我可以調用的 console.log 函數。 例如，如果我想知道這個函數得到了什麼輸入，我只想記錄那個數字。

		我們可以創建 console.log 函數的方法是調用這個實際存在於 JavaScript 中的函數。 我們在 C 中定義了這個函數的形狀，並將其視為外部函數。 它沒有返回值，所以它是一個空值。 然後輸入值將是一個浮點數。

		我們將只定義該簽名。 當我們構建我們的 WebAssembly 時，我們會看到這個函數被自動視為一個外部函數，並且它在我們的模塊中可以作為輸入使用。 它從名為 environment 的模塊導入 console.log。

		這只是 C 代碼編譯過程外部的默認模塊命名空間名稱。 在此處的實例化代碼中，我們將這個 wasm 導入對像用於創建實例。 我打算將其更改為直接對象文字並將該環境值設置為包含 console.log。

		通常情況下，我們會將其設置為 console.log 函數，但因為我在 WasmFiddle 中，所以我想使用 WasmFiddle 日誌函數，它只是稱為日誌。 我們現在可以執行這段代碼，我們可以在記錄輸出值之前看到記錄的輸入值。

		我們直接從 WebAssembly 中運行一個 JavaScript 函數。 為了在我們的本地應用程序中快速加載相同的工作流程，我將下載 WebAssembly 二進製文件。 切換到本地應用程序，我首先要包括我們的 wasm 助手。 使用這個助手，我將獲取我們位於項目文件夾中的 program.wasm 文件。

		這個助手的可選第二個參數是導入對象。 這是我們可以設置環境模塊的地方。 我要設置環境模塊的console.log函數，這次只是在瀏覽器中直接console.log函數。 我們為這個 fetchAndInstantiate 調用返回的承諾是我們執行的 WebAssembly 模塊，其中包含對像上可用的導出。

		我現在可以使用任何輸入值直接調用 get_square_root 函數。 如果我也記錄輸出，我們應該在瀏覽器中看到記錄的輸入和輸出。