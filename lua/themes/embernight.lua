-- lua/themes/embernight.lua
--[[ 
EmberNight - A red-centric, sleep-friendly theme
Author: Sarrtle
Copyright (c) 2025 Sarrtle
License: Apache-2.0
--]]

-- COLORS are still on prototype and may subject to change

---@type Base46Table
local M = {} ---@diagnostic disable-line: missing-fields

-- UI colors (base_30)
-- These entries drive general UI elements: background, panels, line numbers, statusline, etc.
M.base_30 = {
  white = "#ad858b", -- light warm-offwhite for text
  black = "#1b0f0f", -- main background (very dark red)
  darker_black = "#150b0b", -- ~6% darker than black
  black2 = "#251212", -- slightly lighter background for panels
  one_bg = "#251212", -- ~10% lighter than black
  one_bg2 = "#2a1a1a", -- intermediate shade for UI sections
  one_bg3 = "#331e1e", -- further lighter section background
  grey = "#503535", -- muted grey-ish for separators
  grey_fg = "#503535", -- lighter grey for subtle text
  grey_fg2 = "#5a4a4a", -- a bit lighter
  light_grey = "#6a5959", -- lightest grey in UI (e.g., diff context)
  red = "#bf3331", -- primary red (e.g., errors, key highlights)
  baby_pink = "#c27d7d", -- softer rose (e.g., hints, tags)
  pink = "#8f4a4a", -- muted rose (e.g., comments accent if needed)
  line = "#503535", -- line separator color
  green = "#bb5a3c", -- earthy terracotta as “green” accent (diff-add, success)
  vibrant_green = "#d68f5c", -- brighter amber-ish for success highlights
  nord_blue = "#c27d7d", -- repurposed: soft coral for info sections
  blue = "#923e31", -- deep sienna as “blue” accent
  seablue = "#8f4a4a", -- mapped to muted rose for alternative accent
  yellow = "#e69d6b", -- warm amber for warnings or highlights
  sun = "#ffaf81", -- lighter apricot for subtle highlights
  purple = "#8f4a4a", -- reuse muted rose for e.g. LSP hints
  dark_purple = "#700000", -- black cherry for deeper emphasis
  teal = "#8f533d", -- rusted brown as “teal” analog
  orange = "#e69d6b", -- amber-ish for prompts or UI accents
  cyan = "#8f533d", -- same as teal for consistency
  statusline_bg = "#251212", -- statusline background (slightly lighter than main bg)
  lightbg = "#331e1e", -- alternate lighter background (e.g., float windows)
  pmenu_bg = "#8f533d", -- popup menu background
  folder_bg = "#bb5a3c", -- folder icon/background accent
}

-- Syntax colors (base_16)
-- Follows Base16 slots: base00..base0F. You can map these semantically, e.g., base08=red, base09=orange, etc.
M.base_16 = {
  base00 = "#1b0f0f", -- Default Background
  base01 = "#251212", -- Lighter Background (Used for status bars, line number and folding marks)
  base02 = "#2a1a1a", -- Selection Background
  base03 = "#331e1e", -- Comments, Invisibles, Line Highlighting
  base04 = "#8f4a4a", -- Dark Foreground (Used for status line text)
  base05 = "#CBB2B6", -- Default Foreground, Caret, Delimiters, Operators
  base06 = "#f0e5e5", -- Light Foreground (Not often used)
  base07 = "#ffffff", -- Light Background (Not often used)
  base08 = "#923e31", -- Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
  base09 = "#e69d6b", -- Integers, Boolean, Constants, XML Attributes, Diff Changed
  base0A = "#ffaf81", -- Classes, Markup Bold, Search Text Background
  base0B = "#bb5a3c", -- Strings, Inherited Class, Markup Code, Diff Added
  base0C = "#8f533d", -- Support, Regular Expressions, Escape Characters, Markup Quotes
  base0D = "#c27d7d", -- Functions, Methods, Attribute IDs, Headings
  base0E = "#8f4a4a", -- Keywords, Storage, Selector, Markup Italic, Diff Changed
  base0F = "#923e31", -- Deprecated, Opening/Closing Embedded Language Tags, e.g. <?php ?>
}

-- Optional: override or add specific highlight tweaks
M.polish_hl = {
  -- Example: make comments italic
  defaults = {
    Comment = { fg = M.base_30.pink, italic = true },
  },
  -- More Treesitter or plugin-specific highlights can go here:
  -- treesitter = {
  --   ["@variable"] = { fg = M.base_30.foreground_override or "#e8d8d8" },
  -- },
  lsp = {
    DiagnosticVirtualTextError = { bg = nil, fg = M.base_30.red },
    DiagnosticVirtualTextWarn = { bg = nil, fg = M.base_30.yellow },
    DiagnosticVirtualTextInfo = { bg = nil, fg = M.base_30.blue },
    DiagnosticVirtualTextHint = { bg = nil, fg = M.base_30.purple },
  },
}

-- Theme type: dark
M.type = "dark"

-- Allow user override or naming
M = require("base46").override_theme(M, "embernight")

return M
