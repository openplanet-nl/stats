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

bool InMap()
{
#if MP41 || TMNEXT
	return GetApp().RootMap !is null;
#else
	return GetApp().Challenge !is null;
#endif
}

bool InMapEditor()
{
#if FOREVER
	auto app = cast<CTrackMania>(GetApp());
	return cast<CTrackManiaEditorCatalog>(app.Editor) !is null;
#else
	return cast<CGameCtnEditorFree>(GetApp().Editor) !is null;
#endif
}

bool InMediaTracker()
{
#if !TMNEXT
	auto app = cast<CTrackMania>(GetApp());
	return cast<CGameCtnMediaTracker>(app.Editor) !is null;
#else
	return cast<CGameEditorMediaTracker>(GetApp().Editor) !is null;
#endif
}

bool InServer()
{
	auto serverInfo = cast<CGameCtnNetServerInfo>(GetApp().Network.ServerInfo);
#if FOREVER
	return serverInfo !is null && serverInfo.ServerHostName != "";
#else
	return serverInfo !is null && serverInfo.ServerLogin != "";
#endif
}

void Main()
{
	auto app = cast<CTrackMania>(GetApp());

	@g_fontBold = UI::LoadFont("DroidSans-Bold.ttf");

	g_stats.Load();

	int saveTimer = 0;
	while (true) {
		g_stats.TotalTime++;

		if (InServer()) {
			g_stats.OnlineTime++;
		} else if (InMap() && !InMapEditor()) {
			g_stats.SoloTime++;
		}

		if (app.Editor !is null) {
			if (InMapEditor()) {
				g_stats.MapEditorTime++;
				if (app.CurrentPlayground !is null) {
#if TURBO
					if (app.CurrentPlayground.GameTerminals.Length > 0) {
#endif
						g_stats.MapEditorTestTime++;
#if TURBO
					}
#endif
				}

#if TMNEXT
			} else if (cast<CGameEditorSkin>(app.Editor) !is null) {
				g_stats.SkinEditorTime++;
#endif

			} else if (InMediaTracker()) {
				g_stats.MediaTrackerTime++;
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
