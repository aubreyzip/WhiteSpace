local function card_value(playing_card)
    if SMODS.has_no_rank(playing_card) then
        return 0, false
    end

    local id = playing_card:get_id()
    if id == 14 then
        return 11, true
    elseif id >= 11 then
        return 10, false
    end
    return id, false
end

SMODS.Joker({
    key = 'blackjack',
    atlas = 'aws_placeholders',
    pos = { x = 0, y = 0 },

    rarity = 1,
    cost = 4,

    blueprint_compat = true,

    calculate = function(self, card, context)
        if context.after
            and context.main_eval
            and not context.blueprint
            and G.GAME.current_round.hands_played == 0 then

            local total = 0
            local aces = 0

            for _, playing_card in ipairs(context.full_hand or {}) do
                local value, is_ace = card_value(playing_card)
                total = total + value
                if is_ace then
                    aces = aces + 1
                end
            end

            while total > 21 and aces > 0 do
                total = total - 10
                aces = aces - 1
            end

            if total == 21 then
                ease_dollars(5)

                return {
                    message = 'Blackjack!',
                    colour = G.C.MONEY
                }
            end
        end
    end
})
