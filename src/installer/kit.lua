local addonName, ItruliaUI = ...

local moduleName = "Installer"
local Installer = ItruliaUI:GetModule(moduleName)

local Kit = {}
Installer.Kit = Kit

-- Window #080808 @ 0.80, controls #0e0e0e @ 0.95 -- depth comes from stacking
-- opacity in one near-black family, not from lighter greys.
Kit.palette = {
    window  = { 0.031, 0.031, 0.031, 0.80 },
    control = { 0.055, 0.055, 0.055, 0.95 },
    panel   = { 0.06, 0.06, 0.06, 0.80 },
    border  = { 0, 0, 0, 1 },
    brand   = { 0.910, 0.522, 0.239 }, -- #e8853d, the UI half of this addon's title
    hover   = { 0.851, 0.851, 0.851, 0.15 },
    text    = { 0.92, 0.92, 0.92 },
    textDim = { 0.62, 0.62, 0.62 },
    warn    = { 0.85, 0.33, 0.33 }, -- the rail's "Not Installed" flag; red enough to read at 9px
}

local closeTexture = "Interface\\AddOns\\EllesmereUI\\media\\icons\\eui-close.png"
local closeTextureFallback = "Interface\\Buttons\\UI-StopButton"

function Kit.FontPath()
    local EUI = _G.EllesmereUI

    return (EUI and EUI.GetFontPath and EUI.GetFontPath()) or STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
end

function Kit.SetFont(fontString, size, outline)
    fontString:SetFont(Kit.FontPath(), size or 12, outline or "")
    fontString:SetShadowOffset(0, 0)
end

-- Sizes and offsets are given in UI units, which only line up with screen pixels at a
-- UI scale of 1. Anywhere else a 12-unit box or a 2-unit inset lands mid-pixel and one
-- side of it rounds up while the other rounds down, which is what makes a small square
-- look lopsided. PixelUtil converts a unit figure to the nearest one that falls on a
-- pixel boundary at the scale the frame is actually drawn at, which is why the layout
-- here goes through it rather than through SetPoint and SetSize.

function Kit.Backdrop(frame, inset)
    inset = inset or 0

    local backdrop = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    PixelUtil.SetPoint(backdrop, "TOPLEFT", frame, "TOPLEFT", -inset, inset)
    PixelUtil.SetPoint(backdrop, "BOTTOMRIGHT", frame, "BOTTOMRIGHT", inset, -inset)
    backdrop:SetFrameLevel(math.max(frame:GetFrameLevel() - 1, 0))

    -- edgeSize is in UI units, not pixels: at any UI scale other than 1 an edge of "1"
    -- lands between physical pixels and comes out soft, or two pixels wide on one side
    -- of the frame and one on the other. Snapped to whatever UI-unit size draws as a
    -- single whole pixel at the scale this frame is actually rendered at.
    local edgeSize = PixelUtil.GetNearestPixelSize(1, frame:GetEffectiveScale(), 1)

    backdrop:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = edgeSize,
    })

    local window = Kit.palette.window
    backdrop:SetBackdropColor(window[1], window[2], window[3], window[4])
    backdrop:SetBackdropBorderColor(0, 0, 0, 1)

    frame._kitBackdrop = backdrop

    return backdrop
end

