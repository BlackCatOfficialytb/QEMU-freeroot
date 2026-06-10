"use strict";
require("dotenv/config");
const { Client, Intents, MessageAttachment, MessageActionRow, MessageSelectMenu, MessageEmbed } = require("discord.js");
const tmp = require("tmp");
const axios = require("axios");
const fs = require("fs");
const { spawn } = require("child_process");
const path = require("path");

const LOADING_EMOJI = "<a:loading:1468503527449034846>";
const OBFUSCATE_TIMEOUT = 2 * 60 * 1000;
const ADMIN_ID = "1108080471268663486";
const MAX_INPUT_SIZE = 2 * 1024 * 1024;
const COOLDOWN_TIME = 5000;

const DAILY_CREDITS = 3;
const CONFIG_FILE = path.join(__dirname, "config.json");
const CREDIT_REQUIRED_PRESETS = new Set(["Lightrew", "Env Logger", "Env Logger 2", "R3", "R4"]);
const giftCooldowns = new Map();
const GIFT_COOLDOWN_MS = 4 * 60 * 60 * 1000;
const GIFT_MAX_AMOUNT = 10;

const BACKUP_CHANNEL_ID = "1474339250219778159";
let _configChanged = false;
let _activeJobs = 0;
let _backupTimer = null;

let creditsData = {};
let blacklistData = {};
let whitelistData = {};

const _jobRegistry = new Map();
let _jobCounter = 0;

function _registerJob(label) {
  const id = ++_jobCounter;
  _jobRegistry.set(id, { label, startedAt: Date.now() });
  _activeJobs++;
  return id;
}

function _unregisterJob(id) {
  _jobRegistry.delete(id);
  _activeJobs = Math.max(0, _activeJobs - 1);
}

let _saveConfigTimer = null;
let _pendingSaveResolvers = [];

function _flushSaveQueue() {
  const resolvers = _pendingSaveResolvers.splice(0);
  try {
    const snapshot = _buildConfigSnapshot();
    fs.writeFileSync(CONFIG_FILE, JSON.stringify(snapshot, null, 2), "utf-8");
    scheduleBackup();
    resolvers.forEach(r => r(true));
  } catch (e) {
    console.error("Error saving config:", e);
    resolvers.forEach(r => r(false));
  }
}

function _buildConfigSnapshot() {
  return {
    credits: creditsData,
    blacklist: blacklistData,
    whitelist: whitelistData
  };
}

function saveConfig() {
  return new Promise((resolve) => {
    _pendingSaveResolvers.push(resolve);
    if (_saveConfigTimer) return;
    _saveConfigTimer = setImmediate(() => {
      _saveConfigTimer = null;
      _flushSaveQueue();
    });
  });
}

function scheduleBackup() {
  _configChanged = true;
  if (_backupTimer) return;
  _backupTimer = setTimeout(() => tryBackupConfig(), 5000);
}

async function tryBackupConfig() {
  _backupTimer = null;
  if (_activeJobs > 0) {
    _backupTimer = setTimeout(() => tryBackupConfig(), 5000);
    return;
  }
  if (!_configChanged) return;
  _configChanged = false;
  try {
    if (!client || !client.isReady()) return;
    const channel = await client.channels.fetch(BACKUP_CHANNEL_ID);
    if (!channel) return;
    await channel.send({
      content: `Config backup | <t:${Math.floor(Date.now() / 1000)}:F>`,
      files: [new MessageAttachment(CONFIG_FILE, "config.json")]
    });
  } catch (err) {
    console.error("Backup config error:", err);
    _configChanged = true;
  }
}

function loadConfig() {
  const defaultState = () => ({ credits: {}, blacklist: {}, whitelist: {} });
  let parsed = defaultState();
  try {
    if (fs.existsSync(CONFIG_FILE)) {
      const raw = JSON.parse(fs.readFileSync(CONFIG_FILE, "utf-8"));
      parsed = {
        credits: raw.credits || {},
        blacklist: raw.blacklist || {},
        whitelist: raw.whitelist || {}
      };
    }
  } catch (e) {
    console.error("Error loading config:", e);
    parsed = defaultState();
  }
  creditsData = parsed.credits;
  blacklistData = parsed.blacklist;
  whitelistData = parsed.whitelist;

  Object.entries(blacklistData).forEach(([userId, data]) => {
    blacklistedUsers.set(userId, data);
  });
}

function getTodayString() {
  return new Date().toISOString().slice(0, 10);
}

function _isSameDay(dateStr) {
  return dateStr === getTodayString();
}

function _ensureCreditEntry(userId) {
  const today = getTodayString();
  if (!creditsData[userId]) {
    creditsData[userId] = { credits: DAILY_CREDITS, lastReset: today };
    return true;
  }
  return false;
}

function _maybeResetDailyCredits(userId) {
  const entry = creditsData[userId];
  if (!entry) return;
  if (!_isSameDay(entry.lastReset)) {
    if (entry.credits < DAILY_CREDITS) entry.credits = DAILY_CREDITS;
    entry.lastReset = getTodayString();
  }
}

function getUserCredits(userId) {
  const wasNew = _ensureCreditEntry(userId);
  if (wasNew) {
    saveConfig();
    return creditsData[userId].credits;
  }
  _maybeResetDailyCredits(userId);
  const changed = !_isSameDay(creditsData[userId].lastReset);
  if (changed) saveConfig();
  return creditsData[userId].credits;
}

function deductCredit(userId) {
  getUserCredits(userId);
  const entry = creditsData[userId];
  const before = entry.credits;
  entry.credits = Math.max(0, before - 1);
  saveConfig();
  return entry.credits;
}

function addCredits(userId, amount) {
  getUserCredits(userId);
  creditsData[userId].credits += amount;
  saveConfig();
}

const _DURATION_UNITS = { d: 24 * 60 * 60 * 1000, h: 60 * 60 * 1000, m: 60 * 1000 };

