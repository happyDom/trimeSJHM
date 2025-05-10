--[[CharSet_Filter.lua
Copyright (C) 2023 yaoyuan.dou <douyaoyuan@126.com>

制作说明：
结合wanxiang/lua/chars_filter.lua 和 core2022.lua 调整而来

感谢：
gitHub@amzxyz
gitHub@xxx		# core2022.*.yaml/lua 作者

1、作为前轩工作，你需要准备一个字符集的查表文件 CharSet.reverse.bin

2、为了生成查表文件 CharSet.reverse.bin，你需要准备一个名为 CharSet 的伪方案

3、伪方案 CharSet 包括以下文件(放于本lua的父级目录下)
	3.1、伪方案定义文档：CharSet.schema.yaml；该文档的主要内容是调用了下面的字典文档
	3.2、字典文档：CharSet.dict.yaml；该文档主要定义了一个字符列表，用于生成一个字符集的查表文档
		注意：你可以在 CharSet.dict.yaml 文档中增删相关的字符条目，以达到调整个性化字符集的目的

4、你需要在你的方案文档中（注意是schema文档，不是custom文档）依赖这个CharSet的伪方案，如下(请注意甜酸yaml的缩进层级)：
	dependencies:
	  # 原选的依赖项
	  - CharSet		# 增加定义对 CharSet 的依赖
]]

local charsfilter = {}

-- 在 env 引擎中添加新的成员
function charsfilter.init(env)
	-- 使用 ReverseDb 方法加载字符集
	env.charset = ReverseDb("build/CharSet.reverse.bin")
	-- 一个缓存，用于缓存曾经查询过的字符内容，以空间换时间，提升查询速度
	env.memo = {}
end

function charsfilter.fini(env)
	env.charset = nil
	env.memo = nil
	collectgarbage()
end

-- 检查给定的字符是否在字符集表内
function charsfilter.CodepointInCharset(env, codepoint)
	-- 如果已经缓存过该字符的处理结果，直接返回
	if env.memo[codepoint] ~= nil then
		return env.memo[codepoint]
	end

	local char = utf8.char(codepoint)
	local res = (env.charset:lookup(char) ~= "")
	env.memo[codepoint] = res
	return res
end

-- 判断字符是否为汉字
function charsfilter.IsChineseCharacter(text)
	local codepoint = utf8.codepoint(text)
	return (codepoint >= 0x4e00 and codepoint <= 0x9fff)   -- 基本区
		or (codepoint >= 0x3400 and codepoint <= 0x4dbf)    -- 扩A
		or (codepoint >= 0x20000 and codepoint <= 0x2a6df)  -- 扩B
		or (codepoint >= 0x2a700 and codepoint <= 0x2b73f)  -- 扩C
		or (codepoint >= 0x2b740 and codepoint <= 0x2b81f)  -- 扩D
		or (codepoint >= 0x2b820 and codepoint <= 0x2ceaf)  -- 扩E
		or (codepoint >= 0x2ceb0 and codepoint <= 0x2ebef)  -- 扩F
		or (codepoint >= 0x30000 and codepoint <= 0x3134f)  -- 扩G
		or (codepoint >= 0x31350 and codepoint <= 0x323af)  -- 扩H
		or (codepoint >= 0x2ebf0 and codepoint <= 0x2ee5f)  -- 扩I
		or (codepoint >= 0x31c0 and codepoint <= 0x31ef)	-- 笔画
		or (codepoint >= 0x2e80 and codepoint <= 0x2eff)	-- 部首扩展
		or (codepoint >= 0x2f00 and codepoint <= 0x2fdf)	-- 康熙部首
		or (codepoint >= 0xf900 and codepoint <= 0xfadf)	-- 兼容
		or (codepoint >= 0x2f800 and codepoint <= 0x2fa1f)	-- 兼补
		or (codepoint >= 0x2ff0 and codepoint <= 0x2fff)	-- 汉字结构
		or (codepoint >= 0x3100 and codepoint <= 0x312f)	-- 注音
		or (codepoint >= 0x31a0 and codepoint <= 0x31bf)	-- 注音扩展
end

-- 检查给定的字符是否为单个汉字
function charsfilter.IsSingleChineseCharacter(text)
	return utf8.len(text) == 1 and charsfilter.IsChineseCharacter(text)
end

-- 检查给定的字符是否在字符集内
function charsfilter.InCharset(env, text)
	for i, codepoint in utf8.codes(text) do
		if not charsfilter.CodepointInCharset(env, codepoint) then
			return false
		end
	end

	return true
end

function charsfilter.func(t_input, env)
	-- 获取增广模式滤镜开关的状态，如果没有配置扩展滤镜，则默认是增广模式
	local extended = env.engine.context:get_option("extended_charset")

	if extended or env.charset == nil then
		-- 如果增广开关被打开，或者过滤字符集不存在，则直接抛出所有候选项
		for cand in t_input:iter() do
			yield(cand)
		end
	else
		-- 如果增广开关被关闭，并且过滤的字符集存在，对于单字汉字候选项，不在字符集内的候选项不被抛出
		for cand in t_input:iter() do
			if charsfilter.IsSingleChineseCharacter(cand.text) then
				if charsfilter.InCharset(env, cand.text) then
					yield(cand)
				end
			else
				-- 对于非单个汉字模式的字符，直接放行
				yield(cand)
			end
		end
	end
end

return charsfilter