-- A one physical pixel outline, drawn as four strips rather than as a backdrop edge.
--
-- A BackdropTemplate edge is an 8x8 texture stretched around a NineSlice with pixel
-- snapping left on, so wherever one pixel is not one UI unit a side of it rounds to zero
-- and drops out while the side opposite rounds up and comes out twice as thick. On a
-- window that is a hairline; on a 12-unit box it is the whole control. Four strips, each
-- sized to a whole pixel with snapping off so nothing is re-rounded under them, is what
-- EllesmereUI's panels draw and is why their boxes read crisp next to these.
--
-- EllesmereUI's own builder is used whenever it is loaded, so a box here goes through
-- the same code as a box in its options windows rather than through a copy of it.
function Kit.PixelBorder(frame, red, green, blue, alpha)
    alpha = alpha or 1

    local EUI = _G.EllesmereUI
    local PP = EUI and EUI.PP

    if PP and PP.CreateBorder then
        return PP.CreateBorder(frame, red, green, blue, alpha, 1, "OVERLAY", 7)
    end

    local container = CreateFrame("Frame", nil, frame)
    container:SetAllPoints(frame)
    container:SetFrameLevel(frame:GetFrameLevel() + 1)

    local sides = {}

    for index = 1, 4 do
        local strip = container:CreateTexture(nil, "OVERLAY", nil, 7)
        strip:SetColorTexture(red, green, blue, alpha)
        strip:SetSnapToPixelGrid(false)
        strip:SetTexelSnappingBias(0)
        sides[index] = strip
    end

    local function snap()
        local thickness = PixelUtil.GetNearestPixelSize(1, container:GetEffectiveScale(), 1)

        local top, bottom, left, right = sides[1], sides[2], sides[3], sides[4]

        top:ClearAllPoints()
        top:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
        top:SetPoint("TOPRIGHT", container, "TOPRIGHT", 0, 0)
        top:SetHeight(thickness)

        bottom:ClearAllPoints()
        bottom:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", 0, 0)
        bottom:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0, 0)
        bottom:SetHeight(thickness)

        left:ClearAllPoints()
        left:SetPoint("TOPLEFT", top, "BOTTOMLEFT", 0, 0)
        left:SetPoint("BOTTOMLEFT", bottom, "TOPLEFT", 0, 0)
        left:SetWidth(thickness)

        right:ClearAllPoints()
        right:SetPoint("TOPRIGHT", top, "BOTTOMRIGHT", 0, 0)
        right:SetPoint("BOTTOMRIGHT", bottom, "TOPRIGHT", 0, 0)
        right:SetWidth(thickness)
    end

    snap()

    -- The effective scale a frame reports before its first layout pass is its parent's
    -- guess, so the strips are measured again once the window has actually been placed.
    C_Timer.After(0, snap)

    return container
end

function Kit.Button(parent, label, width, height, onClick)
    local button = CreateFrame("Button", nil, parent)
    PixelUtil.SetSize(button, width or 110, height or 24)

    local backdrop = Kit.Backdrop(button)
    local control = Kit.palette.control
    backdrop:SetBackdropColor(control[1], control[2], control[3], control[4])

    local text = button:CreateFontString(nil, "OVERLAY")
    Kit.SetFont(text, 12)
    text:SetPoint("CENTER")
    text:SetText(label)
    text:SetTextColor(Kit.palette.text[1], Kit.palette.text[2], Kit.palette.text[3])
    button._label = text

    -- The hover fill is inset by the border width, so it sits inside the edge.
    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    PixelUtil.SetPoint(highlight, "TOPLEFT", backdrop, "TOPLEFT", 1, -1)
    PixelUtil.SetPoint(highlight, "BOTTOMRIGHT", backdrop, "BOTTOMRIGHT", -1, 1)
    highlight:SetSnapToPixelGrid(true)
    highlight:SetTexelSnappingBias(0)

    local hover = Kit.palette.hover
    highlight:SetColorTexture(hover[1], hover[2], hover[3], hover[4])

    if onClick then
        button:SetScript("OnClick", onClick)
    end

    button.SetLabel = function(self, value)
        self._label:SetText(value)
    end

    -- Active state is a soft brand FILL inside the border, not a border tint --
    -- the same selection language the sidebar rail uses.
    button.SetActive = function(self, on)
        if on and not self._selection then
            local brand = Kit.palette.brand

            local texture = self:CreateTexture(nil, "BACKGROUND", nil, 2)
            texture:SetColorTexture(brand[1], brand[2], brand[3], 0.15)
            PixelUtil.SetPoint(texture, "TOPLEFT", self._kitBackdrop, "TOPLEFT", 1, -1)
            PixelUtil.SetPoint(texture, "BOTTOMRIGHT", self._kitBackdrop, "BOTTOMRIGHT", -1, 1)
            texture:SetSnapToPixelGrid(true)
            texture:SetTexelSnappingBias(0)

            self._selection = texture
        end

        if self._selection then
            self._selection:SetShown(on and true or false)
        end
    end

    return button
end

local boxSize, boxInset = 12, 2

