class Statistics
{
	uint64 TotalTime = 0;
	uint64 SoloTime = 0;
	uint64 OnlineTime = 0;

	uint64 MapEditorTime = 0;
	uint64 MapEditorTestTime = 0;

	uint64 SkinEditorTime = 0;

	uint64 MediaTrackerTime = 0;

	string GetPath()
	{
		return IO::FromDataFolder("Stats.json");
	}

	void Load()
	{
		auto js = Json::FromFile(GetPath());
		if (js.GetType() == Json::Type::Null) {
			print("No data found in Stats.json file. Starting fresh!");
			return;
		}
		TotalTime = Text::ParseUInt64(js.Get("totaltime", Json::Value("0")));
		SoloTime = Text::ParseUInt64(js.Get("solotime", Json::Value("0")));
		OnlineTime = Text::ParseUInt64(js.Get("onlinetime", Json::Value("0")));
		MapEditorTime = Text::ParseUInt64(js.Get("mapeditortime", Json::Value("0")));
		MapEditorTestTime = Text::ParseUInt64(js.Get("mapeditortesttime", Json::Value("0")));
		SkinEditorTime = Text::ParseUInt64(js.Get("skineditortime", Json::Value("0")));
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
		js["skineditortime"] = Text::Format("%lld", SkinEditorTime);
		js["mediatrackertime"] = Text::Format("%lld", MediaTrackerTime);
		Json::ToFile(GetPath(), js);
	}
}
