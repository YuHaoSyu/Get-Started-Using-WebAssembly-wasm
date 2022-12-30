# Read WebAssembly Memory from JavaScript
我們使用偏移量導出函數來獲取字符串在 WebAssembly 內存中的地址。 然後，我們在表示原始字符串數據的 WebAssembly 內存之上創建一個類型化數組，並將其解碼為 JavaScript 字符串。
### program.c
```
char str[] = "Hello World";

char* getStrOffset () {
	return &str[0];
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
				if (res.ok)
					return res.arrayBuffer();
				throw new Error(`Unable to fetch Web Assembly file ${url}.`);
			})
			.then(bytes => WebAssembly.compile(bytes))
			.then(module => WebAssembly.instantiate(module, imports || {}))
			.then(instance => instance.exports);
		}

		fetchAndInstantiateWasm('./program.wasm')
		.then(m => {
			const memory = m.memory;
			const strBuf = new Uint8Array(memory.buffer, m.getStrOffset(), 11);
			const str = new TextDecoder().decode(strBuf);
			console.log(str);
		});
	</script>
```
使用 WebAssembly 中的函數，我們可以傳遞單個數值。 我們僅限於整數和浮點數，32 位或 64 位。 標準 WASM 填充程序示例有一個返回數字的函數。 當我們構建並運行它時，我們可以記錄該數字。 我們通過接口傳遞數字。

如果我想處理像字符串這樣的東西怎麼辦？ 在 C 中，我們使用字符數組定義字符串。 如果我想將這個“hello world”字符串傳遞給 JavaScript，我該怎麼做呢？

一種選擇是創建一個函數 getChar，它返回單個偏移量的單個字符。 我們仍然返回一個代表字符的數字，但我們可以多次調用它來獲取整個字符串。

如果我返回字符串的單個項目，我們就可以從 JavaScript 調用這個函數。 使用零調用 JavaScript 中的 getChar 函數以獲取字符串的第一個字符，然後我們可以看到返回的 H 的字符代碼。

然後我們可以使用一些代碼將其轉換為正確的字符串字符，然後我們可以逐個字母地讀出字符串。 值得慶幸的是，有更好的方法可以做到這一點。 我將創建一個名為 getStringOffset 的 char 指針返回函數，而不是 getChar 函數。

這個函數要做的是返回字符串第一個字符的內存地址。 當我們構建它時，我們可以在下面的代碼中看到，getStringOffset 返回一個數字，它是一個 32 位整數。 它是一個常量整數，16。

這是我們的字符串在 WebAssembly 內存中的地址。 如果我們進一步查看此輸出，我們可以看到有一個數據部分。 數據部分用於在我們的 WebAssembly 模塊中創建預分配內存。

該數據段分配在地址號 16，內容為“hello world”。 那麼我們的記憶也被輸出到這裡了。 我們已經得到了包含我們想要的數據的單個可尋址線性內存。

現在，我們只需編寫 JavaScript 即可讀取它。 我要做的第一件事是讀出內存導出，它直接是 instance.export 的內存屬性。 我們在 JavaScript 中訪問原始內存的方式是使用類型化數組。

我們想在此 WebAssembly 內存之上創建一個類型化數組來表示我們的字符串。 字符串的每個字符都是八位。 我將在 WebAssembly 內存、memory.buffer 屬性之上使用 Uint8 數組類型數組，然後指定我們的字符串開始的 WebAssembly 內存中的偏移量。

調用 getStringOffset 函數，我們可以獲得這個地址，16。我們類型化數組的最後一個參數是緩衝區的長度，在本例中為字符串的 11 個字符。 最後，要將此原始緩衝區轉換為實際的 JavaScript 字符串，我們使用文本解碼 API。 我們傳遞了原始緩衝區，它返回了我們可以在控制台中登錄的字符串。