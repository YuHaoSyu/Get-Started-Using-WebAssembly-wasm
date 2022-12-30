# Compile C Code into WebAssembly
我們使用 C 語言而不是純 WAST，使用 WASM Fiddle (https://wasdk.github.io/WasmFiddle//) 創建平方根函數。 我們展示瞭如何在 WASM Fiddle 中運行 WebAssembly，然後使用輔助函數在瀏覽器中下載並運行它以加載 WebAssembly。
### program.c
```
#include <math.h>

float getSqrt (float num) {
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

    fetchAndInstantiateWasm('./program.wasm')
    .then(m => {
      window.getSqrt = m.getSqrt;
    });
  </script>
```
    在本課中，我使用了一個名為 WasmFiddle 的項目，它允許我在此處的框中編寫 C 語言，並在瀏覽器中將其編譯為 WebAssembly，並運行它進行試驗。

    將會有很多很多語言可以編譯成 WebAssembly。 這是 WebAssembly 的主要優點之一，但如果我們想玩弄它並理解 WebAssembly，C 是執行此操作的最佳級別之一，因為它是原始彙編代碼之上的非常低級別的抽象。

    讓我們創建一個 get_square_root 函數。 該函數的返回值將是一個浮點數。 默認情況下，float 是 32 位類型，然後我們要調用這個函數 	get_square_root。 這個函數的輸入將再次是一個浮點數。

    然後，我們將返回一個數字的平方根。 在 C 語言中，平方根函數是從數學頭文件中加載的，所以我只是將這個頭文件放在頂部。 我們現在可以構建代碼。

    在底部，我們的 WebAssembly 模塊出現了。 我們可以看到它正在導出我們的 get_square_root 函數，我們也可以看到這裡定義的函數，它接受一個輸入
    浮點數 32，返回一個浮點數 32，然後取平方根。

    顯然，當你編寫更複雜的 C 代碼時，閱讀這個 [indecipherable] 會變得更加困難，但兩者之間有非常非常直接的轉換。

    如果你想玩弄輸出，這是一個非常簡單的 WebAssembly 同步實例，當你加載 WasmFiddle 時默認出現。 在這個 wasm 實例或導出上，我們可以訪問 C 代碼中的任何函數。

    我要在這裡運行 get_square_root 函數。 我可以用任何號碼調用它，然後使用運行功能。

    要在我們自己的項目中使用此 WebAssembly，我將單擊“下載 WASM”按鈕。 然後我將在本地項目中找到 program.wasm 文件並打開 html。為了加載 wasm，我將使用一個名為 fetchAndInstantiateWasm 的輔助函數。這將從 URL 異步加載 WebAssembly 文件，執行它，並返回該 WebAssembly 模塊的導出。

    我可以直接調用這個函數，傳遞我們程序文件的 URL，即 program.wasm，這將返回一個承諾，返回 wasm 文件的確切導出。 然後我可以直接從可用的 wasm 模塊導出中分配我們的 get_square_root 函數，作為名稱 get_square_root。 如果您在瀏覽器中使用它，我們可以看到 get_square_root 現在可用。