-- A ticked box plus a label, the whole row clickable. The box carries the same
-- border and brand fill the buttons use, so a list of these reads as part of the
-- same kit; the label dims while unticked, which is the state you scan for.
--
-- width nil fits the row to its label, for a checkbox that stands alone and has to
-- centre under something. A column of them passes a width instead, so the boxes line
-- up whatever their labels say.
function Kit.Checkbox(parent, label, width, height, onClick)
    local button = CreateFrame("Button", nil, parent)
    PixelUtil.SetSize(button, width or 110, height or 20)

    local box = CreateFrame("Frame", nil, button)
    PixelUtil.SetSize(box, boxSize, boxSize)

    -- Anchored by its top edge rather than centred on the row: a LEFT-to-LEFT anchor
    -- puts the box wherever half the row's height falls, and half of an odd number of
    -- pixels is between two of them, which leaves every edge of the box a half pixel out.
    -- The inset is measured in whole pixels instead, so the box sits on the grid the row
    -- above it already sits on.
    local onePixel = PixelUtil.GetNearestPixelSize(1, button:GetEffectiveScale(), 1)
    local inset = onePixel > 0
        and math.floor((button:GetHeight() - box:GetHeight()) / onePixel / 2 + 0.5) * onePixel
        or 0
    PixelUtil.SetPoint(box, "TOPLEFT", button, "TOPLEFT", 0, -inset)

    local control = Kit.palette.control
    local brand = Kit.palette.brand

    -- Pixel snapping is off on both textures here, unlike everywhere else in the kit.
    -- It rounds each edge of a region to the nearest pixel on its own, which rescues a
    -- region that was placed off the grid and ruins one that was placed on it: the fill
    -- below is inset from an edge that is already pixel-aligned, so rounding it again is
    -- what makes one side of the gap wider than the other.
    local fill = box:CreateTexture(nil, "BACKGROUND")
    fill:SetAllPoints()
    fill:SetColorTexture(control[1], control[2], control[3], control[4])
    fill:SetSnapToPixelGrid(false)
    fill:SetTexelSnappingBias(0)

    -- The brand edge is what says there is a box there at all: on a dark panel an
    -- unticked one is otherwise a dark square. It does not change with the state, so the
    -- box holds its outline and only the fill inside it comes and goes.
    Kit.PixelBorder(box, brand[1], brand[2], brand[3], 1)

    -- The gap between the edge and the fill is the whole of what this control looks
    -- like, so both insets are put on pixel boundaries: a 2-unit inset that rounds to
    -- one pixel on the left and two on the right is exactly the lopsided look.
    local check = box:CreateTexture(nil, "ARTWORK")
    PixelUtil.SetPoint(check, "TOPLEFT", box, "TOPLEFT", boxInset, -boxInset)
    PixelUtil.SetPoint(check, "BOTTOMRIGHT", box, "BOTTOMRIGHT", -boxInset, boxInset)
    check:SetColorTexture(brand[1], brand[2], brand[3], 1)
    check:SetSnapToPixelGrid(false)
    check:SetTexelSnappingBias(0)
    check:Hide()

    local boxGap = 6

    local text = button:CreateFontString(nil, "OVERLAY")
    Kit.SetFont(text, 12)
    PixelUtil.SetPoint(text, "LEFT", box, "RIGHT", boxGap, 0)
    text:SetJustifyH("LEFT")
    text:SetWordWrap(false)
    text:SetText(label)
    button._label = text

    -- Given a width the label is pinned to the right edge, so a column of these
    -- truncates rather than overflowing; without one the row takes the label's own
    -- width, which is what makes it centreable.
    local function fit()
        if width then
            return
        end

        button:SetWidth(box:GetWidth() + boxGap + math.ceil(text:GetStringWidth()))
    end

    if width then
        PixelUtil.SetPoint(text, "RIGHT", text:GetParent() or UIParent, "RIGHT", 0, 0)
    else
        fit()
    end

    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetColorTexture(brand[1], brand[2], brand[3], 0.10)

    button.SetLabel = function(self, value)
        self._label:SetText(value)
        fit()
    end

    button.GetChecked = function(self)
        return self._checked and true or false
    end

    button.SetChecked = function(self, on)
        self._checked = on and true or false
        check:SetShown(self._checked)

        local color = self._checked and Kit.palette.text or Kit.palette.textDim
        self._label:SetTextColor(color[1], color[2], color[3])
    end

    button:SetChecked(false)

    button:SetScript("OnClick", function(self)
        self:SetChecked(not self:GetChecked())

        if onClick then
            onClick(self, self:GetChecked())
        end
    end)

    return button
