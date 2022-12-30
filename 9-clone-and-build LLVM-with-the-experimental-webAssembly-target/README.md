# Clone and Build LLVM with the Experimental WebAssembly Target
>本課演示了 LLVM 的完整構建，大致遵循 [GettingStarted.html](https://llvm.org/docs/GettingStartedVS.html)（或 Windows 的 [GettingStartedVS.html](https://llvm.org/docs/GettingStarted.html)）中的步驟，但使用了實驗性的 WebAssembly 目標構建選項。 先決條件包括 cmake（可從 [cmake.org/download](https://cmake.org/download/) 下載）、Windows 上的 Visual Studio 或 Mac 上的 Xcode 命令行工具。

在安裝 LLVM 之前，您只想檢查一些先決條件。 您應該檢查是否安裝了 GCC、Make 版本和 CMake 版本。

如果您沒有 GCC 或 Make，那麼建議您在 Mac 上運行安裝的 Xcode-Select，以確保您擁有 Xcode 在線工具。 在 Windows 中，您需要安裝VisualStudio。 對於 CMake，您可以從本課程文檔中的網站下載它。

我將從克隆 LLVM 開始，我將使用一個鏡像，這樣我們就可以完成這五個 git。 一旦完成，我們就可以進入這個 LLVM 文件夾。 在工具文件夾中，我們需要一個克隆 Clang。 同樣，我將使用 LLVM Mirror。 安裝 Clang 後，我將退出此工具文件夾。 我將在 LLVM 文件夾下創建一個名為 LLVM Build 的文件夾。

在這個文件夾中，我現在可以使用我們的 CMake 命令來設置構建。 這是我們要使用的命令。

在 Windows 中，此 Unix Makefile 將改為 Visual Studio。 我正在構建另一個名為 LLVM Wasm 的文件夾，該文件夾將包含最終構建輸出。 我們正在移動所有目標。 我們正在從 LLVM 文件夾中的源代碼構建 Wasm32 架構作為 WebAssembly 目標。

一旦 CMake 完成，我們就可以開始構建過程。 這大約需要一個小時左右。 我將使用 J8 標誌，以便我們並行運行 Make，然後進行 Make 安裝。

在 Windows 中，我需要 [inaudible] VisualStudio 並打開 llvm.sln 文件以從那裡開始構建。 當構建最終完成時，我們可以檢查我們的 C 編譯器是否在 LLVM Wasm 和 Clang 上可用。 為了釋放一些空間，可以刪除這個 LLVM Build 文件夾。