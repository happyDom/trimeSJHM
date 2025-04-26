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
local candsIdx = -1

local function _inputShow(input, env)
	local inputStr = tostring(env.engine.context.input)
	local inputStrLen = string.len(inputStr)
	
	candsCnt = 0
	candsIdx = -1
	for cand in input:iter() do
		candsIdx = candsIdx + 1
		
		if inputStrLen > 3 then
			-- 3码以上才不做处理
			yield(cand)
		else
			-- 3码以内，只出字
			if inputStrLen == 1 then
				-- 1码只出一简字
				if '~' ~= cand.comment:sub(1,1) then
					yield(cand)
					
					candsCnt = candsCnt + 1
					if candsCnt >= 3 then
						-- 一简字数量只有3个
						break
					end
				end
			elseif utf8String.utf8Len(cand.text) < 2 then
				yield(cand)
			end
		end
	end
end

local function inputShow(input, env)	
	_inputShow(input,env)
end

return inputShow
