# trimeSJHM

这是一个基于trime（同文输入法）的**四角号码**输入方案。通过本方案，你可以在手机的同文输入法中使用**四角号码**打字。

## 项目结构

- <font color=green>sjhm.schema.yaml</font>：这是输入方案的方案文档，里面定义了**四角号码**输入方案
- <font color=green>dyySjhm.trime.yaml</font>：这是键盘定义文档，里面定义了**四角号码**键盘和几种配置方案
- <font color=green>sjhm_base.dict.yaml</font>：这是**四角号码**的码表文档，里面收录定义了约 <font color=red>7w5</font> 个汉字及部件的**四角号码**值
- <font color=green>sjhm_dyy.dict.yaml</font>：这是本方案引用的字典文档，该文档内容如下：
  - 引用了上文的<font color=green>sjhm_base.dict.yaml</font>码表
  - 定义了二字词的组码方式（首字取前 <font color=red>**3**</font> 码，末字取前 <font color=red>**4**</font> 码，一个词语共取 <font color=red>**7**</font> 个码）
  - 定义了单个字的词频信息
  - 定义了二字词以及各词的词频信息

## 使用方法

- 安装【同文输入法】：https://github.com/osfans/trime.git
- 下载本方案
- 把本方案的 <font color=green>yaml</font> 文档放入同文输入法的用户文件夹内（<font color=gray>一般来说，应该是一个叫 <font color=green>rime</font> 的文件夹</font>）

## 如何拆字

可以阅读本项目中的文档 <font color=green>Rime sjhm 7w5 取码总则.md</font>，这里说明了关于**四角号码**的取码规则，并有大量的实例帮助理解。

## 键盘的使用

一般来说，本方案的键盘按键中，有如下使用规则：

- 短按输入按键主符号
- 上划输入按键正上方的符号
- 下划输入按键正下方的符号
- 左划输入按钮上方左侧的符号
- 右划输入按键上方右侧的符号
- 关于长按：
  - 如果是字母按键（a-z），长按输入对应的大写字母
  - 其它按键，如果按键中间写有多个字符，则长按输入右侧的字符

![Snipaste_2025-04-20_22-07-02](https://s2.loli.net/2025/04/20/6DrQgo8FWK43ysS.png)

## 键盘切换

本方案的主键盘是 2行 键盘，如下👇：  
![6d1eb7128df8049bc5cfea8724bbc62](https://s2.loli.net/2025/04/20/6jx7z4UEyk2bsXG.jpg)

您可以通过下划<font color=red>**口**</font>键（<font color=gray>对应数字 <font color=red>**6**</font></font>）键切换到9宫格键盘，如下👇：  
![6d1eb7128df8049bc5cfea8724bbc62](https://s2.loli.net/2025/04/20/6jx7z4UEyk2bsXG.jpg)

## 鸣谢

感谢QQ群友 @夜澜听雨 提供的**四角号码**码表，以及关于**四号号码**拆字的规则说明文档。
