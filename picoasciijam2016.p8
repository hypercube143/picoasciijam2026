pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--1337 420 8)
-- vorp
-- p = "🐱\n웃" 
-- weed_tree = "★\n★\n★"

-- CURR_SCENE
-- p

function _init()
    --CURR_SCENE = startMenu()
    p = newPlayer(50, 50)

        -- example of a full texture
    mega_tx = {
        s("x", 7, 0, 0, 0, 0, "head"),
        s("x", 7, 0, 1, 0, 0, "body"),
        s("x", 7, 1, 1, 0, 0, "body"),
    }
    thingy = co(0, 0, 0, 0, mega_tx, "thingy")
end

function _update60()
   --CURR_SCENE.update()
end

function _draw()
    cls()
    --CURR_SCENE.draw()
    --print(p .. " " .. weed_tree)
    p.draw()
    thingy.draw()
end

----- PLAYER
function newPlayer(x, y)
    return{
        -- str = " 🐱\n(웃",
        -- col = 7,
        sprite = co(x, y, 8, 8, playerTexture(), "player"),
        x = x,
        y = y,
        speed = 1,
        draw = function() print(p.str, p.x, p.y, p.col) end,
        update = function()
            movePlayer()
            
        end
    }
end

function playerTexture()
    return{
        t(s("🐱", 7, "head"), {0,0})
    }
end


function movePlayer()
    if btn(⬅️) then p.x -= p.speed end
    if btn(➡️) then p.x += p.speed end
    if btn(⬆️) then p.y -= p.speed end
    if btn(⬇️) then p.y += p.speed end
end

---- LEVELS
function startMenu()
    return{
        update = function()
            if btn(❎) then CURR_SCENE = levelOne() end
        end,
        draw = function() 
            print("press x")
        end
    }
end

function levelOne()
    -- init occurs once level is loaded, hence no funciton:
    p = newPlayer(50, 50)
    return{
        update = function()
            p.update()
        end,
        draw = function()
            p.draw()
        end
    }
end
-----

function s(str, colour, x, y, offX, offY, id)
    return {
        str = str, colour = colour,
        w = 8, h = 8,
        x = x, y = y,
        offX = offX, offY = offY,
        globalX = nil, globalY = nil,
        id = id,
    }
end


-- texture
-- function t(sprite, pos)
--     return {
--         sprite = sprite, pos = pos
--     }
-- end


-- collisionObject
function co(x, y, w, h, texture, id) 
    return {
        x = x, y = y, w = w, h = h,
        texture = texture,
        id = id,
        draw = function()
            for sprite in all(texture) do
                print(sprite.str, x + sprite.w * sprite.x + sprite.offX, y + sprite.h * sprite.y + sprite.offY, sprite.colour)
            end
        end,
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
