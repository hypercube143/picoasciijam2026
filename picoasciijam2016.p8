pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--1337 420 8)
-- vorp

------------------------------------------------------------------------------------------------------------------------------------------------------
-- NOTES
------------------------------------------------------------------------------------------------------------------------------------------------------
--[[
screen is 128 px hence 16 by 16 no, 5,6, 20 25
glyph is 6x5





--]]
------------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBALS
------------------------------------------------------------------------------------------------------------------------------------------------------
-- DEBUG THINGS
debug = "debug: "
debugCollisions = true
debugWorldYLevels = true

-- GAME THINGS
t = 0
--entities = {} -- eg collidable
map_tiles = {} -- eg collidable
------------------------------------------------------------------------------------------------------------------------------------------------------
-- MAIN GAME FUNCTIONS
------------------------------------------------------------------------------------------------------------------------------------------------------
function _init()
    t = 0
    CURR_SCENE = startMenu()
end

function _update60()
   CURR_SCENE.update()
   print(debug, 2, 2, 7)
end

function _draw()
    cls()
    debug = "debug: "
    CURR_SCENE.draw()
    print(debug, 2, 2, 7)

end

------------------------------------------------------------------------------------------------------------------------------------------------------
-- LEVELS
------------------------------------------------------------------------------------------------------------------------------------------------------
function startMenu()
    return{
        update = function()
            if btn(❎) then 
                initLevelOne()
                CURR_SCENE = levelOne() 
            end
        end,
        draw = function() 
            print("press x")
        end
    }
end