end

-- The brand edge that marks a page's primary action. Only the button that imports
-- carries it: it is what separates the thing the page is for from the nav buttons in
-- the corner, which share its fill and its size.
function Kit.Accent(button)
    local brand = Kit.palette.brand

    button._kitBackdrop:SetBackdropBorderColor(brand[1], brand[2], brand[3], 1)

    return button
end

function Kit.CloseButton(parent, size, onClick)
    local button = CreateFrame("Button", nil, parent)
    PixelUtil.SetSize(button, size or 18, size or 18)

    local glyph = button:CreateTexture(nil, "ARTWORK")
    glyph:SetPoint("CENTER")
    PixelUtil.SetSize(glyph, 13, 13)
    glyph:SetTexture(closeTexture)

    glyph:SetVertexColor(0.851, 0.851, 0.851, 1)
    glyph:SetTexelSnappingBias(0)
    glyph:SetSnapToPixelGrid(true)

    local brand = Kit.palette.brand

    button:SetScript("OnEnter", function()
        glyph:SetVertexColor(brand[1], brand[2], brand[3], 1)
    end)

    button:SetScript("OnLeave", function()
        glyph:SetVertexColor(0.851, 0.851, 0.851, 1)
    end)

    if onClick then
        button:SetScript("OnClick", onClick)
    end

    return button
end

-- A row of small squares, one per picture: which one is on screen, and that there are
-- others. Clickable, so the row is navigation as well as an indicator.
--
-- Squares rather than dots because they sit under a rectangular picture and read as
-- "slides" -- and at 8px a square keeps its edges where a circle turns to mush.
local function squareRow(parent, count, onClick)
    local squareSize, squareGap = 8, 5

    local frame = CreateFrame("Frame", nil, parent)
    PixelUtil.SetSize(frame, count * squareSize + (count - 1) * squareGap, squareSize)

    local squares = {}

    for i = 1, count do
        local square = CreateFrame("Button", nil, frame)
        PixelUtil.SetSize(square, squareSize, squareSize)
        PixelUtil.SetPoint(square, "LEFT", square:GetParent() or UIParent, "LEFT", (i - 1) * (squareSize + squareGap), 0)

        local outline = square:CreateTexture(nil, "BACKGROUND")
        PixelUtil.SetPoint(outline, "TOPLEFT", outline:GetParent() or UIParent, "TOPLEFT", -1, 1)
        PixelUtil.SetPoint(outline, "BOTTOMRIGHT", outline:GetParent() or UIParent, "BOTTOMRIGHT", 1, -1)
        outline:SetColorTexture(0, 0, 0, 1)

        local fill = square:CreateTexture(nil, "ARTWORK")
        fill:SetAllPoints()
        square.fill = fill

        local highlight = square:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetAllPoints()
        highlight:SetColorTexture(1, 1, 1, 0.25)

        square:SetScript("OnClick", function()
            onClick(i)
        end)

        squares[i] = square
    end

    function frame:Select(index)
        local brand = Kit.palette.brand

        for i, square in ipairs(squares) do
            if i == index then
                square.fill:SetColorTexture(brand[1], brand[2], brand[3], 1)
            else
                square.fill:SetColorTexture(0.35, 0.35, 0.35, 0.9)
            end
        end
    end

    return frame
end

-- Full-screen viewer, where the screenshots are actually readable. One instance,
-- reused: a screenshot is a big texture and there is no reason to hold several.
--
-- Click the picture or press Right/Left to step through, click a square to jump,
-- Escape or right-click to close. Strata is above the wizard's own DIALOG, so it covers
-- the window that opened it.
local viewer

-- Room along the bottom for the description, the squares and the hint.
local viewerBand = 140

