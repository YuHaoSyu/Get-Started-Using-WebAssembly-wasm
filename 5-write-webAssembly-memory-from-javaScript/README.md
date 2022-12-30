# Write to WebAssembly Memory from JavaScript
我們在 WebAssembly 中編寫了一個將字符串轉換為小寫的函數，演示瞭如何從 JavaScript 設置輸入字符串。
### program.c
```
void consoleLog (char* offset, int len);

char inStr[20];
char outStr[20];

char* getInStrOffset () {
	return &inStr[0];
}

void toLowerCase () {
	for (int i = 0; i < 20; i++) {
		char c = inStr[i];
		if (c > 64 && c < 91) {
			c = c + 32;
		}
		outStr[i] = c;
	}
	consoleLog(&outStr[0], 20);
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

		let mem;
		function writeString (str, offset) {
			const strBuf = new TextEncoder().encode(str);
			const outBuf = new Uint8Array(mem.buffer, offset, strBuf.length);
			for (let i = 0; i < strBuf.length; i++) {
				outBuf[i] = strBuf[i];
			}
		}
		fetchAndInstantiateWasm('./program.wasm', {
			env: {
				consoleLog (offset, len) {
					const strBuf = new Uint8Array(mem.buffer, offset, len);
					console.log(new TextDecoder().decode(strBuf));
				}
			}
		})
		.then(m => {
			mem = m.memory;
			writeString("Hello Web Assembly", m.getInStrOffset());
			m.toLowerCase();
		});
	</script>
```
在這個示例應用程序中，我在我的 C 應用程序的主函數中調用了一個 console.log 函數。 該函數將兩個參數和偏移量放入 WebAssembly 內存中，這是我定義的字符串的第一個字符，然後是該內存中的長度，即字符串的長度。

運行時，此函數是在 JavaScript 中定義的，它會在頂部 WebAssembly 內存上為該偏移量和長度創建一個 [無法辨認] 緩衝區。 然後它使用文本解碼器解碼字符串並記錄輸出的 JavaScript 字符串。

我們正在從 WebAssembly 內存中讀取原始數據。 如果我們想寫入 WebAssembly 內存怎麼辦？ 例如，我將考慮一個函數 to_lower_case，我們在其中獲取一個輸入字符串，然後輸出一個輸出字符串，該字符串是它的小寫版本。

我們將在這裡有兩個字符串，我會說它們都是 20 個字符長。 在 to_lower_case 函數中，我們現在可以遍歷字符串的每個字符。 我們從輸入字符串中讀取字符值，然後我們可以根據 ASCII 範圍檢查它是否是大寫字母。

使用按位運算要快得多，但為了清楚起見，我們可以只檢查它是否在 ASCII 的 65 到 90 範圍內。 如果它在那個範圍內，我們就改變它。 一旦我們得到小寫字符的結果，我們就將其設置到輸出字符串中。

為了讓它真正容易運行，我將在輸出字符串的地址上運行 console.log 函數，總長度，並刪除 main 函數。 為了能夠在 JavaScript 中寫入輸入字符串，我將創建一個 get_offset 函數，就像我們之前所做的那樣，它返回 WebAssembly 內存中輸入字符串的地址。

成功構建後，我們將在 JavaScript 中執行的操作是通過從 JavaScript 編寫 WebAssembly 內存來填充該輸入字符串。 然後我們將調用 to_lower_case 函數，然後它將繼續並為我們記錄小寫輸出。

我們想要的是一個函數，它允許我們將 JavaScript 中的字符串寫入該 WebAssembly 內存中。 然後我們可以提供寫入該內存的位置的偏移量，然後我們可以從我們編寫的 get_in_string_offset 函數中獲取該偏移量。

為了創建這個 write_string 函數，我們將採用它的字符串和偏移量輸入。 您要做的第一件事是從字符串生成原始字節緩衝區。 為此，我們可以像上面那樣使用文本編碼器接口將 JavaScript 字符串轉換為類型化數組 Uint8 緩衝區。

為了寫入 WebAssembly 內存，我們將創建另一個緩衝區，它代表輸入字符串“WebAssembly 內存”。 我們將在傳遞的輸入字符串的偏移量處從 WebAssembly 內存緩衝區生成它。

我們還將把它設置為我們剛剛創建的緩衝區的長度，我們將寫入它。 循環遍歷字符串緩衝區中的每個字節索引，然後我們可以設置輸出緩衝區，它代表 WebAssembly 內存中的輸入字符串，設置該字符串緩衝區中的每個字節。

通過直接寫入 WebAssembly 類型數組，我們直接寫入 WebAssembly 內存。 運行這個，我們可以看到它正確地小寫了我們從 JavaScript 設置的輸入字符串，包括末尾的一些空字節，因為我們已經將它填充到 20 個字符。

這裡值得注意的是，在 JavaScript 和 WebAssembly 之間進行的這種內存複製有相當多的性能開銷。 出於這個原因，值得非常仔細地考慮一段內存屬於哪裡，作為它的真實來源，並讓它始終作為主要真實來源，以盡量減少複製操作。