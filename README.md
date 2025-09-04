# trimeSJHM

这是一个基于trime（同文输入法）的**四角号码**输入方案。通过本方案，你可以在手机的同文输入法中使用**四角号码**打字。

## 项目结构

- <font color=green>sjhm.schema.yaml</font>：这是输入方案的方案文档，里面定义了**四角号码**输入方案
- <font color=green>dyySjhm.trime.yaml</font>：这是键盘定义文档，里面定义了**四角号码**键盘和几种配置方案
- <font color=green>sjhm_base.dict.yaml</font>：这是**四角号码**的码表文档，里面收录定义了约 <font color=red>7w5</font> 个汉字及部件的**四角号码**值
- <font color=green>sjhm_dyy.dict.yaml</font>：这是本方案引用的字典文档，该文档内容如下：
  - 引用了上文的<font color=green>sjhm_base.dict.yaml</font>码表
  - 引用了其它指定的词典
  - 定义了单个字的词频信息
  - 定义了部分词以及各词的词频信息
  - 定义了打词的取码规则
  ![Snipaste_2025-09-04_16-38-44](https://s2.loli.net/2025/09/04/6LRBOj9woDtXsrg.png)

- 其它文档，提供了对增强功能的支持，例如lua脚本，字符集滤镜，以及反查方案支持等。

## 使用方法

- 安装【[同文输入法](https://github.com/osfans/trime.git)】
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
![Snipaste_2025-04-20_23-20-03](https://s2.loli.net/2025/04/20/XSJGZyMau1lDg7z.png)

## 麻将风皮肤一览

- 9宫格主键盘  
  ![e80dc92226a6fa4e39f8f2a4bff64c1](https://s2.loli.net/2025/05/13/V3xYe9BsKmopfgh.jpg)
- 数字键盘
  ![fdbe1d15135eac1c9e8726009e19497](https://s2.loli.net/2025/05/13/Bzwi9avu6fpY4UD.jpg)
- 标点符号键盘（其一，共有中文标点2页，英文标点1页，共3页）
  ![aaed595dfcc5135f856ccbde57cbc06](https://s2.loli.net/2025/05/13/TeaVgEbNDMSpmuz.jpg)
- 快捷符号键盘
  ![537bdd29c0dccf814dddcb830e613fa](https://s2.loli.net/2025/05/13/8pmbCzDB7JVUQsI.jpg)
- 26字母键盘（支持输入英文字母，支持拼音反查）
  ![469df4ca88701e390d0866abcfd649d](https://s2.loli.net/2025/05/13/Uyj8SixWm13o7fs.jpg)

## 关于 **四角号码** 单字重码率的统计

在一个基于 <font color=red>**26315**</font> 字的统计样本中，以定长四码为统计标准，单字重码率数据如下👇：  
![20250420232418](https://s2.loli.net/2025/04/20/isofpLRBqEAIUS8.png)  
其中重码最多的一个码，重码量为 <font color=red>**134**</font> 码。

如果以不定长码（<font color=gray>存在1码、2码、3码、4码、5码、6码的样式，其中1码、2码、3码为简码</font>）统计，单字重码率统计如下👇：  
![20250420232242](https://s2.loli.net/2025/04/20/kc5iWU28GP7BXLh.png)  
其中重码最多的一个码，重码量为 <font color=red>**91**</font> 码。

作为对比，统计所给样本字的拼音重码率，其中包含共有拼音 <font color=red>**407**</font> 种，单字重码率数据如下👇：  
![20250420232748](https://s2.loli.net/2025/04/20/QrS2Vg3wLnEblat.png)
其中重码最多的一个拼音为 <font color=red>**yi**</font>，重量为 <font color=red>**488**</font> 码。

作为对比，摘取四角号码重码最严重的前 <font color=red>**407**</font> 码，其重码率数据如下👇：  
![20250420233201](https://s2.loli.net/2025/04/20/IkQ51JPj9GWLfpx.png)  
![20250420233219](https://s2.loli.net/2025/04/20/Ca9YHs8XhF2mRIT.png)  

以上对比可以看出，**四角号码**方案在单词重码率数据方面的表现，是要优于**拼音**方案的。

## 关于 **四角号码** 二字词语重码率的统计

基于字典 <font color=green>sjhm_dyy.dict.yaml</font> 内所含 2 字词语 <font color=red>**163608**</font> 组，统计重码率情况。

基于 <font color=red>**33**</font> 取码法（<font color=gray>即在首、尾字各取其首 <font color=red>3</font> 码，共 <font color=red>6</font> 码，构成词语编码</font>）的重码率率计如下👇：  
![20250420235504](https://s2.loli.net/2025/04/20/FW1YXPoxRB7cVTe.png)  

基于 <font color=red>**34**</font> 取码法（<font color=gray>即在首字取其首 <font color=red>3</font> 码，在尾字取其首 <font color=red>4</font> 码，共 <font color=red>7</font> 码，构成词语编码</font>）的重码率率计如下👇：  
![20250420235848](https://s2.loli.net/2025/04/20/cT9QKUWJtp2GAFn.png)  

其中，具体数据列出如下👇：

取码法|总<font color=green>**码**</font>数|重码 <font color=red>10(含)</font>以内的<font color=green>**码**</font>数|重码<font color=red>10(含)</font>以内的<font color=green>**码**</font>数占比
:-|:-:|:-:|:-:
<font color=red>33</font>取码|<font color=red>68426</font>|<font color=red>66875</font>|<font color=red>97.73%</font>
<font color=red>34</font>取码|<font color=red>100359</font>|<font color=red>99859</font>|<font color=red>99.5%</font>

取码法|总<font color=green>**词**</font>数|重码 <font color=red>10(含)</font>以内的<font color=green>**词**</font>数|重码<font color=red>10(含)</font>以内的<font color=green>**词**</font>数占比
:-|:-:|:-:|:-:
<font color=red>33</font>取码|<font color=red>163608</font>|<font color=red>136655</font>|<font color=red>83.53%</font>
<font color=red>34</font>取码|<font color=red>163608</font>|<font color=red>156277</font>|<font color=red>95.52%</font>

## 特别鸣谢

感谢QQ群友 @夜澜听雨 提供的**四角号码**码表，以及关于**四号号码**拆字的规则说明文档。

## 感谢以下开发者的贡献

![img](https://contrib.rocks/image?repo=happyDom/trimeSJHM&_v=0)

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=happyDom/trimeSJHM&type=Date)](https://star-history.com/#happyDom/trimeSJHM&Date)
