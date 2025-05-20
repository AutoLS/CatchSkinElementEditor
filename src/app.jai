App_Settings :: struct 
{
    fruit_scale: float = 1.0;
    catcher_scale: float = 1.0;
    enable_lane_cover: bool;
    lane_cover_scale: float = 1.0;
}

app_ui :: (using app_settings: *App_Settings, using asset_storage: *Asset_Storage)
{
    ImGui.PushItemWidth(200);
    ImGui.SliderFloat("Edit fruit scale", *fruit_scale, 0.1, 5, "%.1f");
    ImGui.PopItemWidth();

    ImGui.PushItemWidth(200);
    ImGui.SliderFloat("Edit catcher scale", *catcher_scale, 0.1, 5, "%.1f");
    ImGui.PopItemWidth();

    ImGui.Checkbox("Enable lane cover", *enable_lane_cover);

    if enable_lane_cover
    {
        ImGui.PushItemWidth(200);
        ImGui.SliderFloat("Edit lane cover scale", *lane_cover_scale, 0.1, 5, "%.1f");
        ImGui.PopItemWidth();
    }
    
    ImGui.Separator();

    ImGui.Text("Preview");
    ImGui.BeginChild("Preview", .{385, 250}, true, IMGUI_WINDOW_FLAGS.AlwaysVerticalScrollbar | IMGUI_WINDOW_FLAGS.AlwaysHorizontalScrollbar);

    fruit := table_find_pointer(*asset_table, .fruit_apple);
    catcher := table_find_pointer(*asset_table, .fruit_catcher_idle);
    
    fruit_new_w := 64 * fruit_scale;
    fruit_new_h := 64 * fruit_scale;
    catcher_new_w := 128 * catcher_scale;
    catcher_new_h := 128 * catcher_scale;
    ImGui.Image(cast(*void)fruit.texture, ImGui.ImVec2.{fruit_new_w, fruit_new_h});
    ImGui.Image(cast(*void)catcher.texture, ImGui.ImVec2.{catcher_new_w, catcher_new_h});

    ImGui.EndChild();
}