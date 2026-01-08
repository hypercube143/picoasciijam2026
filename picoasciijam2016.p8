pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--1337 420 8)

-- p = "🐱\n웃"
-- weed_tree = "★\n★\n★"

function _init()
    p = newPlayer(50, 50)
end

function _update60()
    p.update()
end

function _draw()
    cls()
    --print(p .. " " .. weed_tree)
    p.draw()
end
-----

function newPlayer(x, y)
    return{
        str = "🐱\n웃",
        col = 7,
        x = x,
        y = y,
        draw = function() print(p.str, p.x, p.y, p.col) end,
        update = function() end
    }
end



--[[
Buttons
\code - symbol - name

\131 - ⬇️ - Down Key
\139 - ⬅️ - Left Key
\145 - ➡️ - Right Key
\148 - ⬆️ - Up Key
\142 - 🅾️ - O Key
\151 - ❎ - X Key
Symbols
\code - symbol - name

\16 - ▮ - Vertical rectangle
\17 - ▬ - Horizontal rectangle
\18 - Horizontal half filled rectangle?
\22 - ◀ - Back
\23 - ▶ - Forward
\24 -「 - Japanese starting quote
\25 - 」- Japanese ending quote
\28 - 、- Japanese comma
\29 - ▪ - Small square (bigger than a pixel)
\31 - ⁘ - Four dots
\128 - ■ - Square
\129 - ▒ - Checkerboard
\132 - ░ - Dot pattern
\134 - ● - Ball
\143 - ◆ - Diamond
\144 - .... - Ellipsis
\152 - ▤ - Horizontal lines
\153 - ▥ - Vertical lines
Emojis
\code - symbol - name

\130 - 🐱 - Cat
\133 - ✽ - Throwing star
\135 - ♥ - Heart
\136 - ☉ - Eye (kinda)
\137 - 웃 - Man
\138 - ⌂ - House
\140 - 😐 - Face
\141 - ♪ - Musical note
\146 -  - Star
\147 - ⧗ - Hourglass
\149 - ˇˇ - Birds
\150 - ∧∧ - Sawtooth
--]]

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