local function ensureViewer()
    if viewer then
        return viewer
    end

    viewer = CreateFrame("Button", "ItruliaUIInstallerViewer", UIParent)
    viewer:SetAllPoints(UIParent)
    viewer:SetFrameStrata("FULLSCREEN_DIALOG")
    viewer:EnableMouse(true)
    viewer:EnableKeyboard(true)
    viewer:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    local shade = viewer:CreateTexture(nil, "BACKGROUND")
    shade:SetAllPoints()
    shade:SetColorTexture(0, 0, 0, 0.85)

    local picture = viewer:CreateTexture(nil, "ARTWORK")
    viewer.picture = picture

    -- Under the picture, which is why these are anchored to the band rather than to the
    -- picture: the picture changes size between slides when their shapes differ, and the
    -- text should not move with it.
    local description = viewer:CreateFontString(nil, "OVERLAY")
    Kit.SetFont(description, 13)
    PixelUtil.SetPoint(description, "BOTTOM", description:GetParent() or UIParent, "BOTTOM", 0, 62)
    description:SetJustifyH("CENTER")
    description:SetSpacing(3)
    description:SetTextColor(Kit.palette.text[1], Kit.palette.text[2], Kit.palette.text[3])
    viewer.description = description

    -- Above the description rather than at a fixed height: the description runs to one
    -- line or three depending on the slide, and the title has to sit on top of whichever
    -- it turns out to be.
    local title = viewer:CreateFontString(nil, "OVERLAY")
    Kit.SetFont(title, 16)
    PixelUtil.SetPoint(title, "BOTTOM", description, "TOP", 0, 8)
    title:SetJustifyH("CENTER")
    title:SetWordWrap(false)
    title:SetTextColor(Kit.palette.text[1], Kit.palette.text[2], Kit.palette.text[3])
    viewer.title = title

    local hint = viewer:CreateFontString(nil, "OVERLAY")
    Kit.SetFont(hint, 12)
    PixelUtil.SetPoint(hint, "BOTTOM", hint:GetParent() or UIParent, "BOTTOM", 0, 20)
    hint:SetTextColor(Kit.palette.textDim[1], Kit.palette.textDim[2], Kit.palette.textDim[3])
    viewer.hint = hint

    -- Step or close, without the two gestures fighting each other: a left click is
    -- "next", a right click is "done".
    viewer:SetScript("OnClick", function(self, button)
        if button == "RightButton" then
            self:Hide()

            return
        end

        self:Step(1)
    end)

    -- Only the keys this handles are swallowed; everything else goes through to the
    -- game, so a viewer left open cannot eat someone's keybinds.
    viewer:SetScript("OnKeyDown", function(self, key)
        if key == "RIGHT" or key == "DOWN" then
            self:SetPropagateKeyboardInput(false)
            self:Step(1)
        elseif key == "LEFT" or key == "UP" then
            self:SetPropagateKeyboardInput(false)
            self:Step(-1)
        elseif key == "ESCAPE" then
            self:SetPropagateKeyboardInput(false)
            self:Hide()
        else
            self:SetPropagateKeyboardInput(true)
        end
    end)

    function viewer:Select(index)
        local count = #self.images

        self.index = ((index - 1) % count) + 1

        local image = self.images[self.index]
        local aspect = image.aspect or (16 / 9)

        -- Fitted per slide: a set can mix shapes (Hiding Bar's two are all but square),
        -- and each is limited by whichever of width or height binds first.
        local width = (UIParent:GetWidth() or 800) - 120
        local height = (UIParent:GetHeight() or 600) - 60 - viewerBand

        if width / aspect > height then
            width = height * aspect
        end

        -- Never past life size. The picture is stored at a pixel size while the viewer
        -- works in UI units, so the ceiling is that pixel size divided by the scale the
        -- units are drawn at -- which is what puts one texture pixel on one screen
        -- pixel. Stretched past it the small ones (Hiding Bar's two, a few hundred
        -- pixels square) become a wall of soft edges that shows less than the file does.
        local native = image.width and (image.width / (UIParent:GetEffectiveScale() or 1))

        if native then
            width = math.min(width, native)
        end

        PixelUtil.SetSize(self.picture, width, width / aspect)
        self.picture:SetTexture(image.path)

        self.description:SetWidth(math.max(width, 400))
        self.description:SetText(image.description or "")
        self.title:SetText(image.title or "")

        if self.row then
            self.row:Select(self.index)
        end
    end

    function viewer:Step(by)
        self:Select(self.index + by)
    end

    viewer:Hide()

    tinsert(UISpecialFrames, "ItruliaUIInstallerViewer")

    return viewer
end

-- images is the whole set and index the one to open on, so the viewer can be stepped
-- through from wherever it was entered.
function Kit.ShowImage(images, index)
    local count = #images

    if count == 0 then
        return
    end

    local frame = ensureViewer()
    frame.images = images

    frame.picture:ClearAllPoints()
    PixelUtil.SetPoint(frame.picture, "CENTER", frame.picture:GetParent() or UIParent, "CENTER", 0, viewerBand / 2)

    -- The row is rebuilt when the number of pictures changes, which happens whenever the
    -- viewer is opened from a different page.
    if frame.row and frame.rowCount ~= count then
        frame.row:Hide()
        frame.row:SetParent(nil)
        frame.row = nil
    end

    if not frame.row and count > 1 then
        frame.row = squareRow(frame, count, function(i)
            frame:Select(i)
        end)
        PixelUtil.SetPoint(frame.row, "BOTTOM", frame.row:GetParent() or UIParent, "BOTTOM", 0, 44)
        frame.rowCount = count
    end

    frame.hint:SetText(count > 1
        and "Click or use the arrow keys to browse. Escape to close"
        or "Escape to close")

    frame:Select(index or 1)
    frame:Show()
end

-- The first picture, with a row of squares under it when there are more. No caption:
-- inline it is a thumbnail -- too small to read a UI from -- so the picture and the
-- squares both open the full-screen viewer, which is where the title and description are.
--
-- maxWidth/maxHeight are the box it has to fit inside; each picture carries its own
-- shape, and the thumbnail is fitted to whichever of the two constrains it, so it is
-- never stretched.
function Kit.Gallery(parent, images, maxWidth, maxHeight)
    local count = #images

    if count == 0 then
        return nil
    end

    local first = images[1]
    local aspect = first.aspect or (16 / 9)

    -- The strip of squares is reserved whether or not this gallery draws one, so a page
    -- with two screenshots gets the same picture as a page with one -- the welcome page
    -- otherwise came out a band shorter than everything after it. On a single-picture
    -- page the reserved strip is simply empty; the frame is anchored by its top, so the
    -- picture lands in the same place either way.
    local rowGap, rowHeight = 6, 8
    local band = rowGap + rowHeight

    local width = math.min(maxWidth, (maxHeight - band) * aspect)
    local height = width / aspect

    local frame = CreateFrame("Frame", nil, parent)
    PixelUtil.SetSize(frame, width, height + band)

    local picture = CreateFrame("Button", nil, frame)
    PixelUtil.SetSize(picture, width, height)
    picture:SetPoint("TOP")
    Kit.Backdrop(picture)

    local texture = picture:CreateTexture(nil, "ARTWORK")
    PixelUtil.SetPoint(texture, "TOPLEFT", texture:GetParent() or UIParent, "TOPLEFT", 1, -1)
    PixelUtil.SetPoint(texture, "BOTTOMRIGHT", texture:GetParent() or UIParent, "BOTTOMRIGHT", -1, 1)
    texture:SetTexture(first.path)

    -- Says "this does something" before you click it.
    local highlight = picture:CreateTexture(nil, "HIGHLIGHT")
    PixelUtil.SetPoint(highlight, "TOPLEFT", highlight:GetParent() or UIParent, "TOPLEFT", 1, -1)
    PixelUtil.SetPoint(highlight, "BOTTOMRIGHT", highlight:GetParent() or UIParent, "BOTTOMRIGHT", -1, 1)
    highlight:SetColorTexture(1, 1, 1, 0.12)

    picture:SetScript("OnClick", function()
        Kit.ShowImage(images, 1)
    end)

    if count > 1 then
        -- Clicking a square opens that picture rather than swapping the thumbnail: at
        -- thumbnail size there is nothing to see, and it is the same gesture as clicking
        -- the picture itself.
        local row = squareRow(frame, count, function(i)
            Kit.ShowImage(images, i)
        end)
        row:SetPoint("BOTTOM")
        row:Select(1)
    end

    return frame
end

-- A URL, in a box you can select and copy. An addon cannot open a browser, so this is
-- the whole of what a link can be here -- the same shape EllesmereUI's social icons use,
-- down to the shaded backdrop that dismisses it on a click anywhere outside.
local linkPopup, linkShade

local function hideLink()
    if linkPopup then
        linkPopup:Hide()
    end

    if linkShade then
        linkShade:Hide()
    end
end

local function buildLinkPopup()
    if linkPopup then
        return linkPopup
    end

    linkShade = CreateFrame("Button", nil, UIParent)
    linkShade:SetAllPoints(UIParent)
    linkShade:SetFrameStrata("FULLSCREEN_DIALOG")
    linkShade:SetFrameLevel(499)
    linkShade:RegisterForClicks("AnyUp")
    linkShade:SetScript("OnClick", hideLink)

    local shade = linkShade:CreateTexture(nil, "BACKGROUND")
    shade:SetAllPoints()
    shade:SetColorTexture(0, 0, 0, 0.20)

    linkShade:Hide()

    linkPopup = CreateFrame("Frame", nil, UIParent)
    PixelUtil.SetSize(linkPopup, 380, 72)
    linkPopup:SetFrameStrata("FULLSCREEN_DIALOG")
    linkPopup:SetFrameLevel(500)
    linkPopup:EnableMouse(true)

    Kit.Backdrop(linkPopup)

    local hint = linkPopup:CreateFontString(nil, "OVERLAY")
    Kit.SetFont(hint, 11)
    PixelUtil.SetPoint(hint, "TOP", hint:GetParent() or UIParent, "TOP", 0, -12)
    hint:SetTextColor(Kit.palette.textDim[1], Kit.palette.textDim[2], Kit.palette.textDim[3])
    hint:SetText("Press Ctrl+C to copy, then Escape to close")

    local box = CreateFrame("EditBox", nil, linkPopup)
    PixelUtil.SetSize(box, 340, 24)
    PixelUtil.SetPoint(box, "TOP", hint, "BOTTOM", 0, -8)
    box:SetAutoFocus(false)
    box:EnableMouse(true)
    box:SetJustifyH("CENTER")
    Kit.SetFont(box, 11)
    box:SetTextColor(Kit.palette.text[1], Kit.palette.text[2], Kit.palette.text[3])

    local boxBackdrop = Kit.Backdrop(box)
    local control = Kit.palette.control
    boxBackdrop:SetBackdropColor(control[1], control[2], control[3], control[4])

    -- Read-only without looking disabled: the text has to stay selectable to be
    -- copyable, so an edit is put back rather than refused.
    box:SetScript("OnTextChanged", function(self, userInput)
        if userInput and self:GetText() ~= self.url then
            self:SetText(self.url or "")
            self:HighlightText()
        end
    end)

    box:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        hideLink()
    end)

    box:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)

    box:SetScript("OnMouseUp", function(self)
        self:HighlightText()
    end)

    linkPopup.box = box
    linkPopup:Hide()

    return linkPopup