function parseDuration(str) {
  if (!str) return null;
  const match = str.match(/^(\d+)(d|h|m)$/i);
  if (!match) return undefined;
  const [, num, rawUnit] = match;
  const unit = rawUnit.toLowerCase();
  const factor = _DURATION_UNITS[unit];
  return factor ? parseInt(num) * factor : undefined;
}

function formatDuration(ms) {
  const d = Math.floor(ms / (24 * 60 * 60 * 1000));
  const h = Math.floor((ms % (24 * 60 * 60 * 1000)) / (60 * 60 * 1000));
  const m = Math.floor((ms % (60 * 60 * 1000)) / 60000);
  const realParts = [];
  if (d > 0) realParts.push(`${d}d`);
  if (h > 0) realParts.push(`${h}h`);
  if (m > 0) realParts.push(`${m}m`);
  return realParts.join(' ') || '< 1m';
}

function _resolveWhitelistEntry(userId) {
  const entry = whitelistData[userId];
  if (!entry) return null;
  if (entry.expiresAt === null) return { valid: true, permanent: true, entry };
  if (Date.now() < entry.expiresAt) return { valid: true, permanent: false, entry };
  return { valid: false, entry };
}

function isUserWhitelisted(userId) {
  const result = _resolveWhitelistEntry(userId);
  if (!result) return false;
  if (!result.valid) {
    delete whitelistData[userId];
    saveConfig();
    return false;
  }
  return true;
}

function addWhitelist(userId, durationMs) {
  whitelistData[userId] = {
    expiresAt: durationMs ? Date.now() + durationMs : null,
    addedAt: Date.now()
  };
  saveConfig();
}

function removeWhitelist(userId) {
  if (!whitelistData[userId]) return false;
  delete whitelistData[userId];
  saveConfig();
  return true;
}

function _isAdminUser(userId) {
  return userId === ADMIN_ID;
}

function _checkPrivilegeLevel(userId) {
  if (_isAdminUser(userId)) return 'admin';
  if (isUserWhitelisted(userId)) return 'whitelist';
  return 'normal';
}

async function hasUnlimitedCreditsGlobal(userId, client, member = null) {
  const level = _checkPrivilegeLevel(userId);
  return level === 'admin' || level === 'whitelist';
}

function hasUnlimitedCredits(userId, member) {
  const level = _checkPrivilegeLevel(userId);
  return level === 'admin' || level === 'whitelist';
}

const CODE_BLOCK_PATTERN = /```(?:lua)?\n?([\s\S]*?)```/;

const blacklistedUsers = new Map();
const userCooldowns = new Map();

const PRESET_MAP = {
  "minify": "Minify",
  "luamin": "Luamin",
  "format": "Format",
  "beautify": "Beautify",
  "l": "Env Logger",
  "obf me": "Me",
  "obf flow": "Flow",
  "evil": "Evil",
  "abyss": "Abyss",
  "abyss2": "Abyss2",
  "hex": "Hex",
  "obf weak": "Weak",
  "obf li": "Light",
  "obf ps": "Ps",
  "obf rz": "Rz",
  "obf r1": "R1",
  "obf r2": "R2",
  "obf r3": "R3",
  "obf r4": "R4",
  "veil": "Veil",
  "obf l1": "L1",
  "obf l2": "L2",
  "lightrew": "Lightrew",
  "ib1": "Ib1",
  "ib2": "Ib2",
  "ib3": "Ib3",
  "wrd": "Wrd",
  "ibv": "Ibv",
  "medium": "Medium",
  "m1": "M1",
  "m2": "M2",
  "m3": "M3",
  "obf": "Basic",
  "normal": "Normal",
  "ibs": "Ibs",
  "hard": "Hard",
  "max": "Strong",
  "env": "Env",
  "hidden": "MaxSecurity"
};

const PRESET_CHOICES_GROUP = [
  { name: "Minify", value: "Minify" },
  { name: "Luamin", value: "Luamin" },
  { name: "Format", value: "Format" },
  { name: "Beautify", value: "Beautify" },
  { name: "Env Logger", value: "Env Logger" },
];

const PRESET_CHOICES_GROUP1 = [
  { name: "Me", value: "Me" },
  { name: "Flow", value: "Flow" },
  { name: "Evil", value: "Evil" },
  { name: "Abyss (Evil Level 2)", value: "Abyss" },
  { name: "Abyss2 (Evil Level 3)", value: "Abyss2" },
  { name: "Hex", value: "Hex" },
  { name: "Weak", value: "Weak" },
  { name: "Light", value: "Light" },
  { name: "Ps", value: "Ps" },
  { name: "Rz", value: "Rz" },
  { name: "R2", value: "R2" },
  { name: "Veil", value: "Veil" },
  { name: "L1", value: "L1" },
  { name: "L2 (L1 Level 2)", value: "L2" },
  { name: "lightrew", value: "Lightrew" },
  { name: "Ib1", value: "Ib1" },
  { name: "Ib2", value: "Ib2" },
  { name: "Ib3", value: "Ib3" }
];

const PRESET_CHOICES_GROUP2 = [
  { name: "Wrd", value: "Wrd" },
  { name: "Ibv", value: "Ibv" },
  { name: "Medium", value: "Medium" },
  { name: "M1 (Medium Level 1)", value: "M1" },
  { name: "M2 (Medium Level 2)", value: "M2" },
  { name: "M3 (Medium Level 3)", value: "M3" },
  { name: "Basic (Default)", value: "Basic" }
];

const PRESET_CHOICES_GROUP3 = [
  { name: "Normal (Under 100Kb)", value: "Normal" },
  { name: "Ibs - Luau only (Under 100Kb)", value: "Ibs" },
  { name: "Hard (Under 100Kb)", value: "Hard" },
  { name: "Strong/Max - Luau only (Under 100Kb)", value: "Strong" },
  { name: "Env (Under 100Kb)", value: "Env" },
  { name: "MaxSecurity/Hidden (Under 100Kb)", value: "MaxSecurity" }
];

const _sortedPresetKeys = Object.keys(PRESET_MAP).sort((a, b) => b.length - a.length);

