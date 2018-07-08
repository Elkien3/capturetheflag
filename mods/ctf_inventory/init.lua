local items = {
	minetest.colorize("#66a0ff", "Game Play"),
	"",
	"*  Capture an enemy's flag by walking up to it, punching it, then",
	"   running and punching your team's flag.",
	"*  Rightclick your flag to open the class menu",
	"*  You have to wait 2 minutes after selecting a class to resupply or change class.",
	"*  Healers punch other players with bandage to heal them.",
	"*  Gain more score by killing more than you die, or by capturing the flag.",
	"*  Players are immune for 10 seconds after they respawn.",
	"*  Different classes have different jobs to do, don't be scared to try.",
	"   different classes.",
	"",

	minetest.colorize("#66a0ff", "Team Co-op"),
	"",
	"*  You can change class or resupply at your flag",
	"*  Your team name is displayed in the top left.",
	"   to talk with only your team, type: /t message",
	"",

	minetest.colorize("#66a0ff", "Player Rankings"),
	"",
	"*  See the league table by typing /rankings",
	"*  See your position in it by typing /rankings me",
	"*  Get to the top by capturing lots of flags, and having a high K/D ratio.",
	"",

	minetest.colorize("#66a0ff", "Contact Moderators"),
	"",
	"*  Report people who sabotage using /report."
}
for i = 1, #items do
	items[i] = minetest.formspec_escape(items[i])
end

local fs = [[
		textlist[0,0;7.85,8.5;help;
	]] .. table.concat(items, ",") .. "]"

sfinv.register_page("ctf_inventory:help", {
	title = "Help",
	get = function(self, player, context)
		return sfinv.make_formspec(player, context, fs, false)
	end
})
