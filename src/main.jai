#import "Basic";
#import "GL";
#import "AutoLib";
#import "Windows";
#import "stb_image";
#import "stb_image_resize";
#import "stb_image_write";
#load "file.jai";
#load "app.jai";

main :: ()
{
    app: Application;
    app.name = "SkinElementEditor";
    app.w = 400;
    app.h = 400;

    init_lib(*app, false);

    main_tool_active: bool;

    asset_storage: Asset_Storage;
    load_skin_assets(*asset_storage);

    app_settings: App_Settings;

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
				is_new_file = ImGui.MenuItem("New", "Ctrl+N");

				is_open_file = ImGui.MenuItem("Open..", "Ctrl+O");

				is_save_file = ImGui.MenuItem("Save", "Ctrl+S");
			}
			// if ImGui.BeginMenu("Menu")
			// {
			// 	defer ImGui.EndMenu();
			// }
		}

        handle_file_action(*app, is_new_file, is_open_file, is_save_file);

        app_ui(*app_settings, *asset_storage);

        ImGui.End();

        lock_fps(*app.clock, 60);

        draw_frame(*app);

        update_clock(*app.clock);
    }
}