-- Aubrey's White Space: sounds
assert(SMODS.load_file("src/sounds.lua"))()

-- Aubrey's White Space: Atlases
assert(SMODS.load_file("src/atlases.lua"))()

local function load_folder(folder)
    local files = {}
    for _, file in ipairs(SMODS.NFS.getDirectoryItems(SMODS.current_mod.path .. folder)) do
        if file:match("%.lua$") then
            files[#files + 1] = file
        end
    end
    table.sort(files)
    for _, file in ipairs(files) do
        assert(SMODS.load_file(folder .. "/" .. file))()
    end
end

-- Aubrey's White Space: jokers
load_folder("src/jokers")

-- Aubrey's White Space: vouchers
load_folder("src/vouchers")

-- Aubrey's White Space: config menu, Joker pool toggle and discovery
assert(SMODS.load_file("src/settings.lua"))()

-- Aubrey's White Space: monochrome main menu
assert(SMODS.load_file("backgrounds/monochrome.lua"))()

-- Aubrey's White Space: menu cards (part of the custom theme)
SMODS.current_mod.menu_cards = function()
    local mod = SMODS.Mods.WhiteSpace
    local cards = { func = mod.refresh_title_card }
    if mod.config.custom_menu_theme then
        cards[1] = { key = "j_aws_delinquent" }
    end
    return cards
end