Statistics g_stats;

UI::Font@ g_fontBold;

void RenderStat(const string &in icon, const string &in name, const string &in value)
{
	UI::Text(icon + " " + name); UI::NextColumn();
	UI::Text(value); UI::NextColumn();
}

void RenderMenu()
{
	UI::SetNextWindowContentSize(300, 0);
	if (UI::BeginMenu("\\$9cf" + Icons::LineChart + "\\$z Statistics")) {
		UI::Columns(2, "statistics");

		UI::PushFont(g_fontBold);
		UI::Text("Statistic"); UI::NextColumn();
		UI::Text("Value"); UI::NextColumn();
		UI::PopFont();

		UI::Separator();
		RenderStat(Icons::ClockO, "Total time", Time::Format(g_stats.TotalTime * 1000, false));
		RenderStat(Icons::ClockO, "Solo time", Time::Format(g_stats.SoloTime * 1000, false));
		RenderStat(Icons::ClockO, "Online time", Time::Format(g_stats.OnlineTime * 1000, false));

		UI::Separator();
		RenderStat(Icons::ClockO, "Map editor time", Time::Format(g_stats.MapEditorTime * 1000, false));
		RenderStat(Icons::ClockO, "Map editor test time", Time::Format(g_stats.MapEditorTestTime * 1000, false));
#if TMNEXT
		UI::Separator();
		RenderStat(Icons::ClockO, "Skin editor time", Time::Format(g_stats.SkinEditorTime * 1000, false));
#endif
		UI::Separator();
		RenderStat(Icons::ClockO, "Mediatracker time", Time::Format(g_stats.MediaTrackerTime * 1000, false));

		UI::Columns(1);
		UI::EndMenu();
	}
}

void OnDestroyed()
{
	g_stats.Save();
}

void Main()
{
	auto app = GetApp();

	@g_fontBold = UI::LoadFont("DroidSans-Bold.ttf");

	g_stats.Load();

	int saveTimer = 0;
	while (true) {
		g_stats.TotalTime++;

		auto serverInfo = cast<CGameCtnNetServerInfo>(app.Network.ServerInfo);
		if (serverInfo !is null && serverInfo.ServerLogin != "") {
			g_stats.OnlineTime++;
#if TMNEXT || MP4
		} else if (app.RootMap !is null && app.Editor is null) {
			g_stats.SoloTime++;
#elif TURBO
		} else if (app.Challenge !is null && app.Editor is null) {
			g_stats.SoloTime++;
#endif
		}

		if (app.Editor !is null) {
			if (cast<CGameCtnEditorFree>(app.Editor) !is null) {
				g_stats.MapEditorTime++;
				if (app.CurrentPlayground !is null) {
					g_stats.MapEditorTestTime++;
				}
#if TMNEXT
			} else if (cast<CGameEditorSkin>(app.Editor) !is null) {
				g_stats.SkinEditorTime++;
			} else if (cast<CGameEditorMediaTracker>(app.Editor) !is null) {
				g_stats.MediaTrackerTime++;
#else
			} else if (cast<CGameCtnMediaTracker>(app.Editor) !is null) {
				g_stats.MediaTrackerTime++;
#endif
			}
		}

		saveTimer++;
		if (saveTimer >= 60) {
			g_stats.Save();
			saveTimer = 0;
		}

		sleep(1000);
	}
}
