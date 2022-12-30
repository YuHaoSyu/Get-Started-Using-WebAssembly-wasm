# A First Comparison of the Performance between JS and WebAssembly
為了比較 JS 和 WebAssembly 的性能，我們使用一個例子來計算屏幕上圓圈之間的碰撞。 這會迅速降低渲染性能，從而使性能比較可見。 我們簡單回顧一下將 JS 轉換為 C 代碼的相同步驟，發現 JS 版本的代碼實際上比 WASM 版本的代碼更快——WebAssembly 提高性能並不是一個簡單的論點。

		在這個例子中，我們正在計算頁面上圓圈之間的碰撞，這會增加相當大的性能開銷。 如果我將 circle_count 增加到 2,000，我們已經可以開始看到明顯的減速，所以讓我們看看我們與 WebAssembly 的對話是否可以使速度更快。

		無需深入了解碰撞算法的細節，我們只需將 JavaScript 複製到我們的 C 文件中即可開始轉換。 要簡要地完成這些步驟，將 circle_count 定義為宏，更新函數簽名，將類型添加到我們的變量，修復迭代以查找我們的外部數學函數，並更新它們的調用，為數學和 [indecipherable] 庫添加包含 .

		然後，編譯器可以使用這些函數內聯我們對平方根、冪和 [indecipherable] 的使用。

		接下來，定義我們的圓和圓速度結構並初始化這些數組——長度、圓計數——用於它們的靜態分配[indecipherable]獲取 circle_count 函數並獲取 circle_data_offset 函數以知道在哪裡找到 wasm 內存中圓位置數據的地址。

		最後，我們修復了 circle_data 結構數組中的索引訪問，以正確引用數據值。 然後我們可以使用 WasmFiddle 進行編譯，下載最終的 WebAssembly 二進製文件。 在新頁面中，我現在可以包含 wasm 幫助程序並使用它來加載我位於 dynamics_call.wasm 的 WebAssembly 二進製文件。

		這個函數的第二個參數是導入。 我們需要設置環境，其中包含一個隨機 F 和 exp 函數。

		承諾 [indecipherable] 我們返回實例化模塊，然後我們可以從我們導入的函數中讀取 circle_count 和 circle_data_offset。 我們可以使用我們提供的偏移量以及我們知道它將是 WebAssembly 內存中的 circle_count 長度的三倍這一事實，為圓數據構建我們的類型化數組數據。

		最後，我們可以渲染該圓數據，將 init 和 timestep 方法從我們的 WebAssembly 二進製文件傳遞到渲染函數中。 左邊是JS模擬，右邊是WebAssembly版本，我們可以直接比較性能。

		不幸的事實是，左側的 JS 版本實際上最終仍然比我們的 WebAssembly 更快。 WebAssembly 不是提高性能的靈丹妙藥。 這可能只是我們在瀏覽器中對 WebAssembly 進行優化的早期階段，但如果我們以正確的原則處理性能，我們今天可以克服這個問題。