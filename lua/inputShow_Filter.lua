-- inputShow_Filter.lua
-- Copyright (C) 2023 yaoyuan.dou <douyaoyuan@126.com>

--引入 utf8String 处理字符串相关操作
local utf8StringEnable, utf8String = pcall(require, 'utf8String')

local logEnable, log = pcall(require, "runLog")
if logEnable then
	log.writeLog('')
	log.writeLog('log from inputShow_Filter.lua')
	log.writeLog('utf8StringEnable:'..tostring(utf8StringEnable))
end

local candsCnt = 0
local cands = {}
local allCands = {}

local function _inputShow(input, env)
	local inputStr = tostring(env.engine.context.input)
	local inputStrLen = string.len(inputStr)
	
	candsCnt = 0
	cands = {}
	allCands = {}
	for cand in input:iter() do
		table.insert(allCands, cand)
		if inputStrLen > 3 or '/' == inputStr:sub(1,1) then
			-- 3码以上，或者以 / 引导的输入，不做处理
			yield(cand)
		elseif utf8String.utf8Len(cand.text) < 2 then
			-- 3码以内，只出字
			if inputStrLen < 3 then
				-- 3码以下，只出一简字，或二简字
				if '~' == cand.comment:sub(1,1) then
					break
				else
					table.insert(cands, cand)
					candsCnt = candsCnt + 1
				end
			else
				yield(cand)
				candsCnt = candsCnt + 1
			end
		end
	end
	
	-- 一简字，二简字排序，以便保持固定的次序
	if 0 < #cands then
		table.sort(cands, function(a,b)
			return (b.text > a.text)
		end)
		for idx = 1, #cands do
			yield(cands[idx])
		end
	end
	
	if inputStrLen <= 3 and candsCnt < 1 then
		-- 如果3码及以下，但没有候选项出来，则抛出所有候选项
		for idx = 1, #allCands do
			yield(allCands[idx])
		end
	end
end

local function inputShow(input, env)
	_inputShow(input,env)
end

return inputShow
