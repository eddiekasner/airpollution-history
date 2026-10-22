-- Pandoc Lua filter for slide images and credits.
--
-- Each image slide in the Rmd is written as:
--
--   ::::: {.slideimage}
--   ![Alt text describing the image](images/file.png){height=6.2cm}
--
--   ::: {.credit}
--   Source credit
--   :::
--   :::::
--
-- Beamer/LaTeX: centers the image and sets the credit in small type
--   (looks the same as the original slides).
-- PowerPoint: keeps the image and credit on the same slide (credit as the
--   figure caption). add-alt-text.py then writes the alt text from the Rmd
--   into the .pptx, since pandoc does not do this itself.

local function is_latex()
  return FORMAT:match("beamer") or FORMAT:match("latex")
end

local function wrap_latex(open, close, content)
  local blocks = { pandoc.RawBlock("latex", open) }
  for _, b in ipairs(content) do table.insert(blocks, b) end
  table.insert(blocks, pandoc.RawBlock("latex", close))
  return blocks
end

local function find_image(blocks)
  for _, b in ipairs(blocks) do
    if b.t == "Para" or b.t == "Plain" then
      for _, il in ipairs(b.content) do
        if il.t == "Image" then return il end
      end
    end
  end
end

local function find_credit(blocks)
  for _, b in ipairs(blocks) do
    if b.t == "Div" and b.classes:includes("credit") then return b end
  end
end

-- PowerPoint: replace simple inline math with plain Unicode symbols, which
-- render reliably in PowerPoint, LibreOffice, and screen readers.
local math_symbols = {
  ["\\rightarrow"] = "\u{2192}",
  ["\\mu"] = "\u{00B5}",
}

function Math(el)
  if is_latex() then return nil end
  local text = el.text
  for tex, sym in pairs(math_symbols) do
    text = text:gsub(tex, sym)  -- backslash is not special in Lua patterns
  end
  return pandoc.Str((text:gsub("%s+", "")))
end

function Div(el)
  if el.classes:includes("slideimage") then
    if is_latex() then
      local inner = {}
      for _, b in ipairs(el.content) do
        if b.t == "Div" and b.classes:includes("credit") then
          for _, x in ipairs(wrap_latex("{\\fontsize{5pt}{5}\\selectfont", "\\par}", b.content)) do
            table.insert(inner, x)
          end
        else
          table.insert(inner, b)
        end
      end
      return wrap_latex("\\begin{center}", "\\end{center}", inner)
    end
    local img = find_image(el.content)
    local credit = find_credit(el.content)
    if img and credit and pandoc.Figure then
      local cap = pandoc.utils.blocks_to_inlines(credit.content)
      img.caption = cap
      return pandoc.Figure(pandoc.Plain { img }, { pandoc.Plain(cap) })
    end
    return el.content
  end
end