function initLevelOne()
    p = newPlayer(60, 80)
    bar = newBar()
    t = 0
    entities = initEntities()
    thoughts = initThoughts()

    for i = 1, 5, 1 do
        map_tiles[i] = platformCo(0, -16 - (8 * (i-1)), 16, 11) -- base platform player starts on (could this be a unique co later on? perhaps a nice grassy hill area?)
    end
        -- generate initial platforms
    for i = 1, 5, 1 do
        x, w = unpack(calcPlatformXPosAndWBasedOnLastPlatform())
        worldY = (i * platformYSpacing) - (8 * 3) 
        platform = platformCo(x, worldY, w, 420)
        platform.worldY = worldY
        map_tiles[#map_tiles + 1] = platform
    end

    -- spawn initial weed
    wed = weed(76, -8)
    wed.worldY = -8
    entities[#entities + 1] = wed
end

function levelOne()   
    return{
        update = function()
            p.update()
            t += 1
            
            updateThoughts()
            attemptPlatformCreation(t)
            attemptToSpawnWeed()
            -- delete any platforms & entities (weed) which move far below screen
            despawnOutOfRangeCollidables(map_tiles, 200)
            despawnOutOfRangeCollidables(entities, 200)
           
            -- checkPlayerCollision(map_tiles)
            -- checkPlayerCollision(entities)

        end,
        draw = function()
            drawGrid("❎", "♥")
            
            

            p.draw()
            -- DEBUGGING REMOVE LATER
            if debugWorldYLevels then
               print(p.worldY, p.x, p.y, 11)
            end
            --weed_tree.draw(90, 90)
            bar.draw()
            -- DEBUGGING UNCOMMENT LATER
            -- toCorrupt()
            ---
            --debug = debug .."tick: " .. t

            
            -- draw corruption every frame, update every 10th
            -- if t % 10 == 0 then
            --     updateCorruption(t * 0.0025)
            -- end
            -- drawCorruption()

            -- draw all map tile collidables
            drawPlatforms()
            drawEntities()
            drawThoughts()

            debug = debug .. tostr(#entities)           
            
            --lastWeed = entities[#entities]
            if lastWeed then
                --debug = debug .. tostr(lastWeed.worldY)
                debug = debug .. tostr(#entities)
            end 
        end
    }
end

function animationScene(anim)
    t = 0
    return {
        --t = 0,
        draw = function()
            anim.draw()
        end,
        update = function()
            t += 1
            -- start filling animation on first tick
            anim.update(t)
            -- DEBUGGING UNCOMMENT LATER
            if anim.finished() then
                CURR_SCENE = levelOne()
            end
            --DEBUGGING REMOVE LATER
            -- if t == (60 * 5) then
            --     CURR_SCENE = levelOne()
            -- end
        end
    }
end

rainbowN = 1
-- fps doesn't get calculated correctly, too lazy to fix. the higher it is, the faster the animation runs
function animation(fps, fillSpeed, frames)
    fillLevel = 0
    currentFrameIdx = 0 
    rainbowMode = false
    rainbowSpeedMod = 1
    -- fillSpeed = 0 -- layers per second
    return {
        update = function(t) 
            fillLevel = flr(t / (60 / fillSpeed))
            if fillLevel > #frames[1] then
                rainbowMode = true
            end
            rainbowFillLevel = flr((t - (#frames[1] * (60 / fillSpeed))) / (60 / (fillSpeed * rainbowSpeedMod)))
            currentFrameIdx = (flr(t / fps) % #frames) + 1 
        end,
        draw = function()
            yMod = 0
            spacing = 8
            currentFrame = frames[currentFrameIdx]
            layerN = 1
            for layer in all(currentFrame) do
                layerStr = layer.str
                -- layerStr = currentFrameIdx
                if not rainbowMode then
                    if #currentFrame - layerN < fillLevel then
                        layerCol = 11 -- fill up with green (potentially allow for this col to change, rainbow even?)
                    else
                        layerCol = layer.colour
                    end
                else
                    if layerN <= rainbowFillLevel then
                        if rainbowN > #platformColours then 
                            rainbowN = 1
                        end
                        layerCol = platformColours[rainbowN]
                    end
                end
                print(layerStr, 0, yMod, layerCol)
                if true then
                    rainbowN += 1
                end
                yMod += spacing
                layerN += 1
            end
        end,
        fill = function(speed)
            fillSpeed = speed
        end,
        finished = function()
            if rainbowFillLevel == #frames[1] then
                return true
            end
            return false
        end
    }
end


-- animation layer
function al(str, col)
    return {
        str = str,
        colour = col
    }
end



function drawPlatforms()
    for collidable in all(map_tiles) do
        worldY = getCoYFromPlayerWorldY(collidable)
        
        collidable.draw(collidable.x, worldY)
        if debugWorldYLevels then
            -- collidable.texture[#collidable.texture] = s(collidable.worldY, 11, 0, 0, 0, 0, "end") -- DEBUGGING REMOVE LATER
            print(collidable.worldY, collidable.x, worldY, 11)
        end
    end
end
------------------------------------------------------------------------------------------------------------------------------------------------------
-- PLAYER FUNCTIONS
------------------------------------------------------------------------------------------------------------------------------------------------------
defaultPlayerGravity = 1.5
function newPlayer(x, y)
    local texture = {
            s("🐱", 7, 0, 0, 0, 4, "head"),
            s("웃", 7, 0, 1, 0, 0, "body"),
            s("L", 6, 0, 1, -1, -1, "tail")
        }
    return{
        spr = co(x, y, 8, 8, texture, "player"),
        x = x,
        y = y,
        worldY = 0, -- in pixels
        speed = 1,
        gravity = defaultPlayerGravity,
        yVel = 0,
        decel = 0.1,
        jumpStr = 4.20, -- B) smok weed every day
        draw = function() 
            p.spr.draw(p.x, p.y)
        end,
        update = function()
            checkPlayerCollision(entities)
            tileColliders = checkPlayerCollision(map_tiles) -- potentially have these return values to inform below gravity logic
            movePlayer(tileColliders)
            -- check if player colliding - potentially make this a list and for loop later? DONE IN LEVEL_ONE
            -- p.spr.collisionCheck(weed_tree)
        end
    }
end

upBtnJustPressed = false
function movePlayer(colliders)

    -- check whether player touching platform
    touchingPlatform = false
    platform = nil 
    for collider in all(colliders) do
        if collider.id == "platform" then
            touchingPlatform = true
            platform = collider
        end
    end

    -- if touchingPlatform then
    --     p.gravity = 0
    -- else
    --     p.gravity = defaultPlayerGravity
    -- end

    if btn(⬅️) then 
        p.x -= p.speed 

        if p.x < -2 then p.x = 125 end
    end
    if btn(➡️) then 
        p.x += p.speed
        -- p.worldY += p.speed

        if p.x > 124 then p.x = -5 end
    end
    if btn(⬆️) then
        -- can only tap, not hold to jump
        if not upBtnJustPressed and touchingPlatform then
            upBtnJustPressed = true
            -- p.y -= p.speed
            -- DEBUGGING REMOVE LATER
            -- p.worldY += p.speed
            p.yVel = p.jumpStr
            -- player gravity
        end
    else
        -- upBtn released
        upBtnJustPressed = false
    end
    if btn(⬇️) then 
        -- p.y += p.speed 
        --p.worldY -= p.speed
    end
    -- apply gravity etc
    
    p.worldY += p.yVel
    p.yVel -= p.decel
    if p.yVel < 0 then p.yVel = 0 end
    -- apply gravity if not touching platform
    if not touchingPlatform then
        p.worldY -= p.gravity
    -- propel player upwards if they aren't quite on the top of platform
    -- else
    --     if (p.worldY - 16) < platform.worldY then
    --         p.worldY += 0.1
    --     end
    else
        -- player hits their head
        if (p.worldY + 1) < platform.worldY then
            p.yVel = 0
            p.worldY -= p.gravity
        end
    end
end

lastWeedCollectedWorldY = -1
function checkPlayerCollision(collidables)
-- check every collidable collisions against the player's from a list of collidables
    collidedWith = {}
    for collidable in all(collidables) do
        -- debug = entities[#entities] -- tostr(p.spr.collisionCheck(collidable))
        if p.spr.collisionCheck(collidable) then
            collidedWith[#collidedWith + 1] = collidable
            -- if debug collisions, sprites turn yellow and pink when collision happens
            if debugCollisions then
                p.spr.colour = 10
                collidable.colour = 14
                sfx(0)
            end
            --
            if collidable.id == "weed" and lastWeedCollectedWorldY != collidable.worldY then
                -- del(entities, collidable)
                if btn(❎) then
                    lastWeedCollectedWorldY = collidable.worldY
                    collidable.y = -420
                    -- collidable.colour = 0
                    -- idx = 1
                    -- for c in all(collidables) do
                    --     if c == collidable then break end
                    --     idx += 1
                    -- end
                    -- entities[idx].y = -420
                    bar.increaseHighness()
                    -- lerping will go here, or at least a call to the lerp function, right sap?
                    -- after lerp, change to a random animation scene
                    frames = {
                        {
                            al("layer 1 frame 1", 7),
                            al("layer 2", 7),
                            al("layer 3", 7),
                            al("layer 4", 7),
                            al("layer 5", 7),
                            al("layer 6", 7),
                            al("layer 7", 7),
                            al("layer 8", 7),
                            al("layer 9", 7),
                            al("layer 10", 7),
                            al("layer 11", 7),
                            al("layer 12", 7),
                            al("layer 13", 7),
                            al("layer 14", 7),
                            al("layer 15", 7),
                            al("layer 16", 7),
                        },
                        {
                            al("layer 1 frame 2", 7),
                            al("layer 2", 7),
                            al("layer 3", 7),
                            al("layer 4", 7),
                            al("layer 5", 7),
                            al("layer 6", 7),
                            al("layer 7", 7),
                            al("layer 8", 7),
                            al("layer 9", 7),
                            al("layer 10", 7),
                            al("layer 11", 7),
                            al("layer 12", 7),
                            al("layer 13", 7),
                            al("layer 14", 7),
                            al("layer 15", 7),
                            al("layer 16", 7),
                        },

                    }
                    anim = animation(20, 16, frames)
                    CURR_SCENE = animationScene(anim)
                end
            end
            --
            if collidable.id == "platform" then -- platform should be turning white when player hits it but this not the case for some reason gahhh
                for sprite in all(collidable) do
                    sprite.colour = 7
                end
            end
        end
    end
    return collidedWith
end


------------------------------------------------------------------------------------------------------------------------------------------------------
-- MAP THINGS
------------------------------------------------------------------------------------------------------------------------------------------------------
platformSpawnHeight = (11 * 8)
platformYSpacing = (4 * 8)
function attemptPlatformCreation(tick)
    -- -- generate platform every 100 ticks
    -- if (tick + 99) % 100 == 0 then
    -- generate two blocks apart based on height
    -- if (ceil(p.worldY) % platformYSpacing == 0) then
    if true then --(tick + 99) % 100 == 0 then

        -- only generate platform if there are none on this world y level
        n = 0
        for plat in all(map_tiles) do
            checkHeight = (p.worldY + platformSpawnHeight)
            if plat.worldY > (checkHeight - platformYSpacing) and plat.worldY < (checkHeight + platformYSpacing) then
                n += 1
            end
        end

        if n == 0 then
            x, w = unpack(calcPlatformXPosAndWBasedOnLastPlatform())
            -- set world y to be above the player's, just out of screen
            worldY = p.worldY + platformSpawnHeight -- px above
            -- maybe later include the chance for a weed object to spawn just above the platform based on worldY HERE
            newPlatform = platformCo(x, worldY, w, 420)
            newPlatform.worldY = worldY -- you have to set world y after instantiating
            map_tiles[#map_tiles + 1] = newPlatform
        end
    end
end

function attemptToSpawnWeed()
    lastPlatform = map_tiles[#map_tiles]

    if platformTotalCount % 7 != 0 then return end -- place above every nth platform

   --  nOfPlatformsSeperated = 5

    if lastPlatform == nil then return end

    weedMod = 8 * 2
    weedHeight = lastPlatform.worldY + weedMod

    -- can only place weed if there isn't weed already on the last placed platform
    canPlaceWeed = true
    for entity in all(entities) do
        if entity.id == "weed" then
            if entity.worldY == weedHeight then
               canPlaceWeed = false 
            end
            -- topOfScreenWorldY = p.worldY + (10 * 3)
            -- if entity.worldY > topOfScreenWorldY - ((nOfPlatformsSeperated + 2) * 8) then
            --     canPlaceWeed = false
            -- end
        end
    end

    if canPlaceWeed then
        -- -- stupid lil solution to have weed only spawn between every 7 platforms
        -- if #map_tiles % 2 == 0 then -- ENTITES MUST ONLY CONTAIN WEEED FROM NOW ON, OTHERWISE THIS WILL BREAK -- OKE
        --     x = (flr(rnd(14)) + 1) * 8
        -- else
        --     x = -420
        -- end
        x = (flr(rnd(14)) + 1) * 8
        wed = weed(x, weedHeight)
        wed.worldY = weedHeight
        entities[#entities + 1] = wed
    end
end

function calcPlatformXPosAndWBasedOnLastPlatform()
    -- A PLATFORM MUST FOLLOW THESE RULES:
    -- generate width between 3 - 5,
    -- position so there's at least 1 block padding to the left or right
    -- must not be covering the previous platform; must be far enough to the left or right and be smaller if close
    -- NO LONGER INCLUDED (player can wrap around screen, these jumps aren't impossible anymore): mustn't generate further than 6 blocks from the previous platform. above 6 blocks is too hard / impossible to jump between

    prevPlatform = map_tiles[#map_tiles] 

    -- two platforms on either layers can never spawn right next to each other
    x = prevPlatform.x
    while prevPlatform.x == x do -- and abs((prevPlatform.x - x)/8.0) < 6 do
        -- always 3 long
        w = 3 -- flr(rnd(3)) + 3 
        x = flr(rnd(15 - w) + 1) * 8 
    end
    return {x, w}
end

function getCoYFromPlayerWorldY(collidable)
    return p.worldY - collidable.y + p.y --(p.worldY - collidable.worldY)
end

-- despawn all collidables in collidable table if they're a certain number of pixels below player
function despawnOutOfRangeCollidables(tabl, threshold)
    n = 1
    for plat in all(tabl) do
        if (p.worldY - threshold) > plat.worldY then -- (plat.worldY - threshold) then
            deli(tabl, n)
        end
        n += 1
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------
-- ENTITY THINGS
------------------------------------------------------------------------------------------------------------------------------------------------------
function initEntities()
    return {} -- {weed(60, 60), weedTree(20, 80)}
end

function drawEntities()
    for e in all(entities) do
        worldY = getCoYFromPlayerWorldY(e)
        e.draw(e.x, worldY)
    end
end

-- COLLISION OBJECTS
function weedTree(x, y)
   return co(x, y, 0, 0,
        {
            s("★", 11, 1, 1, 1, -2, "weed"),
            s("★", 11, 0, 1, 3, 3, "weed"),
            s("★", 11, 1, 1, 1, 3, "weed"),
            s("★", 11, 2, 1, -1, 3, "weed"),
            s("★", 11, 1, 2, 1, 2, "weed"),
        },
    "weed_tree"
    )
end

function weed(x, y)
    --str, colour, x, y, offX, offY, id
    w = {s("★", 11, 0, 0, 0, 0, "weed")}
    --x, y, w, h, texture, id
    return co(x, y, -1, -1, w, "weed")
end


-- global thought cloud vars
MIN_DIST_FROM_PLAYER = 20

function initThoughts()
    local y = MIN_DIST_FROM_PLAYER + 5 
    return {
        thought(30, y, 7, "get a j*b"),
        thought(30, y, 7, "literal idiot >:("),
        thought(30, y, 7, "you were an accident"),
        thought(30, y, 7, "you've wasted your life"),
        --thought(30, y, "failure"),
    }
end

function thought(x, y, col, text)
    return{
    shiftX = 0,
    shiftY = 0,
    text = text,
    co = co(
        x,
        p.y + y, -- y under and relative to player
        -1, -1,
        {s(text, col, 0, 0, 0, 0, "thought")},
        "thought"
        )
    }
end

function updateThoughts()
    for thot in all(thoughts) do
        if t%50 == 0 then
            if thot.co.x -1 <= -5 then 
                thot.shiftX = flr(rnd(2)) -- 0 to 1
            elseif thot.co.x + 1 >= 128 - (#thot.text)*4 then
                thot.shiftX = -1 + flr(rnd(2)) -- -1 to ()
            else
                thot.shiftX = -1 + flr(rnd(3))
            end

            if thot.co.y -1 <= (p.y + MIN_DIST_FROM_PLAYER) then 
                thot.shiftY = flr(rnd(2))
            elseif thot.co.y +1 >= 120 then
                thot.shiftY = -1 + flr(rnd(2))
            else
                thot.shiftY = -1 + flr(rnd(3))
            end
        
        end

        thot.co.x = lerp(thot.co.x, thot.co.x + thot.shiftX, .2)
        thot.co.y = lerp(thot.co.y, thot.co.y + thot.shiftY, .2)
    end
end

function drawThoughts()
    line(0, p.y + MIN_DIST_FROM_PLAYER, 128, p.y + MIN_DIST_FROM_PLAYER, 7)
    for t in all(thoughts) do
        t.co.draw(t.co.x, t.co.y)
    end
end


------------------------------------------------------------------------------------------------------------------------------------------------------
-- GAME THINGS
------------------------------------------------------------------------------------------------------------------------------------------------------
function newBar()
    return{
        x = 120,
        y = 0,
        level = 2,
        max_level = 10,
        update = function() end,
        draw = function() 
            -- grey background
            pad = 10
            for i = 0, 9 do
                -- should be grey as default
                if bar.max_level-i > bar.level then
                    drawGlyphWithBorder("★", 6, "★", 5, bar.x, 2 + bar.y + i*pad)
                else
                -- and green up to bar level
                    drawGlyphWithBorder("★", 3, "★", 11, bar.x, 2 + bar.y + i*pad)
                end
            end
        end,

        increaseHighness = function()
            if bar.level < bar.max_level then
                bar.level += 1
            end
        end

    }
end

-- draw corruption every frame, update every 10th
-- should only happen on threshold reached
function toCorrupt()
    -- 5 weeds to bar and flash
    if bar.level <= 2 then 
        if t % 10 == 0 then
            updateCorruption(t * 0.0025)
         end
        drawCorruption()
    end
end

corrWidth = 21
corrHeight = 26
corrGlyphArray = {}
-- overlay that obscures player's vision
-- level from 0-1
function updateCorruption(level)

    if level > 1.0 then
        level = 1.0
    end
    
    corrGlyphArray = {}
    totalGlyphs = corrWidth * corrHeight
    glyphCount = flr(((totalGlyphs) * level) + 0.5)
    chars = "▒░●◆▤▥🐱✽♥☉웃⌂😐♪★⧗"
    --chars = "😐🐱"

    corrGlyphArray = {}

    -- add glyphs
    for i = 1, glyphCount do
        corrGlyphArray[#corrGlyphArray + 1] = chars[flr(rnd(#chars)) + 1]
    end

    -- add empty
    for i = 1, totalGlyphs - glyphCount do
        corrGlyphArray[#corrGlyphArray + 1] = ""
    end

    -- shuffle
    for i = #corrGlyphArray, 2, -1 do
        j = flr(rnd(i)) + 1
        corrGlyphArray[i], corrGlyphArray[j] = corrGlyphArray[j], corrGlyphArray[i]
    end
end

function drawCorruption()
    xMod = 0
    yMod = 0
    spacer = 6
    spacerY = 5
    n = 1
    -- draw grid of glyphs
    for i = 1, corrHeight, 1 do
        for j = 1, corrWidth, 1 do
            char = corrGlyphArray[n]
            -- print only if non empty glyph
            if char != "" then
                print(char, xMod, yMod, 7)
            end
            n += 1
            xMod += spacer
        end
        xMod = 0
        yMod += spacerY
    end
end


------------------------------------------------------------------------------------------------------------------------------------------------------
-- COLLISION OBJECT THINGS
------------------------------------------------------------------------------------------------------------------------------------------------------
function s(str, colour, x, y, offX, offY, id)
    local width = 8
    if id == "thought" then width = 4*#str end -- so that the hit box is the length of the string
    return {
        str = str, colour = colour,
        originalColour = colour, -- helpful for knowing which colour the platforms should go back to after flashing white when landed on
        --w = 8, h = 8,
        w = width, h = 8,
        x = x, y = y,
        offX = offX, offY = offY,
        globalX = x, globalY = y,
        id = id,
    }
end

-- collisionObject
function co(x, y, w, h, texture, id) 
    return {
        x = x, y = y, w = w, h = h,
        worldY = -1,
        texture = texture,
        id = id,
        -- draw texture to screen based on x, y pos
        draw = function(x, y)
            x = x
            y = y
            for sprite in all(texture) do
                sprite_x = x + sprite.w * sprite.x
                sprite_y = y + sprite.h * sprite.y
                sprite.globalX = sprite_x
                sprite.globalY = sprite_y
                -- display red box around collisions if debugging mode active
                if debugCollisions then
                    rect(sprite_x, sprite_y, sprite_x + sprite.w, sprite_y + sprite.h, 8)
                end
                -- +2 is just to center sprite texture with collision box
                print(sprite.str, sprite_x + sprite.offX, sprite_y + sprite.offY, sprite.colour)
            end
            -- if debugWorldYLevels then
            --     print(worldY, x, y, 11)
            -- end

        end,
        -- update collisions
        collisionCheck = function(other)
            collides = false
            for sprite in all(texture) do 
                for otherSprite in all(other.texture) do

                    l1 = sprite.globalX
                    t1 = sprite.globalY
                    r1 = sprite.globalX + sprite.w
                    b1 = sprite.globalY + sprite.h

                    l2 = otherSprite.globalX
                    t2 = otherSprite.globalY
                    r2 = otherSprite.globalX + otherSprite.w
                    b2 = otherSprite.globalY + otherSprite.h

                    collides = (l1<r2 and r1>l2) and (t1<b2 and b1>t2)
                    
                    if collides then
                        -- if debugCollisions then
                        --     sprite.colour = 10
                        --     otherSprite.colour = 14
                        -- end
                        return true
                    end
                end
            end
            return false
        end,
        update = function() end
    }
end

platformTotalCount = 0
platformColourN = 4 -- start at blue
platformColours = {8, 9, 10, 11, 12, 13}
function platformCo(x, y, w, colour)
    platformTotalCount += 1
    if colour == 420 then
        -- cycle thru rainbow colours bc why not :pp
        platformColourN += 1
        if platformColourN > #platformColours then 
            platformColourN = 1
        end
        colour = platformColours[platformColourN]
    end
    if colour == 421 then
        -- copy prev tile colour
        colour = map_tiles[#map_tiles]
    end
    -- add left platform edge
    texture = {s("▒", colour, 0, 0, 1, 2, "platform_edge_left")}
    -- length of a platform must be at least 1
    if w == 1 then
        return co(x, y, 0, 0, texture, "platform")
    end
    -- add middle section
    for i = 1, w - 2, 1 do
        texture[#texture + 1] = s("▤", colour, i, 0, 1, 2, "platform_middle")
    end
    -- add right platform edge
    texture[#texture + 1] = s("▒", colour, w - 1, 0, 1, 2, "platform_edge_right")
    return co(x, y, 0, 0, texture, "platform")
end


------------------------------------------------------------------------------------------------------------------------------------------------------
-- UTIL
------------------------------------------------------------------------------------------------------------------------------------------------------
function lerp(p1, p2, amt)
    return p1 + (p2-p1) * amt
end

-- FOR STRINGS
function drawGlyphWithBorder(border, col1, inner, col2, x, y)
    for xOff = -1, 1 do
        for yOff = -1, 1 do
            print(border, x + xOff, y + yOff, col1)
        end
    end
    print(inner, x, y, col2)
end

-- FOR COs
function drawBorder(borderShape, innerShape)
    local b = borderShape
    local i = innerShape
    for xOff = -1, 1 do
        for yOff = -1, 1 do
            b.draw(b.x + xOff, b.y + yOff)
        end
    end
    i.draw(i.x, i.y)
end

function drawGrid(border, fill)
    outer_row = border .. border .. border .. border .. border .. border .. border .. border .. border .. border .. border .. border .. border .. border .. border .. border .. "\n"
    inner_row = border .. fill .. fill .. fill .. fill .. fill .. fill .. fill .. fill .. fill .. fill .. fill .. fill .. fill .. fill .. border .. "\n"
    
    print(outer_row ..
    inner_row ..
    inner_row .. 
    inner_row ..
    inner_row .. 
    inner_row ..
    inner_row .. 
    inner_row ..
    inner_row .. 
    inner_row ..
    inner_row .. 
    inner_row ..
    inner_row .. 
    inner_row ..
    inner_row ..    
    --
    inner_row ..
    inner_row .. 
    inner_row ..
    inner_row ..
    inner_row ..
    --
    outer_row
    , 0, 0, 5)

end

------------------------------------------------------------------------------------------------------------------------------------------------------
-- ASCII
------------------------------------------------------------------------------------------------------------------------------------------------------
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
\17 - ヌ∧て - Horizontal rectangle
\18 - Horizontal half filled rectangle?
\22 - ◀ - Back
\23 - ▶ - Forward
\24 -「 - Japanese starting quote
\25 - 」- Japanese ending quote
\28 - 、- Japanese comma
\29 - ヌ∧ち - Small square (bigger than a pixel)
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
\146 - ★ - Star
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
__sfx__
000100000d0500f05010050120501405017050190501d0501f050210503405024050250502705028050290502a0502b0502d0502d0502e0502e0502e050070500605005050050500605009050150500000000000