const levenshtein = (a, b) => {
  const aLen = a.length, bLen = b.length;
  if (aLen === 0) return bLen;
  if (bLen === 0) return aLen;
  let prev = new Uint16Array(aLen + 1);
  let curr = new Uint16Array(aLen + 1);
  for (let j = 0; j <= aLen; j++) prev[j] = j;
  for (let i = 1; i <= bLen; i++) {
    curr[0] = i;
    for (let j = 1; j <= aLen; j++) {
      curr[j] = b[i - 1] === a[j - 1]
        ? prev[j - 1]
        : 1 + Math.min(prev[j - 1], prev[j], curr[j - 1]);
    }
    [prev, curr] = [curr, prev];
  }
  return prev[aLen];
};

function _resolveExactPreset(cleanContent) {
  for (const key of _sortedPresetKeys) {
    if (cleanContent.startsWith(key)) return PRESET_MAP[key];
  }
  return null;
}

function _resolveFuzzyPreset(args) {
  const firstWord = args[0];
  let bestMatch = null;
  let minDistance = 3;
  for (const key of _sortedPresetKeys) {
    const keyParts = key.split(" ");
    let inputPart;
    if (keyParts.length === 1) {
      inputPart = firstWord;
    } else {
      if (args.length < keyParts.length) continue;
      inputPart = args.slice(0, keyParts.length).join(" ");
    }
    const dist = levenshtein(key, inputPart);
    if (dist < minDistance) {
      minDistance = dist;
      bestMatch = PRESET_MAP[key];
    }
  }
  return bestMatch;
}

const getPreset = (content) => {
  const lower = content.toLowerCase().trim();
  if (!lower.startsWith("!") && !lower.startsWith(".")) return null;
  const cleanContent = lower.substring(1);
  const args = cleanContent.split(/\s+/);
  const exact = _resolveExactPreset(cleanContent);
  if (exact) return exact;
  return _resolveFuzzyPreset(args);
};

function isCommand(content) {
  const lower = content.toLowerCase();
  const prefixedCommands = ["help", "wl", "unwl", "blacklist", "unblacklist"];
  const hasPrefix = (cmd) => lower.startsWith(`!${cmd}`) || lower.startsWith(`.${cmd}`);
  if (prefixedCommands.some(hasPrefix)) return true;
  if (getPreset(lower)) return true;
  return false;
}

async function _resolveDisplayName(userId, client, fallback) {
  if (fallback) return fallback;
  try {
    const user = await client.users.fetch(userId);
    return user.tag;
  } catch {
    return userId;
  }
}

async function addToBlacklist(userId, reason, client, username = null) {
  try {
    const displayName = await _resolveDisplayName(userId, client, username);
    const entry = { reason: reason || 'No reason provided', username: displayName };
    blacklistedUsers.set(userId, entry);
    blacklistData[userId] = entry;
    if (whitelistData[userId]) delete whitelistData[userId];
    saveConfig();
    return true;
  } catch (err) {
    console.error("Error adding to blacklist:", err);
    return false;
  }
}

function removeFromBlacklist(userId) {
  if (!blacklistedUsers.has(userId)) return false;
  blacklistedUsers.delete(userId);
  delete blacklistData[userId];
  saveConfig();
  return true;
}

function _extractMentionId(input) {
  const match = input.match(/^<@!?(\d+)>$/);
  return match ? match[1] : null;
}

function _isRawId(input) {
  return /^\d+$/.test(input);
}

async function _findMemberByName(guild, lowerInput) {
  try {
    const members = await guild.members.fetch();
    const found = members.find(m =>
      m.user.username.toLowerCase() === lowerInput ||
      m.user.tag.toLowerCase() === lowerInput ||
      (m.nickname && m.nickname.toLowerCase() === lowerInput)
    );
    return found ? found.user.id : null;
  } catch (err) {
    console.error("Error fetching members:", err);
    return null;
  }
}

async function parseUserId(userInput, message) {
  if (!userInput) return null;
  const mentionId = _extractMentionId(userInput);
  if (mentionId) return mentionId;
  if (_isRawId(userInput)) return userInput;
  if (message.guild) {
    return await _findMemberByName(message.guild, userInput.toLowerCase());
  }
  return null;
}

const CooldownManager = (() => {
  function _getCooldownEnd(userId) {
    return userCooldowns.get(userId) ?? 0;
  }
  function _computeRemaining(userId) {
    const now = Date.now();
    const end = _getCooldownEnd(userId);
    if (end <= now) return null;
    return ((end - now) / 1000).toFixed(2);
  }
  return {
    check(userId) {
      if (_isAdminUser(userId)) return null;
      return _computeRemaining(userId);
    },
    set(userId) {
      if (_isAdminUser(userId)) return;
      const expires = Date.now() + COOLDOWN_TIME;
      userCooldowns.set(userId, expires);
    },
    clear(userId) {
      userCooldowns.delete(userId);
    }
  };
})();

const checkCooldown = (userId) => CooldownManager.check(userId);
const setCooldown = (userId) => CooldownManager.set(userId);

function _buildSpawnArgs(preset, filename, outFileName) {
  if (preset === "Lightrew") {
    const exePath = path.join(__dirname, "lightrew", "Xhider CLI", "bin", "Release", "netcoreapp3.1", "Xhider CLI.exe");
    return { cmd: exePath, args: [filename, outFileName] };
  }
  if (preset === "Env Logger") {
    return { cmd: "python", args: ["uveilr/main2.py", filename, "-o", outFileName] };
  }
  return { cmd: "lua", args: ["./lua/cli.lua", "--LuaU", "--preset", preset, filename, "--out", outFileName] };
}

function obfuscate(filename, preset) {
  return new Promise((resolve, reject) => {
    const outFile = tmp.fileSync();
    const { cmd, args } = _buildSpawnArgs(preset, filename, outFile.name);
    const child = spawn(cmd, args);

    const timer = setTimeout(() => {
      try { child.kill(); } catch (e) {}
      reject(new Error("Timeout"));
    }, OBFUSCATE_TIMEOUT);

    let stderr = "";
    if (child.stderr) {
      child.stderr.on("data", (data) => { stderr += data.toString(); });
    }
    child.on("close", (code) => {
      clearTimeout(timer);
      if (code !== 0 && !child.killed) {
        reject(new Error(stderr || `Process exited with code ${code}`));
      } else {
        resolve(outFile);
      }
    });
    child.on("error", (err) => {
      clearTimeout(timer);
      reject(err);
    });
  });
}

