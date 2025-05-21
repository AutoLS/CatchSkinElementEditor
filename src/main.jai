#import "Basic";
#import "GL";
#import "AutoLib";
#import "Windows";
#import "stb_image";
#import "stb_image_resize";
#import "stb_image_write";
#load "asset.jai";
#load "app.jai";

main :: ()
{
    app: Application;
    app.name = "SkinElementEditor";
    app.w = 400;
    app.h = 500;

    init_lib(*app, false);

    main_tool_active: bool;

    asset_storage: Asset_Storage;
    load_skin_assets(*asset_storage);

    app_settings: App_Settings;
    app_settings.name = alloc(32);
    memset(app_settings.name, 0, 32);

    export_popup := false;

    while app.running
    {
        reset_temporary_storage();
        handle_events(*app);
        clear_window(*app);

        //Logic
        if app.is_quit
        {
            app.running = false;
        }

        is_new_file := false;
		is_open_file := false;
		is_save_file := false;
        is_export := false;
		
		ImGui.Begin("Main", *main_tool_active, 
					IMGUI_WINDOW_FLAGS.NoTitleBar |
					IMGUI_WINDOW_FLAGS.MenuBar | 
					IMGUI_WINDOW_FLAGS.NoMove |
					IMGUI_WINDOW_FLAGS.NoResize |
					IMGUI_WINDOW_FLAGS.NoBackground);

		if ImGui.BeginMenuBar()
		{
			defer ImGui.EndMenuBar();
			if ImGui.BeginMenu("File")
			{
				defer ImGui.EndMenu();
				// is_new_file = ImGui.MenuItem("New", "Ctrl+N");

				// is_open_file = ImGui.MenuItem("Open..", "Ctrl+O");

				// is_save_file = ImGui.MenuItem("Save", "Ctrl+S");

				is_export = ImGui.MenuItem("Export", "");
			}
			// if ImGui.BeginMenu("Menu")
			// {
			// 	defer ImGui.EndMenu();
			// }
		}

        //handle_file_action(*app, is_new_file, is_open_file, is_save_file);

        app_ui(*app_settings, *asset_storage);

        if is_export
        {
            export_popup = export(*app_settings, *asset_storage);
        }

        if export_popup
        {
            ImGui.OpenPopup("Success");
            
            ImGui.SetNextWindowSize(.{300, 0}, ImGui.Cond.Always);
            ImGui.SetNextWindowPos(.{app.w*0.5, app.h*0.5}, ImGui.Cond.Appearing, .{0.5, 0.5});
            if ImGui.BeginPopupModal("Success", null, IMGUI_WINDOW_FLAGS.AlwaysAutoResize)
            {
                defer ImGui.EndPopup();

                ImGui.PushTextWrapPos(400);
                ImGui.TextUnformatted("Exported successfully, would you like to open the output director?");
                ImGui.PopTextWrapPos();

                ImGui.Separator();

                if ImGui.Button("YES")
                {
                    path := get_absolute_path(app_settings.output_directory);
                    print("Path: %\n", path);
                    ImGui.CloseCurrentPopup();
                    ShellExecuteA(null, "open", temp_c_string(path), null, null, SW_SHOWDEFAULT);
                    export_popup = false;
                }
                ImGui.SameLine();
                if ImGui.Button("NO")
                {
                    ImGui.CloseCurrentPopup();
                    export_popup = false;
                }
            }
        }

        ImGui.End();

        lock_fps(*app.clock, 60);

        draw_frame(*app);

        update_clock(*app.clock);
    }
}