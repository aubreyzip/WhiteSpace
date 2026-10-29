SMODS.Joker({
    key = 'luminous',
    atlas = 'aws_luminous',
    pos = { x = 0, y = 0 },

    rarity = 2,
    cost = 6,

    blueprint_compat = true,

    loc_txt = {
        name = 'Luminous',
        text = {
            'Using a {C:planet}Planet{} card',
            'upgrades its poker hand',
            '{C:attention}1{} additional time'
        }
    },

    calculate = function(self, card, context)
        if context.using_consumeable
            and context.consumeable
            and context.consumeable.ability
            and context.consumeable.ability.set == 'Planet' then

            -- Vanilla and most modded Planets store one hand in hand_type,
            -- multi-hand Planets (e.g. Cryptid) store a list in hand_types
            local consumeable = context.consumeable.ability.consumeable or {}
            local hands, seen = {}, {}
            local function add(hand)
                if type(hand) == 'string' and not seen[hand] and G.GAME.hands[hand] then
                    seen[hand] = true
                    hands[#hands + 1] = hand
                end
            end
            add(consumeable.hand_type)
            if type(consumeable.hand_types) == 'table' then
                for _, hand in ipairs(consumeable.hand_types) do
                    add(hand)
                end
            end
            if #hands == 0 then return end

            -- Chain one level_up effect per hand; this levels the hand directly
            -- rather than re-using the Planet, so no consumable contexts fire again
            local effect
            for i = #hands, 1, -1 do
                effect = {
                    level_up = 1,
                    level_up_hand = hands[i],
                    extra = effect
                }
            end
            effect.message = localize('k_level_up_ex')
            return effect
        end
    end
})
