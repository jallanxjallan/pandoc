-- extract_content.lua (with metadata-controlled image/list inclusion)

local keep_images = false
local keep_lists = false

local function read_markdown_file(filepath)
	local file = io.open(filepath, "r")
	if not file then
		io.stderr:write("Warning: Missing file - " .. filepath .. "\n")
		return { pandoc.Para { pandoc.Str("Missing File: " .. filepath) } }
	end

	local content = file:read("*all")
	file:close()

	local doc = pandoc.read(content, "markdown")
	return doc.blocks
end

function Meta(meta)
	-- Set global flags from metadata (default to false)
	if meta.keep_images and meta.keep_images == true then
		keep_images = true
	end
	if meta.keep_lists and meta.keep_lists == true then
		keep_lists = true
	end
	return meta
end

function Para(para)
	local has_link = false
	for _, elem in ipairs(para.content) do
		if elem.t == "Link" and elem.target:match("%.md$") then
			has_link = true
			break
		end
	end

	if has_link then
		local output = {}
		for _, elem in ipairs(para.content) do
			if elem.t == "Link" and elem.target:match("%.md$") then
				local blocks = read_markdown_file(elem.target)
				for _, blk in ipairs(blocks) do
					table.insert(output, blk)
				end
			end
		end
		return output
	else
		return para
	end
end

function Image(img)
	if keep_images then
		return img
	else
		return {}
	end
end

function BulletList(list)
	if keep_lists then
		return list
	else
		return {}
	end
end

function OrderedList(list)
	if keep_lists then
		return list
	else
		return {}
	end
end

function DefinitionList(list)
	if keep_lists then
		return list
	else
		return {}
	end
end

function BlockQuote(blockquote)
	local prefix = pandoc.Para({pandoc.Strong(pandoc.Str("note:"))})
	local new_blocks = { prefix }
	for _, blk in ipairs(blockquote.content) do
		table.insert(new_blocks, blk)
	end
	return new_blocks
end
