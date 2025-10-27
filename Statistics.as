class Statistics
{
	uint64 TotalTime = 0;
	uint64 SoloTime = 0;
	uint64 OnlineTime = 0;

	uint64 MapEditorTime = 0;
	uint64 MapEditorTestTime = 0;

#if !FOREVER && !TURBO
	uint64 SkinEditorTime = 0;
#endif

	uint64 MediaTrackerTime = 0;

	string GetPath()
	{
		return IO::FromStorageFolder("Stats.json");
	}

	void CheckForLegacyPath()
	{
		// Check if Stats.json exists in the user's own folder. If it does, move it to PluginStorage.
		string legacyPath = IO::FromDataFolder("Stats.json");
		if (IO::FileExists(legacyPath)) {
			warn("Migrating Stats.json from user folder to PluginStorage!");
			IO::Move(legacyPath, GetPath());
		}
	}

	void Load()
	{
		string path = GetPath();

		if (!IO::FileExists(path)) {
			CheckForLegacyPath();
		}

		auto js = Json::FromFile(path);
		if (js.GetType() == Json::Type::Null) {
			print("No data found in Stats.json file. Starting fresh!");
			return;
		}
		TotalTime = Text::ParseUInt64(js.Get("totaltime", Json::Value("0")));
		SoloTime = Text::ParseUInt64(js.Get("solotime", Json::Value("0")));
		OnlineTime = Text::ParseUInt64(js.Get("onlinetime", Json::Value("0")));
		MapEditorTime = Text::ParseUInt64(js.Get("mapeditortime", Json::Value("0")));
		MapEditorTestTime = Text::ParseUInt64(js.Get("mapeditortesttime", Json::Value("0")));
#if !FOREVER && !TURBO
		SkinEditorTime = Text::ParseUInt64(js.Get("skineditortime", Json::Value("0")));
#endif
		MediaTrackerTime = Text::ParseUInt64(js.Get("mediatrackertime", Json::Value("0")));
	}

	void Save()
	{
		auto js = Json::Object();
		js["totaltime"] = Text::Format("%lld", TotalTime);
		js["solotime"] = Text::Format("%lld", SoloTime);
		js["onlinetime"] = Text::Format("%lld", OnlineTime);
		js["mapeditortime"] = Text::Format("%lld", MapEditorTime);
		js["mapeditortesttime"] = Text::Format("%lld", MapEditorTestTime);
#if !FOREVER && !TURBO
		js["skineditortime"] = Text::Format("%lld", SkinEditorTime);
#endif
		js["mediatrackertime"] = Text::Format("%lld", MediaTrackerTime);
		Json::ToFile(GetPath(), js);
	}
}
