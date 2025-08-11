#import "File";

App_Settings :: struct 
{
    name: *u8;
    fruit_scale: float = 1.0;
    catcher_scale: float = 1.0;
    enable_lane_cover: bool;
    lane_cover_height: s32 = 200;

    output_directory: string;
    assets_loaded: bool;
    actual_preview: bool;
}

lane_cover_settings :: (using app_settings: *App_Settings)
{
    ImGui.Checkbox("Generate lane cover", *enable_lane_cover);

    if enable_lane_cover
    {
        ImGui.PushItemWidth(200);
        if ImGui.InputInt("Edit Height (in pixels)", *lane_cover_height, 5, 10)
        {
            Clamp(*lane_cover_height, 50, 1366);
        }
        ImGui.PopItemWidth();
    }
}

app_ui :: (using app_settings: *App_Settings, using asset_storage: *Asset_Storage)
{
    ImGui.PushItemWidth(200);
    ImGui.InputText("Output Name", name, 32);
    ImGui.PopItemWidth();
    ImGui.PushItemWidth(200);
    ImGui.InputFloat("Edit fruit scale", *fruit_scale, 0.1, 0.5, "%.2f");
    Clamp(*fruit_scale, cast(float)0.1, cast(float)5.0);
    ImGui.PopItemWidth();

    ImGui.PushItemWidth(200);
    ImGui.InputFloat("Edit catcher scale", *catcher_scale, 0.1, 0.5, "%.2f");
    Clamp(*catcher_scale, cast(float)0.1, cast(float)5.0);
    ImGui.PopItemWidth();

    lane_cover_settings(app_settings);
    
    ImGui.Separator();

    ImGui.Text("Simple Preview");
    ImGui.Checkbox("Actual Size", *actual_preview);
    
    ImGui.BeginChild("Preview", .{385, 325}, true, IMGUI_WINDOW_FLAGS.AlwaysVerticalScrollbar | IMGUI_WINDOW_FLAGS.AlwaysHorizontalScrollbar);

    fruit := table_find_pointer(*asset_table, .fruit_apple);
    catcher := table_find_pointer(*asset_table, .fruit_catcher_idle);
    
    fruit_new_w: float;
    fruit_new_h: float;
    catcher_new_w: float;
    catcher_new_h: float;

    if actual_preview
    {
        fruit_new_w = fruit.width * fruit_scale;
        fruit_new_h = fruit.height * fruit_scale;
        catcher_new_w = catcher.width * catcher_scale;
        catcher_new_h = catcher.height * catcher_scale;
    }
    else
    {
        fruit_new_w = 64 * fruit_scale;
        fruit_new_h = 64 * fruit_scale;
        catcher_new_w = 98 * catcher_scale;
        catcher_new_h = 98 * catcher_scale;
    }

    ImGui.Image(cast(*void)fruit.texture, ImGui.ImVec2.{fruit_new_w, fruit_new_h});
    ImGui.Image(cast(*void)catcher.texture, ImGui.ImVec2.{catcher_new_w, catcher_new_h});
    
    ImGui.EndChild();
}

export :: (settings: *App_Settings, asset_storage: *Asset_Storage) -> bool
{
    name := to_string(settings.name);
    if name.count == 0
    {
        name = "default";
    }

    if settings.output_directory
    {
        free(settings.output_directory);
    }

    settings.output_directory = copy_string(tprint("output/%", name));
    make_directory_if_it_does_not_exist("output");
    make_directory_if_it_does_not_exist(settings.output_directory);
    for i : 0 .. enum_highest_value(Asset_Name)
    {
        asset_enum := cast(Asset_Name)i;
        asset := table_find_pointer(*asset_storage.asset_table, asset_enum);
        scale: float;

        if asset_enum == 
        {
            case .fruit_catcher_fail; #through;
            case .fruit_catcher_idle; #through;
            case .fruit_catcher_kiai;
            {
                scale = settings.catcher_scale;
            }
            case;
            {                
                scale = settings.fruit_scale;
            }
        }

        new_width: s32 = cast(s32)(asset.width * scale);
        new_height: s32 = cast(s32)(asset.height * scale);
        resized_image_data := alloc(new_width * new_height * asset.channels);

        result := stbir_resize_uint8(asset.data, asset.width, asset.height, 0, resized_image_data, new_width, new_height, 0, asset.channels);

        if !result
        {
            free(resized_image_data);
            return false;
        }

        image_output_path := tprint("%/%", settings.output_directory, asset.file_name);
        stbi_write_png(temp_c_string(image_output_path), new_width, new_height, asset.channels, resized_image_data, new_width * asset.channels);

        free(resized_image_data);
    }

    if settings.enable_lane_cover
    {
        image_width: s32 = 1366;
        image_height: s32 = 786;
        scorebar_bg_image := create_transparent_image(image_width, image_height);
        
        rect_x: s32 = 216;
        rect_y: s32 = 0;
        rect_w: s32 = 934;
        fill_rectangle_at_position(scorebar_bg_image, .{0, 0, 0}, image_width, image_height, rect_x, rect_y, rect_w, settings.lane_cover_height);

        image_output_path := tprint("%/scorebar-bg.png", settings.output_directory);
        stbi_write_png(temp_c_string(image_output_path), image_width, image_height, 4, scorebar_bg_image, image_width * 4);

        free(scorebar_bg_image);
    }

    return true;
}