-- SMODS.change_booster_limit raises G.GAME.modifiers.extra_boosters, which the
-- shop's Booster loop reads when a shop is built, and also adds the new packs to
-- the shop that is currently open. Both are saved with the run, so reloading a
-- shop restores its packs instead of generating more

SMODS.Voucher({
    key = 'overpack',
    atlas = 'aws_placeholders',
    pos = { x = 0, y = 3 },

    config = {
        extra = {
            boosters = 1
        }
    },

    loc_txt = {
        name = 'Overpack',
        text = {
            '{C:attention}+#1#{} Booster Pack',
            'available in every shop'
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.boosters } }
    end,

    redeem = function(self, card)
        SMODS.change_booster_limit(card.ability.extra.boosters)
    end,

    -- Called by mods that can remove Vouchers (e.g. Cryptid)
    unredeem = function(self, card)
        SMODS.change_booster_limit(-card.ability.extra.boosters)
    end
})

SMODS.Voucher({
    key = 'overpack_plus',
    atlas = 'aws_placeholders',
    pos = { x = 1, y = 3 },

    requires = { 'v_aws_overpack' },

    config = {
        extra = {
            boosters = 1
        }
    },

    loc_txt = {
        name = 'Overpack Plus',
        text = {
            '{C:attention}+#1#{} Booster Pack',
            'available in every shop'
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.boosters } }
    end,

    redeem = function(self, card)
        SMODS.change_booster_limit(card.ability.extra.boosters)
    end,

    unredeem = function(self, card)
        SMODS.change_booster_limit(-card.ability.extra.boosters)
    end
})
