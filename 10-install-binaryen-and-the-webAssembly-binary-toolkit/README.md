# Install Binaryen and the WebAssembly Binary Toolkit (WABT)
在本課中，我們將介紹 Binaryen (http://github.com/WebAssembly/binaryen) 獲取 s2wasm 二進製文件和 WABT (https://github.com/WebAssembly/wabt) 獲取 wast2wasm 二進製文件的安裝過程。

先決條件是 cmake (https://cmake.org/download/)、Mac 上的 XCode CLI 工具或 Windows 上的 Visual Studio。

		為了獲得 .s 到 .asm 工具，我將從 GitHub 克隆和構建 binaryen。 在安裝了 CMake 的 binaryen 文件夾中，我們然後運行 CMake。準備就緒後，我們運行 CMake -- build。 構建當前文件夾。 對於 Windows 用戶，如果您已經安裝了 CMake 並擁有 Visual Studio 構建工具，那麼同樣的過程應該可以工作。

		為了構建 WebAssembly 二進制工具包，我將從 GitHub 克隆。 我們需要添加這個遞歸標誌，當我們做那個克隆時，以確保我們包含子模塊。 下載後，構建過程大致相同。 除了這一次，我將創建一個構建文件夾，在其中運行 CMake。

		我將添加 CMake EXECUTABLE_OUTPUT_PATH 標誌以將我們的可執行二進製文件輸出到 out 文件夾中。 我們針對較低的文件夾源運行它。 然後我們運行 CMake -- 構建。 完成構建到輸出路徑。 然後可以刪除構建文件夾。