##############################################################################
#  function for conversion to image
##############################################################################

"""
Initializes `wkhtmltoimage` in graphics less mode `img_init(0)` or not
`img_init(1)`
"""
function img_init(usegraphics::Int)
  ccall((:wkhtmltoimage_init, libwkhtml),
        Int, (Int,), usegraphics)
end

"""
Closes `wkhtmltoimage`
"""
function img_deinit()
  ccall((:wkhtmltoimage_deinit, libwkhtml),
        Int, ())
end


### Global settings ###

"""
Sets the output parameters by passing pairs `"property" => "values"` (both should be String).

example:
```julia
ps = ImgSettings("out" => "/tmp/example.pdf",
                 "orientation" => "Landscape")
```

##Parameters :

- **crop.left** left/x coordinate of the window to capture in pixels. E.g. "200"
- **crop.top** top/y coordinate of the window to capture in pixels. E.g. "200"
- **crop.width** Width of the window to capture in pixels. E.g. "200"
- **crop.height** Height of the window to capture in pixels. E.g. "200"
- **load.cookieJar** Path of file used to load and store cookies.
- **load.* Page specific settings related to loading content, see Object Specific loading settings.
- **web.* See Web page specific settings.
- **transparent** When outputting a PNG or SVG, make the white background transparent. Must be either "true" or "false"
- **in** The URL or path of the input file, if "-" stdin is used. E.g. "http://google.com"
- **out** The path of the output file, if "-" stdout is used, if empty the content is stored to a internalBuffer.
- **fmt** The output format to use, must be either "", "jpg", "png", "bmp" or "svg".
- **screenWidth** The with of the screen used to render is pixels, e.g "800".
- **smartWidth** Should we expand the screenWidth if the content does not fit? must be either "true" or "false".
- **quality** The compression factor to use when outputting a JPEG image. E.g. "94".

##Web page specific settings

- **web.background** Should we print the background? Must be either "true" or "false".
- **web.loadImages** Should we load images? Must be either "true" or "false".
- **web.enableJavascript** Should we enable javascript? Must be either "true" or "false".
- **web.enableIntelligentShrinking** Should we enable intelligent shrinkng to fit more content on one page? Must be either "true" or "false". Has no effect for wkhtmltoimage.
- **web.minimumFontSize** The minimum font size allowed. E.g. "9"
- **web.printMediaType** Should the content be printed using the print media type instead of the screen media type. Must be either "true" or "false". Has no effect for wkhtmltoimage.
- **web.defaultEncoding** What encoding should we guess content is using if they do not specify it properly? E.g. "utf-8"
- **web.userStyleSheet** Url er path to a user specified style sheet.
- **web.enablePlugins** Should we enable NS plugins, must be either "true" or "false". Enabling this will have limited success.

##Object Specific loading settings

- **load.username** The user name to use when loging into a website, E.g. "bart"
- **load.password** The password to used when logging into a website, E.g. "elbarto"
- **load.jsdelay** The mount of time in milliseconds to wait after a page has done loading until it is actually printed. E.g. "1200". We will wait this amount of time or until, javascript calls window.print().
- **load.zoomFactor** How much should we zoom in on the content? E.g. "2.2".
- **load.customHeaders** TODO
- **load.repertCustomHeaders** Should the custom headers be sent all elements loaded instead of only the main page? Must be either "true" or "false".
- **load.cookies** TODO
- **load.post** TODO
- **load.blockLocalFileAccess** Disallow local and piped files to access other local files. Must be either "true" or "false".
- **load.stopSlowScript** Stop slow running javascript. Must be either "true" or "false".
- **load.debugJavascript** Forward javascript warnings and errors to the warning callback. Must be either "true" or "false".
- **load.loadErrorHandling** How should we handle obejcts that fail to load. Must be one of:
  - **"abort"** Abort the convertion process
  - **"skip"** Do not add the object to the final output
  - **"ignore"** Try to add the object to the final output.
- **load.proxy** String describing what proxy to use when loading the object.
- **load.runScript** TODO

##Header and footer settings

The same settings can be applied for headers and footers, here there are explained in terms of the header.

- **header.fontSize** The font size to use for the header, e.g. "13"
- **header.fontName** The name of the font to use for the header. e.g. "times"
- **header.left** The string to print in the left part of the header, note that some sequences are replaced in this string, see the wkhtmltopdf manual.
- **header.center** The text to print in the center part of the header.
- **header.right** The text to print in the right part of the header.
- **header.line** Whether a line should be printed under the header (either "true" or "false").
- **header.spacing** The amount of space to put between the header and the content, e.g. "1.8". Be aware that if this is too large the header will be printed outside the pdf document. This can be corrected with the margin.top setting.
- **header.htmlUrl** Url for a HTML document to use for the header.

"""
type ImgSettings
  ptr::Ptr{GlobalSettings}
