#import "Reflection";
#import "Hash_Table";
#import "String";

Asset_Name :: enum u32
{
    fruit_catcher_fail;
    fruit_catcher_idle;
    fruit_catcher_kiai;
    fruit_apple;
    fruit_apple_overlay;
    fruit_drop;
    fruit_grapes;
    fruit_grapes_overlay;
    fruit_orange;
    fruit_orange_overlay;
    fruit_pear;
    fruit_pear_overlay;
}

Asset :: struct
{
    type: Asset_Name;
    name: string;
    file_name: string;

    data: *u8;
    width: s32;
    height: s32;
    channels: s32;

    texture: u32;
}

Asset_Storage :: struct
{
    asset_table: Table(Asset_Name, Asset);
}

load_skin_assets :: (using asset_storage: *Asset_Storage)
{
    for i : 0 .. enum_highest_value(Asset_Name)
    {
        asset_enum := cast(Asset_Name)i;
        
        asset: Asset;
        asset.type = asset_enum;
        asset.name = copy_string(enum_value_to_name(asset_enum));
        replace_chars(asset.name, "_", 45); //NOTE: 45 is the ascii code for '-'
        asset.file_name = join(asset.name, ".png");
        file_path := tprint("assets/%", asset.file_name);
        asset.data = stbi_load(temp_c_string(file_path), *asset.width, *asset.height, *asset.channels, 0);

        if asset.data
        {
            asset.texture = gl_load_texture(temp_c_string(file_path), true);
            table_add(*asset_table, asset.type, asset); 
            print("File loaded: %\n", asset.file_name);       
        }
    }
}
