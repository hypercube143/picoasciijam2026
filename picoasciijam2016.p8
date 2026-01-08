pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--1337 420 8)

-- p = "🐱\n웃"
-- weed_tree = "★\n★\n★"

-- CURR_SCENE
-- p

function _init()
    --CURR_SCENE = startMenu()
    p = newPlayer(50, 50)

        -- example of a full texture
    mega_tx = {
        t(s("x", 7, "head"), {0, 0}),
        t(s("x", 7, "body"), {0, 1})
    }
    thingy = co(0, 0, 0, 0, mega_tx, "thingy")
end

function _update60()
   CURR_SCENE.update()
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

function s(str, colour, id)
    return {
        str, colour,
        width = 8, hieght = 8,
        globalX, globalY,
        id
    }

-- texture
function t(sprite, pos)
    return {
        sprite, pos
    }

-- collisionObject
function co(x, y, w, h, texture, id) 
    return {
        x, y, w, h,
        texture,
        id,
        draw = function()
            for tx in all(mega_tx) do
                sprite = tx.sprite
                sprite_str = sprite.str
                sprites_col = sprite.col
                sprite_w = sprite.width
                sprite_h = sprite.height
                pos = tx.pos
                print(sprite_str, x + sprite_w * pos[0], y + sprite_h * pos[1], sprite.colour)
            end

        end,
        update = function() end
    }


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
