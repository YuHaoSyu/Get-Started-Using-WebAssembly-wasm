# Compiling C/C++ to WebAssembly using LLVM, Binaryen and WABT
我們通過命令行步驟通過 LLVM 將 C/C++ 編譯成中間 S 文件，然後使用 Binaryen 將該 S 文件編譯成 WAST 文件，最後使用 WABT 獲取 WASM 二進製文件。 然後，我們展示了一種為 Web Assembly 克隆和配置自定義標準庫標頭的方法，以構建包含到標準庫中的內容。

		我在 nativedemo.c 中有一個文件，我們將把它編譯成 WebAssembly。 我的 LLVM WebAssembly 構建位於 llvm/wasm。 我將使用 bin/cling 驅動程序來執行 C 或 C++ 編譯。 當我們運行 cling 時，我們還不能直接轉換成 WebAssembly。 現在，我們要做的是輸出一個中間 S 格式。

		這是 cling 的 [indecipherable] LLVM 標誌，或者我們可以只使用簡寫大寫字母 S。然後我將應用我的 C 優化，我將選擇目標為 wasm32。 默認情況下，wasm 是一個 32 位系統。 這在將來可能會發生變化，然後使用 C 標誌在 nativedemo.c 處編譯文件。 最後，將其輸出到一個臨時文件 demo.s 中。

		理想情況下，這將位於臨時文件夾或類似的文件夾中。 當我們運行該編譯過程時，我們將查看是否有任何警告或錯誤。 然後我們可以看到最終的 demo.s 文件包含了這個中間的 LLVM 格式。 為了將這種 LLVM 中間格式轉換為 WebAssembly，我們使用了 binaryen 項目，它帶有一個名為 s2wasm 的工具。

		我將針對 demo.s 文件調用它。 我將傳遞一個 S 標誌來設置堆棧標誌。 我強烈建議記住這個標誌，否則代碼將運行併中斷。 我打算將堆棧大小設置為半兆字節。 它是以字節為單位的大小。 然後我們將輸出到一個 demo.wast 文件中。

		如果我想編譯我的 WebAssembly 模塊以導入它的內存，而不是在這裡默認導出它，我可以傳遞一個導入內存標誌。 現在，我將使用導出內存選項進行編譯。 如果我們查看 demo.wast，我們現在可以看到這是一個 WebAssembly 模塊。 我們有我們的函數導出，我們的內存正在設置等。

		最後一步是將這個垃圾文件轉換成我們可以在瀏覽器中運行的 WebAssembly 二進製文件。 這是我們使用 WebAssembly 二進制工具包中的第三個工具 wast2wasm 的地方。 我將針對 demo.wast 運行它，輸出一個 demo.wasm 文件。 如果我們查看 demo.wasm 文件，您可以看到它以 asm 標頭開頭，並且全是二進制格式，可以在瀏覽器中運行。

		你在這種編譯過程中遇到的第一個問題是，如果我嘗試編譯一個使用標準庫的不同演示，我們會立即發現在嘗試使用 標準庫和 [indecipherable] 來找到它。 因為 WebAssembly 太新了，我們需要自己配置標準庫。

		這就是使用像 emscripten 這樣可以為我們處理所有這些細節的包羅萬象的工具的地方。 我發現在這里工作得很好的是鏈接標準庫的 emscripten 版本。 因為下載量很大，所以從 GitHub 克隆 emscripten。 實際上，我只是拼湊了一個僅包含這些包含文件夾的存儲庫。

		如果我們克隆它，我們就可以使用它作為我們的輸入目標來獲得一些基本的標準 Lisp 支持。 當運行我們的 clang 構建命令時，我們添加了 -Include 選項，大寫 I，然後我們可以使用 LISP/c 或 LISP/cxx 或兩者加載這個包含文件夾，以獲取標準庫頭文件，然後可以修復 建造。