end

# 0 arg case
ImgSettings() = ImgSettings(img_create_global_settings())

# >= 1 case
function ImgSettings(p1::Pair{String,String}, args...)
  ptr = img_create_global_settings()

  img_set_global_setting(ptr, p1.first, p1.second)
  for p in args
    isa(p, Pair{String,String}) || error("argument $p is not Pair{String,String}")
    img_set_global_setting(ptr, p.first, p.second)
  end

  ImgSettings(ptr)
end

function setindex!(settings::ImgSettings, value::String, property::String)
  img_set_global_setting(settings.ptr, property, value)
end

function getindex(settings::ImgSettings, property::String)
  img_get_global_setting(settings.ptr, property)
end

function img_create_global_settings()
  ccall((:wkhtmltoimage_create_global_settings, libwkhtml),
        Ptr{GlobalSettings}, ())
end

function img_get_global_setting(gs::Ptr{GlobalSettings}, property::String)
  cval = zeros(UInt8, 100)
  ccall((:wkhtmltoimage_get_global_setting, libwkhtml),
        Int,
        (Ptr{GlobalSettings}, Cstring, Cstring, Int),
        gs, convert(Cstring, pointer(property)),
            convert(Cstring, pointer(cval)), sizeof(cval)-1 )
  unsafe_string(pointer(cval))
end

function img_set_global_setting(gs::Ptr{GlobalSettings}, property::String, value::String)
  ccall((:wkhtmltoimage_set_global_setting, libwkhtml),
        Int,
        (Ptr{GlobalSettings}, Cstring, Cstring),
        gs,
        convert(Cstring, pointer(property)),
        convert(Cstring, pointer(value)) )
end

### conversion ###

type ImgConverter
  ptr::Ptr{Converter}
end

function ImgConverter(settings::ImgSettings)
  obj = ImgConverter(img_create_converter(settings.ptr))

  finalizer(obj, o -> img_destroy_converter(o.ptr))

  obj
end

function run(conv::ImgConverter)
  img_wkconvert(conv.ptr)
end

function img_create_converter(gs::Ptr{GlobalSettings})
  ccall((:wkhtmltoimage_create_converter, libwkhtml),
        Ptr{Converter},
        (Ptr{GlobalSettings}, Cstring),
        gs, C_NULL )
end

function img_destroy_converter(conv::Ptr{Converter})
  ccall((:wkhtmltoimage_destroy_converter, libwkhtml),
        Void,
        (Ptr{Converter},),
        conv )
end

function img_wkconvert(conv::Ptr{Converter})
  ccall((:wkhtmltoimage_convert, libwkhtml),
        Int, (Ptr{Converter},), conv )
end

function img_add_object(conv::Ptr{Converter}, os::Ptr{ObjectSettings},
                    data::Union{String, Ptr{Void}})
  ccall((:wkhtmltoimage_add_object, libwkhtml),
        Void,
        (Ptr{Converter}, Ptr{ObjectSettings}, Cstring),
        conv, os,
        isa(data, String) ? convert(Cstring, pointer(data)) : data)
end
