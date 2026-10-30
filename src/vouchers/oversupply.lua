-- Extra Voucher offers use Steamodded's G.GAME.modifiers.extra_vouchers, which
-- SMODS.get_next_vouchers reads when filling the shop's Voucher list. The list
-- lives in G.GAME.current_round.voucher, so it is saved with the run and topped
-- up (never duplicated) the next time a shop is built.
-- SMODS.change_voucher_limit is not used because it also inserts a Voucher into
-- the shop that is currently open; the extra offer starts with the next shop.

local function change_extra_vouchers(amount)
    G.GAME.modifiers.extra_vouchers = math.max(0, (G.GAME.modifiers.extra_vouchers or 0) + amount)
end

SMODS.Voucher({
    key = 'oversupply',
    atlas = 'aws_placeholders',
    pos = { x = 0, y = 3 },

    config = {
        extra = {
            vouchers = 1
        }
    },

    loc_txt = {
        name = 'Oversupply',
        text = {
            '{C:attention}+#1#{} Voucher available',
            'in every shop'
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.vouchers } }
    end,

    redeem = function(self, card)
        change_extra_vouchers(card.ability.extra.vouchers)
    end,

    -- Called by mods that can remove Vouchers (e.g. Cryptid)
    unredeem = function(self, card)
        change_extra_vouchers(-card.ability.extra.vouchers)
    end
})

SMODS.Voucher({
    key = 'oversupply_plus',
    atlas = 'aws_placeholders',
    pos = { x = 1, y = 3 },

    requires = { 'v_aws_oversupply' },

    config = {
        extra = {
            vouchers = 1
        }
    },

    loc_txt = {
        name = 'Oversupply Plus',
        text = {
            '{C:attention}+#1#{} Voucher available',
            'in every shop'
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.vouchers } }
    end,

    redeem = function(self, card)
        change_extra_vouchers(card.ability.extra.vouchers)
    end,

    unredeem = function(self, card)
        change_extra_vouchers(-card.ability.extra.vouchers)
    end
})
