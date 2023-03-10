# Optimize Collision Detection in JS with a Grid
>為了提高碰撞檢測的性能，我們需要深入研究算法的內部結構。 這裡我們更新了 JS 碰撞檢測代碼，使用網格進行碰撞檢測，最終帶來了很大的性能提升。

為了優化我們在 JavaScript 中的碰撞算法，我們的主循環是這個時間步函數。 我們在每個時間步上所做的是遍歷整個頁面中的每個圓圈。 那是 2,000。

我們正在更新它的動態，然後我們正在對所有其他圓圈應用碰撞檢測。 我們每幀都進行四百萬次碰撞檢測，這正是我們的性能問題。

我們可以通過用網格打破空間來改進這種碰撞算法。 然後我們只需要計算與網格的單個單元格的碰撞檢測。 我們最初將為網格使用任意寬度和高度。 我們可以稍後對此進行優化。

在我們的時間步長函數中，我們然後在每個時間步長上創建網格。 我們遍歷列和行，每行都由一個數組表示。 然後，各個單元格是包含在該網格單元格中的一組圓圈。 對於這個初始化步驟，我們只是將它設置為每個單元格的空數組。

我們的時間步函數的第一部分是計算每個圓的動態。 我們將保留此計算，但不是直接進入碰撞檢測，而是首先將每個圓分配到其中一個網格單元中。

我們根據當前圓圈在頁面上的展示來計算當前圓圈的列，作為按比例放大到網格大小的總寬度的一部分。 我們需要向下舍入，因為網格從零開始，所以我們可以使用 Math.floor 來做到這一點。

如果我們看右邊一些最大的圓圈，它們實際上包含在多個網格單元中。 我們不需要計算每個圓的單個單元格，而是計算它的單元格範圍。

我們將根據從中心點減去半徑來計算其最左邊的列，併計算其最右邊的列，並對其最上面的行和最下面的行執行相同的操作。

現在我們確切地知道給定的圓屬於哪些單元格，我們需要將它分配到網格中。 我們可以從第一列循環到圓圈所在的最後一列，然後我們直接從網格中獲取這些列。 然後我們從圓圈所在的第一行到圓圈所在的最後一行循環查找行，我們從網格中獲取單元格值。

我們已經預先將每個單元格分配給一個空的圓圈數組，因此我們可以使用數組推送將圓圈添加到該單元格。 要引用圓，我們可以使用圓的索引和圓數據數組作為我們的唯一標識符。

如果圓圈恰好在瀏覽器邊界之外——假設我們正在重新調整瀏覽器窗口的大小——我們將分配給一個無效的網格，或者一個負的網格值。 讓我們只檢測前列是否為負數，並將其設置為零，類似地，如果兩列大於網格寬度，則將其恢復為網格大小。

如果兩個圓圈在瀏覽器窗口外發生碰撞，我們實際上會忽略這些碰撞檢測。 有了網格，我們不再需要在每個圓圈之間進行碰撞檢測，所以我將結束我們當前所在的每個圓圈的循環。
現在，我們只需遍歷網格中的每個單獨單元格，並對該單元格內的圓應用碰撞檢測。 單元格值本身是包含在單元格中的圓形索引數組。 你也想遍歷這個數組。

我們之前每個圓圈的迭代值是迭代的“I”和“IV”。 “我”三步走，“四”一步步走兩步。 要從此處的信息中獲取“IV”迭代值，我只是將“I”除以三，然後乘以二。

與前面的代碼一樣，我們現在可以從圓數據中讀出 X1 和圓的值，並使用這些索引讀出最後一個“T”的外部“I”分量。 為單元格中的一個圓圈設置變量後，您想要與單元格中的另一個圓圈進行比較。

我們將需要一個最終的內部循環，我們可以在其中獲得我們正在比較的這個圓圈的索引。 這個循環只需要從當前圈之後的圈開始，所以我們每對比較只做一次。

我們就快到了。 通過為比較圓設置這些“J”和“JV”索引，位置和速度查找實際上已經在我們原始的碰撞檢測代碼中。

我將繼續，並將其複制進去。這現在將我們的整個碰撞檢測算法嵌套在這些特定的網格單元比較中。

這就是碰撞算法網格優化。 我可以向你保證，我第一次沒有做對，這個過程中有很多小時的閱讀、重寫和調試。