const _ERROR_REPLACEMENTS = [
  [/\/data\/data\/com\.termux\/files\//g, ""],
  [/usr\/bin\/lua:\s*/g, ""],
  [/\.\/lua\/luacrack\/steps\//g, ""],
  [/\.\/lua\/luacrack\/vmstrings\//g, ""],
  [/[^\s]+\.lua:\d+:\s*/g, ""],
  [/\[C\]:/g, ""],
  [/in function/g, ""],
  [/stack traceback:/g, ""],
  [/^Error:\s*/i, ""]
];

const _applyErrorReplacements = (line) =>
  _ERROR_REPLACEMENTS.reduce((acc, [pattern, replacement]) => acc.replace(pattern, replacement), line).trim();

const filterError = (msg) => {
  const lines = msg.split("\n");
  for (const line of lines) {
    if (line.toLowerCase().includes("error")) {
      return _applyErrorReplacements(line);
    }
  }
  return "I'm sorry dear I failed :)";
};

const helpPages = [
  {
    title: 'Commands List',
    description:
      '> **[ help ] ›** Show this help menu with all commands\n' +
      '> **[ minify, luamin ] ›** Minify Lua code (remove spaces)\n' +
      '> **[ format, beautify ] ›** Format and beautify Lua code\n' +
      '> **[ l ] ›** Environment Logger for debugging `[Need Credit]`\n\n' +
      '**How to use:**\n' +
      '• Attach a .lua file with command\n' +
      '• Use code block: ```lua code ```\n' +
      '• Reply to message with code/file\n\n' +
      '**Examples:**\n' +
      '`!obf [attach file]`\n' +
      '`.evil` with code block\n\n' +
      '**Limits:** Cooldown 5s | Max 2MB',
    color: '#5865F2'
  },
  {
    title: 'Commands List',
    description:
      '**[ All Sizes ]**\n' +
      '> **[ obf me ] ›** Me preset obfuscation\n' +
      '> **[ obf flow ] ›** Flow obfuscation\n' +
      '> **[ obf weak ] ›** Weak protection level\n' +
      '> **[ obf li ] ›** Light obfuscation\n' +
      '> **[ obf ps ] ›** Ps preset\n' +
      '> **[ obf rz ] ›** Rz preset\n' +
      '> **[ obf r2 ] ›** R2 preset\n' +
      '> **[ obf r1 ] ›** R1 preset\n' +
      '> **[ obf r3 ] ›** R3 preset `[Need Credit]`\n' +
      '> **[ obf r4 ] ›** R4 preset `[Need Credit]`\n' +
      '> **[ obf l1 ] ›** Light Level 1\n' +
      '> **[ obf l2 ] ›** Level 2 (stronger than L1)\n' +
      '> **[ lightrew ] ›** Light rewrite `[Need Credit]`\n' +
      '> **[ veil ] ›** Veil protection\n' +
      '> **[ evil ] ›** Evil preset obfuscation\n' +
      '> **[ abyss ] ›** (Evil Level 2)\n' +
      '> **[ abyss2 ] ›** (Evil Level 3)\n' +
      '> **[ hex ] ›** Hex encoding obfuscation\n' +
      '> **[ ib1 ] ›** IronBrew 1\n' +
      '> **[ ib2 ] ›** IronBrew preset 2\n' +
      '> **[ ib3 ] ›** IronBrew preset 3\n\n' +
      '**Note:** These presets work with any file size, but processing time may vary based on file size and complexity.',
    color: '#5865F2'
  },
  {
    title: 'Commands List',
    description:
      '**[ Limit < 300KB ]**\n' +
      '> **[ wrd ] ›** Wrd Obfuscate your scripts with the WeAreDevs obfuscator\n' +
      '> **[ ibv ] ›** IronBrew variant\n' +
      '> **[ medium ] ›** Medium protection\n' +
      '> **[ m1 ] ›** Medium Level 1\n' +
      '> **[ m2 ] ›** Medium Level 2\n' +
      '> **[ m3 ] ›** Medium Level 3\n' +
      '> **[ obf ] ›** Basic/Default obfuscation\n' +
      '**[ Limit < 100KB ]**\n' +
      '> **[ normal ] ›** Normal protection\n' +
      '> **[ ibs ] ›** IronBrew Strong - Luau only\n' +
      '> **[ hard ] ›** Hard protection\n' +
      '> **[ max ] ›** Maximum/Strong - Luau only\n' +
      '> **[ env ] ›** Environment protection\n' +
      '> **[ hidden ] ›** MaxSecurity - Luau only',
    color: '#5865F2'
  },
  {
    title: 'Commands List',
    description:
      '**[ Admin Commands ]**\n' +
      '> **[ blacklist <user> [reason] ] ›** Add user to blacklist\n' +
      '> **[ unblacklist <user> ] ›** Remove user from blacklist\n' +
      '> **[ wl <user> [duration] ] ›** Whitelist a user (unlimited credits)\n' +
      '  - No duration = lifetime | Duration: `1d`, `12h`, `30m`\n' +
      '> **[ unwl <user> ] ›** Remove whitelist from a user\n\n' +
      '**[ Credit Commands ]**\n' +
      '> **[ credits ] ›** Check your own remaining credits\n' +
      '> **[ credits <user> ] ›** Check another user credits\n' +
      '> **[ gift <user> <amount> ] ›** Gift credits to another user\n' +
      '  - Admin: no cooldown, no limit\n' +
      '  - Whitelist role: 4h cooldown, max 10 per gift\n' +
      '> **[ take <user> <amount> ] ›** Remove credits from a user (Admin only)\n\n' +
      '**Credit Info:**\n' +
      '• Commands marked `[Need Credit]` cost 1 credit each\n' +
      '• Each user gets 3 credits per day (resets daily)\n' +
      '• Credits above 3 are kept and not reset\n' +
      '• Errors do not consume credits\n\n' +
      '**Examples:**\n' +
      '`.blacklist 123456789 Spam`\n' +
      '`.blacklist @username Abuse`\n' +
      '`.unblacklist 123456789`\n' +
      '`.wl @user 7d`\n' +
      '`.wl 123456789`\n' +
      '`.unwl @user`\n' +
      '`.gift @user 5`\n\n' +
      '**Website Obfuscated Xhider:**\n' +
      '`https://xhider.xyz/`',
    color: '#5865F2'
  }
];

const helpCollectors = new Map();

function _buildHelpEmbed(pageIndex) {
  const data = helpPages[pageIndex];
  return new MessageEmbed()
    .setColor(data.color)
    .setTitle(data.title)
    .setDescription(data.description)
    .setFooter({ text: `Page ${pageIndex + 1} / ${helpPages.length}` });
}

function _buildHelpRow(pageIndex) {
  return new MessageActionRow().addComponents(
    {
      type: 'BUTTON',
      customId: `help_prev_${pageIndex}`,
      label: 'Previous',
      style: 'SECONDARY',
      disabled: pageIndex === 0
    },
    {
      type: 'BUTTON',
      customId: `help_next_${pageIndex}`,
      label: 'Next',
      style: 'SECONDARY',
      disabled: pageIndex === helpPages.length - 1
    }
  );
}

const showHelp = async (message, page = 0) => {
  page = Math.max(0, Math.min(page, helpPages.length - 1));
  try {
    const sentMessage = await message.reply({
      embeds: [_buildHelpEmbed(page)],
      components: [_buildHelpRow(page)]
    });

    if (helpCollectors.has(message.author.id)) {
      helpCollectors.get(message.author.id).stop();
    }

    const collector = sentMessage.createMessageComponentCollector({ time: 300000 });
    helpCollectors.set(message.author.id, collector);

    collector.on('collect', async interaction => {
      if (interaction.user.id !== message.author.id) {
        await interaction.reply({ content: 'Not supported :)', ephemeral: true });
        return;
      }
      const isPrev = interaction.customId.startsWith('help_prev');
      const isNext = interaction.customId.startsWith('help_next');
      let newPage = page;
      if (isPrev) newPage = Math.max(0, page - 1);
      else if (isNext) newPage = Math.min(helpPages.length - 1, page + 1);
      await interaction.update({
        embeds: [_buildHelpEmbed(newPage)],
        components: [_buildHelpRow(newPage)]
      });
      page = newPage;
    });

    collector.on('end', () => {
      helpCollectors.delete(message.author.id);
      sentMessage.edit({ components: [] }).catch(() => {});
    });
  } catch (err) {
    console.error('Help error:', err);
    await message.reply('An error occurred while showing help menu.');
  }
};

const RANDOM_QUESTIONS = [
  "Did you know Lua was created in Brazil in 1993?", "What's your favorite Lua feature?",
  "Have you tried LuaJIT for better performance?", "Do you prefer Lua 5.1 or 5.4?",
  "What's the hardest bug you've fixed in Lua?", "Do you use metatables often in your scripts?",
  "Have you ever made a game with Love2D?", "What's your opinion on Lua coroutines?",
  "Do you prefer tables or userdata?", "Have you worked with Lua C API before?",
  "What's your favorite Lua library?", "Do you write Lua for Roblox or FiveM?",
  "Have you tried concatenation optimization in Lua?", "What's the most complex script you've obfuscated?",
  "Do you prefer local or global variables?", "Have you ever contributed to a Lua project?",
  "What's your take on Lua's garbage collector?", "Do you use pairs or ipairs more often?",
  "Have you explored Lua patterns for string matching?", "What's your biggest Lua project so far?"
];

const getRandomQuestion = () => RANDOM_QUESTIONS[Math.floor(Math.random() * RANDOM_QUESTIONS.length)];

async function safeReply(message, content) {
  try {
    await message.reply(content);
  } catch (err) {
    const isUnknown = err.code === 50035 || err.message.includes("Unknown message");
    if (isUnknown) {
      await message.channel.send(content);
    } else {
      throw err;
    }
  }
}

function cleanupFiles(...files) {
  setImmediate(() => {
    files.forEach(f => {
      try { if (f) f.removeCallback(); }
      catch (e) { console.error("Cleanup error:", e.message); }
    });
  });
}

function _buildResponseContent(preset, processingTime, creditLine) {
  return `Selected Mode: ${preset}\nProcessing Time: ${processingTime}ms\n-# ${getRandomQuestion()}${creditLine}`;
}

async function _sendObfResult(message, isInteraction, loadingMsg, content, files) {
  const payload = { content, files };
  if (isInteraction) return message.editReply(payload);
  if (loadingMsg) return loadingMsg.edit(payload);
  return safeReply(message, payload);
}

async function _sendObfError(message, isInteraction, loadingMsg, errorMsg) {
  if (isInteraction) return message.editReply(errorMsg);
  if (loadingMsg) return loadingMsg.edit({ content: errorMsg, files: [] });
  return safeReply(message, errorMsg);
}

async function processObf(message, tmpFile, preset, sourceInfo, codeContent = null, client, originalFileName = null, isInteraction = false, loadingMsg = null, onSuccess = null) {
  const startTime = Date.now();
  try {
    const outFile = await obfuscate(tmpFile.name, preset);
    const stats = fs.statSync(outFile.name);

    if (stats.size === 0) {
      const errorMsg = "I'm sorry dear I failed :)";
      await _sendObfError(message, isInteraction, loadingMsg, errorMsg);
      cleanupFiles(outFile, tmpFile);
      return;
    }

    const processingTime = Date.now() - startTime;
    const attachment = new MessageAttachment(outFile.name, `${Math.floor(Math.random() * 1e16)}.lua`);

    let creditLine = '';
    if (onSuccess) {
      const remainingCredits = onSuccess();
      creditLine = `\n-# You have ${remainingCredits} credit(s) remaining.`;
    }

    const responseContent = _buildResponseContent(preset, processingTime, creditLine);
    await _sendObfResult(message, isInteraction, loadingMsg, responseContent, [attachment]);

    const userTag = isInteraction ? message.user.tag : message.author.tag;
    console.log(`${userTag} -> ${sourceInfo} @ ${preset} | ${processingTime}ms`);
    cleanupFiles(outFile, tmpFile);
  } catch (err) {
    console.error(err);
    const isTimeout = err.message === "Timeout";
    const errorMsg = isTimeout
      ? `I'm sorry dear I failed :) \`\`\`Timed out while processing.\`\`\``
      : `I'm sorry dear I failed :) \`\`\`${filterError(err.message || err.toString())}\`\`\``;
    await _sendObfError(message, isInteraction, loadingMsg, errorMsg);
    cleanupFiles(tmpFile);
  }
}

async function handleWithEmoji(message, handler) {
  let loadingMsg;
  const jobId = _registerJob(`msg:${message.id}`);
  try {
    loadingMsg = await message.reply(`${LOADING_EMOJI} Processing...`);
    await handler(loadingMsg);
  } catch (err) {
    console.error("Handler error:", err);
    if (loadingMsg) {
      await loadingMsg.edit(`\`\`\`Error: ${filterError(err.message)}\`\`\``);
    }
  } finally {
    _unregisterJob(jobId);
    if (_activeJobs === 0 && _configChanged && !_backupTimer) {
      _backupTimer = setTimeout(() => tryBackupConfig(), 2000);
    }
  }
}

async function downloadFile(url) {
  const response = await axios.get(url, { responseType: "stream", timeout: 30000 });
  const declaredSize = response.headers["content-length"];
  if (declaredSize && parseInt(declaredSize) > MAX_INPUT_SIZE) {
    throw new Error("File too large (Max 2MB)");
  }
  const tmpFile = tmp.fileSync({ postfix: ".lua" });
  const writeStream = fs.createWriteStream(tmpFile.name);
  response.data.pipe(writeStream);
  await new Promise((resolve, reject) => {
    writeStream.on("finish", resolve);
    writeStream.on("error", reject);
  });
  return tmpFile;
}

const createTempFile = (content) => {
  const tmpFile = tmp.fileSync({ postfix: ".lua" });
  fs.writeFileSync(tmpFile.name, content, "utf-8");
  return tmpFile;
};

const client = new Client({
  intents: [
    Intents.FLAGS.GUILDS,
    Intents.FLAGS.GUILD_MESSAGES,
    Intents.FLAGS.DIRECT_MESSAGES,
    Intents.FLAGS.GUILD_MEMBERS
  ],
  partials: ["CHANNEL", "MESSAGE"]
});

client.once("ready", async () => {
  console.log(`Logged in as ${client.user.tag}`);
  client.user.setPresence({
    activities: [{ name: "Obfuscator | !help", type: "PLAYING" }],
    status: "idle"
  });

client.on("messageCreate", async (message) => {
  if (message.author.bot) return;
  const content = message.content;
  const lower = content.toLowerCase();

  if (lower.startsWith("!help") || lower.startsWith(".help")) { showHelp(message); return; }

  if (lower.startsWith("!credits") || lower.startsWith(".credits")) {
    const args = content.trim().split(/\s+/).slice(1);

    if (args.length === 0) {
      const userId = message.author.id;
      if (_isAdminUser(userId)) {
        await safeReply(message, `You are the admin!`);
      } else if (isUserWhitelisted(userId)) {
        const wlResult = _resolveWhitelistEntry(userId);
        if (wlResult && wlResult.permanent) {
          await safeReply(message, `You already have a whitelist. *(Lifetime)*`);
        } else if (wlResult) {
          const remaining = wlResult.entry.expiresAt - Date.now();
          await safeReply(message, `You already have a whitelist. *(${formatDuration(remaining)} remaining)*`);
        }
      } else {
        const credits = getUserCredits(userId);
        await safeReply(message, `Credits: ${credits}/${DAILY_CREDITS} remaining today.`);
      }
    } else {
      const targetId = await parseUserId(args.join(" "), message);
      if (!targetId) {
        await safeReply(message, `User not found. Please use an ID, @mention, or username.`);
        return;
      }
      let targetUser;
      try { targetUser = await client.users.fetch(targetId); } catch (e) {}
      const targetName = targetUser ? targetUser.tag : targetId;
      if (_isAdminUser(targetId)) {
        await safeReply(message, `**${targetName}** is the admin!`);
      } else if (isUserWhitelisted(targetId)) {
        const wlResult = _resolveWhitelistEntry(targetId);
        if (wlResult && wlResult.permanent) {
          await safeReply(message, `**${targetName}** has a whitelist. *(Lifetime)*`);
        } else if (wlResult) {
          const remaining = wlResult.entry.expiresAt - Date.now();
          await safeReply(message, `**${targetName}** has a whitelist. *(${formatDuration(remaining)} remaining)*`);
        }
      } else {
        const credits = getUserCredits(targetId);
        await safeReply(message, `**${targetName}** has ${credits}/${DAILY_CREDITS} credit(s) remaining today.`);
      }
    }
    return;
  }

  if (lower.startsWith("!gift") || lower.startsWith(".gift")) {
    const member = message.guild
      ? await message.guild.members.fetch(message.author.id).catch(() => null)
      : null;
    const isAdmin = _isAdminUser(message.author.id);
    const hasCreditRole = await hasUnlimitedCreditsGlobal(message.author.id, client, member);

    if (!isAdmin && !hasCreditRole) {
      await safeReply(message, "You do not have permission to use the `.gift` command.");
      return;
    }

    const args = content.trim().split(/\s+/).slice(1);
    if (args.length < 2) {
      await safeReply(message, "Usage: `.gift <id/name/@user> <amount>`");
      return;
    }

    const amountStr = args[args.length - 1];
    const amount = parseInt(amountStr);
    if (isNaN(amount) || amount <= 0) {
      await safeReply(message, "Invalid credit amount.");
      return;
    }

    if (!isAdmin && amount > GIFT_MAX_AMOUNT) {
      await safeReply(message, `You can only gift up to **${GIFT_MAX_AMOUNT}** credits at a time.`);
      return;
    }

    if (!isAdmin) {
      const lastGift = giftCooldowns.get(message.author.id);
      const cooldownExpired = !lastGift || Date.now() >= lastGift + GIFT_COOLDOWN_MS;
      if (!cooldownExpired) {
        const remaining = Math.ceil((lastGift + GIFT_COOLDOWN_MS - Date.now()) / 60000);
        await safeReply(message, `You must wait **${remaining} minute(s)** before gifting credits again.`);
        return;
      }
    }

    const userInput = args.slice(0, args.length - 1).join(" ");
    const targetId = await parseUserId(userInput, message);
    if (!targetId) {
      await safeReply(message, "User not found. Please use an ID, @mention, or username.");
      return;
    }

    addCredits(targetId, amount);
    if (!isAdmin) giftCooldowns.set(message.author.id, Date.now());

    const targetCredits = getUserCredits(targetId);
    await safeReply(message, `Gifted **${amount}** credit(s) to <@${targetId}>. They now have **${targetCredits}** credit(s).`);
    return;
  }

  if (lower.startsWith("!take") || lower.startsWith(".take")) {
    if (!_isAdminUser(message.author.id)) {
      await safeReply(message, `Only the admin can use this command.`);
      return;
    }

    const takeArgs = content.trim().split(/\s+/).slice(1);
    if (takeArgs.length < 2) {
      await safeReply(message, `Usage: \`.take <id/name/@user> <amount>\``);
      return;
    }

    const takeAmount = parseInt(takeArgs[takeArgs.length - 1]);
    if (isNaN(takeAmount) || takeAmount <= 0) {
      await safeReply(message, `Invalid credit amount.`);
      return;
    }

    const takeInput = takeArgs.slice(0, takeArgs.length - 1).join(" ");
    const takeTargetId = await parseUserId(takeInput, message);
    if (!takeTargetId) {
      await safeReply(message, `User not found. Please use an ID, @mention, or username.`);
      return;
    }

    getUserCredits(takeTargetId);
    const before = creditsData[takeTargetId].credits;
    creditsData[takeTargetId].credits = Math.max(0, before - takeAmount);
    saveConfig();
    const after = creditsData[takeTargetId].credits;
    await safeReply(message, `Removed **${before - after}** credit(s) from <@${takeTargetId}>. They now have **${after}** credit(s).`);
    return;
  }

  if (lower.startsWith("!wl") || lower.startsWith(".wl")) {
    if (!_isAdminUser(message.author.id)) {
      await safeReply(message, "Only admin can use this command.");
      return;
    }
    const args = content.trim().split(/\s+/).slice(1);
    if (args.length < 1) {
      await safeReply(message, "Usage: `.wl <id/@user/username> [duration: 1d/2h/30m]`\nNo duration = lifetime.");
      return;
    }
    const lastArg = args[args.length - 1];
    const hasDuration = args.length >= 2 && /^\d+(d|h|m)$/i.test(lastArg);
    const durationMs = hasDuration ? parseDuration(lastArg) : null;
    const userInput = hasDuration ? args.slice(0, args.length - 1).join(" ") : args.join(" ");
    const userId = await parseUserId(userInput, message);
    if (!userId) {
      await safeReply(message, "Could not find user. Please provide a valid ID, mention, or username.");
      return;
    }
    addWhitelist(userId, durationMs);
    const durationLabel = durationMs ? `**${formatDuration(durationMs)}**` : `**lifetime**`;
    await safeReply(message, `<@${userId}> has been whitelisted for ${durationLabel}.`);
    return;
  }

  if (lower.startsWith("!unwl") || lower.startsWith(".unwl")) {
    if (!_isAdminUser(message.author.id)) {
      await safeReply(message, "Only admin can use this command.");
      return;
    }
    const args = content.trim().split(/\s+/).slice(1);
    if (args.length < 1) {
      await safeReply(message, "Usage: `.unwl <id/@user/username>`");
      return;
    }
    const userId = await parseUserId(args.join(" "), message);
    if (!userId) {
      await safeReply(message, "Could not find user. Please provide a valid ID, mention, or username.");
      return;
    }
    const success = removeWhitelist(userId);
    const reply = success
      ? `<@${userId}>'s whitelist has been removed.`
      : `User <@${userId}> does not have a whitelist.`;
    await safeReply(message, reply);
    return;
  }

  if (lower.startsWith("!blacklist") || lower.startsWith(".blacklist")) {
    if (!_isAdminUser(message.author.id)) {
      await safeReply(message, "Only admin can use this command.");
      return;
    }
    const args = content.split(/\s+/).slice(1);
    if (args.length < 1) {
      await safeReply(message, "Usage: .blacklist <user_id/@user/username> [reason]");
      return;
    }
    const userInput = args[0];
    const userId = await parseUserId(userInput, message);
    if (!userId) {
      await safeReply(message, "Could not find user. Please provide a valid ID, mention, or username.");
      return;
    }
    let username = null;
    try {
      const user = await client.users.fetch(userId);
      username = user.tag;
    } catch { username = userInput; }
    const reason = args.slice(1).join(" ");
    const success = await addToBlacklist(userId, reason, client, username);
    const reply = success
      ? `User <@${userId}> has been blacklisted.`
      : `Failed to add user to blacklist.`;
    await safeReply(message, reply);
    return;
  }

  if (lower.startsWith("!unblacklist") || lower.startsWith(".unblacklist")) {
    if (!_isAdminUser(message.author.id)) {
      await safeReply(message, "Only admin can use this command.");
      return;
    }
    const args = content.split(/\s+/).slice(1);
    if (args.length < 1) {
      await safeReply(message, "Usage: .unblacklist <user_id/@user/username>");
      return;
    }
    const userId = await parseUserId(args[0], message);
    if (!userId) {
      await safeReply(message, "Could not find user. Please provide a valid ID, mention, or username.");
      return;
    }
    const success = removeFromBlacklist(userId);
    const reply = success
      ? `User <@${userId}> has been removed from blacklist.`
      : `User is not blacklisted or failed to remove.`;
    await safeReply(message, reply);
    return;
  }

  if (message.reference) {
    const preset = getPreset(lower);
    if (!preset) return;

    if (blacklistedUsers.has(message.author.id)) {
      await safeReply(message, `You are blacklisted. Reason: ${blacklistedUsers.get(message.author.id).reason}`);
      return;
    }

    const cooldownRemaining = checkCooldown(message.author.id);
    if (cooldownRemaining) {
      await safeReply(message, `You're currently on cooldown! Please wait ${cooldownRemaining}s`);
      return;
    }

    let requiresCredit_reply = CREDIT_REQUIRED_PRESETS.has(preset);
    if (requiresCredit_reply) {
      const member_reply = message.guild
        ? await message.guild.members.fetch(message.author.id).catch(() => null)
        : null;
      if (!await hasUnlimitedCreditsGlobal(message.author.id, client, member_reply)) {
        const credits_reply = getUserCredits(message.author.id);
        if (credits_reply <= 0) {
          await safeReply(message, `You need at least 1 credit to use this command.`);
          return;
        }
      } else {
        requiresCredit_reply = false;
      }
    }

    try {
      const replied = await message.channel.messages.fetch(message.reference.messageId);
      const attachment = replied.attachments.first();
      const fileUrl = attachment?.url;
      const originalFileName = attachment?.name;
      const match = replied.content.match(CODE_BLOCK_PATTERN);

      if (attachment && attachment.size > MAX_INPUT_SIZE) { await safeReply(message, "Replied file too large (Max 2MB)"); return; }
      if (match && Buffer.byteLength(match[1]) > MAX_INPUT_SIZE) { await safeReply(message, "Replied code too long (Max 2MB)"); return; }
      if (!fileUrl && !match) { await safeReply(message, "No file or code block in replied message."); return; }

      setCooldown(message.author.id);

      await handleWithEmoji(message, async (loadingMsg) => {
        let tmpFile, sourceInfo, codeContent = null, fileName = null;

        if (fileUrl) {
          try {
            tmpFile = await downloadFile(fileUrl);
            sourceInfo = originalFileName || fileUrl;
            fileName = originalFileName;
          } catch (err) {
            console.error(err);
            if (err.response?.status === 404 || err.code === 'ENOTFOUND') {
              await loadingMsg.edit(`${message.author}\`\`\`Do not delete files while the bot is processing\`\`\``);
              return;
            }
            throw err;
          }
        } else {
          const code = match[1].trim();
          tmpFile = createTempFile(code);
          sourceInfo = "Code block (Reply)";
          codeContent = code;
        }

        const onSuccessCb = requiresCredit_reply ? () => deductCredit(message.author.id) : null;
        await processObf(message, tmpFile, preset, sourceInfo, codeContent, client, fileName, false, loadingMsg, onSuccessCb);
      });
    } catch (err) {
      console.error(err);
      await safeReply(message, `\`\`\`Error: ${filterError(err.message)}\`\`\``);
    }
    return;
  }

  const preset = getPreset(lower);
  if (!preset) return;

  if (blacklistedUsers.has(message.author.id)) {
    await safeReply(message, `You are blacklisted. Reason: ${blacklistedUsers.get(message.author.id).reason}`);
    return;
  }

  const cooldownRemaining = checkCooldown(message.author.id);
  if (cooldownRemaining) {
    await safeReply(message, `You're currently on cooldown! Please wait ${cooldownRemaining}s`);
    return;
  }

  let requiresCredit = CREDIT_REQUIRED_PRESETS.has(preset);
  if (requiresCredit) {
    const member = message.guild
      ? await message.guild.members.fetch(message.author.id).catch(() => null)
      : null;
    if (!await hasUnlimitedCreditsGlobal(message.author.id, client, member)) {
      const credits = getUserCredits(message.author.id);
      if (credits <= 0) {
        await safeReply(message, `You need at least 1 credit to use this command.`);
        return;
      }
    } else {
      requiresCredit = false;
    }
  }

  const attachment = message.attachments.first();
  const fileUrl = attachment?.url;
  const originalFileName = attachment?.name;
  const match = content.match(CODE_BLOCK_PATTERN);

  if (attachment && attachment.size > MAX_INPUT_SIZE) { await safeReply(message, "File too large (Max 2MB)"); return; }
  if (match && Buffer.byteLength(match[1]) > MAX_INPUT_SIZE) { await safeReply(message, "Code too long (Max 2MB)"); return; }
  if (!fileUrl && !match) { await safeReply(message, "Please attach a file or provide a code block."); return; }

  setCooldown(message.author.id);

  await handleWithEmoji(message, async (loadingMsg) => {
    try {
      let tmpFile, sourceInfo, codeContent = null, fileName = null;

      if (fileUrl) {
        try {
          tmpFile = await downloadFile(fileUrl);
          sourceInfo = originalFileName || fileUrl;
          fileName = originalFileName;
        } catch (err) {
          console.error(err);
          if (err.response?.status === 404 || err.code === 'ENOTFOUND') {
            await loadingMsg.edit(`${message.author}\`\`\`Do not delete files while the bot is processing\`\`\``);
            return;
          }
          throw err;
        }
      } else {
        const code = match[1].trim();
        tmpFile = createTempFile(code);
        sourceInfo = "Code block";
        codeContent = code;
      }

      const onSuccessCb = requiresCredit ? () => deductCredit(message.author.id) : null;
      await processObf(message, tmpFile, preset, sourceInfo, codeContent, client, fileName, false, loadingMsg, onSuccessCb);
    } catch (err) {
      console.error(err);
      await loadingMsg.edit(`\`\`\`Error: ${filterError(err.message)}\`\`\``);
    }
  });
});

client.login(process.env.DISCORD_TOKEN);
console.log("Bot is starting...");