end

-- Opens over `anchor`, with the URL selected and focused so Ctrl+C is the only thing
-- left to do. Does nothing without a URL, which is what an entry whose link has not
-- been filled in yet gives.
function Kit.ShowLink(url, anchor)
    if not url or url == "" then
        return
    end

    local popup = buildLinkPopup()

    popup.box.url = url
    popup.box:SetText(url)

    popup:ClearAllPoints()

    if anchor then
        PixelUtil.SetPoint(popup, "BOTTOM", anchor, "TOP", 0, 8)
    else
        PixelUtil.SetPoint(popup, "CENTER", UIParent, "CENTER", 0, 0)
    end

    linkShade:Show()
    popup:Show()

    popup.box:SetFocus()
    popup.box:HighlightText()
end

-- A viewport for a page with more rows than the content area is tall, so the overflow
-- scrolls instead of running under the nav buttons.
--
-- The bar's lane is taken out of the width whether or not the bar is drawn: a list that
-- only overflows on some characters (rows are built from what is installed) would
-- otherwise be laid out at two different widths for the same page.
--
-- Returns the frame to parent rows to, and the function to call once they are on it --
-- the height of a list is only known after it is built, and that height is what says
-- whether there is anything to scroll.
local scrollBarWidth = 4
local scrollBarGap = 6
local scrollStep = 28
local thumbMinHeight = 20

