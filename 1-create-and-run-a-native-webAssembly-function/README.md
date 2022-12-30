# Create and Run a Native WebAssembly Function
在本介紹中，我們展示了一個簡單的 WebAssembly 函數，它返回數字的平方根。 為了創建這個函數，我們加載了 WebAssembly 資源管理器 (https://mbebenita.github.io/WasmExplorer/)，編寫本機 WAST 代碼來創建和導出函數。 我們編譯並下載生成的 WebAssembly 二進製文件，使用 Fetch API 和 WebAssembly JavaScript API 加載它以在瀏覽器中調用函數。
### test.wat
```
(module
	(export "sqrt" (func $sqrt))
	(func $sqrt
		(param $num f32)
		(result f32)
		(f32.sqrt (get_local $num))
	)
)
```
### test.html
```
<!doctype html>
	<title>WASM Test</title>
	<script>
		fetch('./test.wasm')
		.then(res => {
			if (res.ok) return res.arrayBuffer();
			throw new Error(`Unable to fetch WASM.`);
		})
		.then(bytes => {
			return WebAssembly.compile(bytes);
		})
		.then(module => {
			return WebAssembly.instantiate(module);
		})
		.then(instance => {
			window.wasmSqrt = instance.exports.sqrt;
		});
	</script>
```
		在本課中，我們將了解如何創建一個非常簡單的 WebAssembly 函數。 在這個例子中，一個函數將取一個數字的平方根。 正如你在這裡看到的，這個函數在瀏覽器中作為原生 WebAssembly 代碼運行，我們可以調用它來獲取平方根。

		我將使用一個名為 WebAssembly Explorer 的項目。 這允許我們直接在瀏覽器中編寫純 WebAssembly 代碼，以獲得可在我們的應用程序中使用的二進製文件。

		讓我們直接進入。每個 WebAssembly 文件都以模塊聲明開頭。 然後我們需要自己創建 square_root 函數。 我們可以通過函數聲明來做到這一點。 我們給函數起一個名字，然後在函數內部，我們必須說出函數有哪些參數和返回值。

		對於我們的 square_root 函數，我們將有一個參數，我們可以將其標記為 num。 這個參數的類型是十進制類型，所以我們要在內存中使用float32數字表示。 這意味著它是一個 32 位浮點數。

		結果類型也將是平方根值的相同 float32 輸出。 參數寫好了。 我們現在可以編寫函數體了。 我們想取數字參數的 float32 平方根。 我們讀取該參數的方式是使用 get_local 函數。

		然後我們可以通過我們給它的標籤來引用數字參數。 我們正在讀取參數值，將其傳遞給 square_root 函數，結果將位於函數末尾的此處，自然會成為返回值。 它是正確的類型，因為它已經是 float32。

		為了真正能夠使用此功能，我們希望將其公開給 JavaScript。 我們這樣做的方法是在 WebAssembly 模塊中使用導出聲明。 我們可以給導出一個名字，比如 square_root。 然後我們通過我們給它的函數標籤進一步引用函數，就像你在 JavaScript中導出函數一樣。

		現在我們可以使用瀏覽器內工具組裝二進製文件，然後我們也可以將二進製文件下載到我們的文件系統。 將這個下載的 WebAssembly 文件移動到我們的主項目文件夾，然後我們可以編輯我們的 html 文件來加載 WebAssembly 二進製文件。

		為了在瀏覽器中加載 WebAssembly，我們需要自己獲取和編譯它。 我們將在瀏覽器中使用 fetch 函數來獲取 WebAssembly 二進製文件。 這給了我們回應的承諾。 我們需要檢查響應是否正常，如果是，我們可以從響應中返回數組緩衝區。

		這是因為 WebAssembly 是二進制格式，所以我們要使用原始二進製字節。 如果響應不正常，我們還可以添加一個不錯的錯誤消息。 這將返回那些原始字節，然後我們可以使用 JavaScript WebAssembly API 將其編譯成 WebAssembly 模塊。

		模塊的承諾回來了，然後我們需要實際實例化它以獲得 WebAssembly 模塊實例，所以我們使用 WebAssembly.instantiate。 然後該實例包含一個 exports 屬性，該屬性包含我們所有來自 WebAssembly 模塊的導出和綁定。

		我要從導出中挑選出 square_root 函數並將其寫入窗口對象。 我們現在可以在瀏覽器中看到我們的 WebAssembly 函數。
