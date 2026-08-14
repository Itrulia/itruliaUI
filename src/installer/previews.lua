local addonName, ItruliaUI = ...

local moduleName = "Installer"
local Installer = ItruliaUI:GetModule(moduleName)

-- Screenshots, keyed by the page they belong to: `welcome` for the whole setup, and an
-- addon's own key for its page. Add a file under previews/ and a line here.
--
-- The source width and height are passed rather than a ratio, both because it is what
-- you can read off the file and because there is no way to ask a texture how big it is
-- -- the shape has to be declared or the picture comes out stretched.
--
-- title shows under the thumbnail and again in the full-screen viewer; description only
-- in the viewer, since at thumbnail size there is no room for a sentence.
local mediaPath = "Interface\\AddOns\\" .. addonName .. "\\src\\installer\\previews\\"

-- The pixel size is kept as well as the ratio: the ratio shapes the thumbnail, and the
-- size is what the full-screen viewer refuses to grow past (see Kit.ShowImage).
local function preview(file, width, height, title, description)
    return {
        path = mediaPath .. file,
        aspect = width / height,
        width = width,
        height = height,
        title = title,
        description = description,
    }
end

Installer.previews = {
    welcome = {
        preview(
            "preview_01.png",
            2560, 1440,
            "Out in the world",
            "The everyday layout: quest tracker to the left, minimap and meters to the right, unit frames and cooldowns gathered over the action bars, and nameplates on everything around you."
        ),
        preview(
            "preview_02.png",
            2560, 1440,
            "In a raid",
            "The same layout with the raid pieces in play: raid frames bottom left, boss timers bottom right, meters and aura tracking on the right, and reminders over your character."
        ),
    },

    ItruliaQoL = {
        preview(
            "itruliaqol/preview_01.png",
            2560, 1440,
            "Test mode",
            "Every indicator and alert at once, the way test mode shows them. Pet missing, death and interrupt callouts, durability, out of melee, potion ready. In play you only ever see the one that applies."
        ),
    },

    BigWigs = {
        preview(
            "bigwigs/preview01.png",
            2560, 1440,
            "Timer bars",
            "Boss timers sit beside your character where you are already looking, with the emphasized ones pulled out to the bottom right."
        ),
    },

    NSRT = {
        preview(
            "nsrt/preview_01.png",
            2560, 1440,
            "Reminders",
            "Northern Sky's own preview mode, showing where each kind of reminder lands: texts above your character, icons and circles beside it, bars to the right."
        ),
    },

    HidingBar = {
        preview(
            "hidingbar/preview_01.png",
            248, 266,
            "Tucked away",
            "Nothing but the minimap until you want more. Every addon icon is collected onto a bar that stays hidden."
        ),
        preview(
            "hidingbar/preview_02.png",
            245, 264,
            "Opened",
            "The same bar with the pointer on it: the icons unfold beside the minimap in a grid, and fold away again when you leave."
        ),
    },
}