function Kit.ScrollList(parent)
    local width = parent:GetWidth()

    if not width or width < 100 then
        width = 500
    end

    width = width - scrollBarWidth - scrollBarGap

    local viewport = CreateFrame("ScrollFrame", nil, parent)
    PixelUtil.SetPoint(viewport, "TOPLEFT", parent, "TOPLEFT", 0, 0)
    PixelUtil.SetPoint(viewport, "BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0)
    PixelUtil.SetWidth(viewport, width)
    viewport:EnableMouseWheel(true)

    -- No SetPoint on the list: a scroll child is anchored by the ScrollFrame itself, and
    -- that anchor is what SetVerticalScroll moves. Pinning it to the viewport would leave
    -- it where it is and the page would scroll nowhere.
    local list = CreateFrame("Frame", nil, viewport)
    PixelUtil.SetSize(list, width, 1)
    viewport:SetScrollChild(list)

    local track = CreateFrame("Frame", nil, parent)
    PixelUtil.SetPoint(track, "TOPRIGHT", parent, "TOPRIGHT", 0, 0)
    PixelUtil.SetPoint(track, "BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
    PixelUtil.SetWidth(track, scrollBarWidth)
    track:Hide()

    local lane = track:CreateTexture(nil, "ARTWORK")
    lane:SetAllPoints()
    lane:SetColorTexture(1, 1, 1, 0.06)

    local thumb = CreateFrame("Button", nil, track)
    PixelUtil.SetWidth(thumb, scrollBarWidth)

    local fill = thumb:CreateTexture(nil, "OVERLAY")
    fill:SetAllPoints()
    fill:SetColorTexture(Kit.palette.brand[1], Kit.palette.brand[2], Kit.palette.brand[3], 0.55)

    local function range()
        return math.max(list:GetHeight() - viewport:GetHeight(), 0)
    end

    local function update()
        local overflow = range()

        if overflow <= 0 then
            viewport:SetVerticalScroll(0)
            track:Hide()

            return
        end

        track:Show()

        local scroll = math.max(0, math.min(overflow, viewport:GetVerticalScroll()))
        viewport:SetVerticalScroll(scroll)

        local viewHeight = viewport:GetHeight()
        local thumbHeight = math.max(viewHeight * viewHeight / list:GetHeight(), thumbMinHeight)

        PixelUtil.SetHeight(thumb, thumbHeight)
        PixelUtil.SetPoint(thumb, "TOPLEFT", track, "TOPLEFT", 0, -(viewHeight - thumbHeight) * (scroll / overflow))
    end

    local function scrollTo(value)
        viewport:SetVerticalScroll(math.max(0, math.min(range(), value)))
        update()
    end

    viewport:SetScript("OnMouseWheel", function(self, delta)
        scrollTo(self:GetVerticalScroll() - delta * scrollStep)
    end)

    -- The thumb moves over the track while the list moves the other way over a longer
    -- distance, so a drag is measured as a fraction of the travel it has and applied to
    -- the overflow the list has.
    local function onDrag(self)
        local travel = viewport:GetHeight() - self:GetHeight()

        if travel <= 0 then
            return
        end

        local _, cursorY = GetCursorPosition()

        scrollTo(self.scrollFrom + (self.cursorFrom - cursorY / self:GetEffectiveScale()) * range() / travel)
    end

    thumb:RegisterForDrag("LeftButton")

    thumb:SetScript("OnDragStart", function(self)
        local _, cursorY = GetCursorPosition()

        self.cursorFrom = cursorY / self:GetEffectiveScale()
        self.scrollFrom = viewport:GetVerticalScroll()
        self:SetScript("OnUpdate", onDrag)
    end)

    thumb:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    return list, update
end

function Kit.Header(parent, height)
    local plate = parent:CreateTexture(nil, "BORDER")
    plate:SetColorTexture(0, 0, 0, 0.25)
    PixelUtil.SetPoint(plate, "TOPLEFT", plate:GetParent() or UIParent, "TOPLEFT", 1, -1)
    PixelUtil.SetPoint(plate, "TOPRIGHT", plate:GetParent() or UIParent, "TOPRIGHT", -1, -1)
    plate:SetHeight(height or 28)

    return plate
end
