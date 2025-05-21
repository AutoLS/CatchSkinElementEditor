create_transparent_image :: (width: s32, height: s32) -> *u8
{
    pixels := cast(*u8)alloc(width * height * 4);

    for i : 0 .. (width * height)-1 
    {
        pixels[i * 4] = 0;
        pixels[i * 4 + 1] = 0;
        pixels[i * 4 + 2] = 0;
        pixels[i * 4 + 3] = 0;
    } 

    return pixels;
}

fill_rectangle_at_position :: (pixels: *u8, color: Vector3, image_w: s32, image_h: s32, rect_x: s32, rect_y: s32, rect_w: s32, rect_h: s32)
{
    x_end := ifx rect_x + rect_w > image_w then image_w else rect_x + rect_w;
    y_end := ifx rect_y + rect_h > image_h then image_h else rect_y + rect_h;

    r: u8 = cast(u8)(255 * color.x); 
    g: u8 = cast(u8)(255 * color.y); 
    b: u8 = cast(u8)(255 * color.z); 
    for y : rect_y .. y_end-1 
    {
        for x : rect_x .. x_end-1
        {
            i := (y * image_w + x) * 4; //ARGB
            pixels[i + 0] = r;
            pixels[i + 1] = g;
            pixels[i + 2] = b;
            pixels[i + 3] = 255;
        }
    }
}