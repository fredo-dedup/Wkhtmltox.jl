##############################################################################
#  function for conversion to pdf
##############################################################################

"""
Initializes `wkhtmltopdf` in graphics less mode `pdf_init(0)` or not
`pdf_init(1)`
"""
function pdf_init(usegraphics::Int)
  ccall((:wkhtmltopdf_init, libwkhtml),
        Int, (Int,), usegraphics)
end

"""
Closes `wkhtmltopdf`
"""
function pdf_deinit()
  ccall((:wkhtmltopdf_deinit, libwkhtml),
        Int, ())
end


### Global settings ###

"""
Sets the output parameters by passing pairs `"property" => "values"` (both should be String).

example:
```julia
ps = PdfSettings("out" => "/tmp/example.pdf",
                 "orientation" => "Landscape")

```

Parameters (see https://wkhtmltopdf.org/libwkhtmltox/pagesettings.html#pagePdfGlobal) :

  - *size.pageSize* The paper size of the output document, e.g. "A4".
  - *size.width* The with of the output document, e.g. "4cm".
  - *size.height* The height of the output document, e.g. "12in".
  - *orientation* The orientation of the output document, must be either "Landscape" or "Portrait".
  - *colorMode* Should the output be printed in color or gray scale, must be either "Color" or "Grayscale"
  - *resolution* Most likely has no effect.
  - *dpi* What dpi should we use when printing, e.g. "80".
  - *pageOffset* A number that is added to all page numbers when printing headers, footers and table of content.
  - *copies* How many copies should we print?. e.g. "2".
  - *collate* Should the copies be collated? Must be either "true" or "false".
  - *outline* Should a outline (table of content in the sidebar) be generated and put into the PDF? Must be either "true" or false".
  - *outlineDepth* The maximal depth of the outline, e.g. "4".
  - *dumpOutline* If not set to the empty string a XML representation of the outline is dumped to this file.
  - *out* The path of the output file, if "-" output is sent to stdout, if empty the output is stored in a buffer.
  - *documentTitle* The title of the PDF document.
  - *useCompression* Should we use loss less compression when creating the pdf file? Must be either "true" or "false".
  - *margin.top* Size of the top margin, e.g. "2cm"
  - *margin.bottom* Size of the bottom margin, e.g. "2cm"
  - *margin.left* Size of the left margin, e.g. "2cm"
  - *margin.right* Size of the right margin, e.g. "2cm"
  - *imageDPI* The maximal DPI to use for images in the pdf document.
  - *imageQuality* The jpeg compression factor to use when producing the pdf document, e.g. "92".
  - *load.cookieJar* Path of file used to load and store cookies.

"""
type PdfSettings
  ptr::Ptr{GlobalSettings}
end

# 0 arg case
PdfSettings() = PdfSettings(pdf_create_global_settings())

# >= 1 case
function PdfSettings(p1::Pair{String,String}, args...)
  ptr = pdf_create_global_settings()

  pdf_set_global_setting(ptr, p1.first, p1.second)
  for p in args
    isa(p, Pair{String,String}) || error("argument $p is not Pair{String,String}")
    pdf_set_global_setting(ptr, p.first, p.second)
  end

  PdfSettings(ptr)
end

function setindex!(settings::PdfSettings, value::String, property::String)
  pdf_set_global_setting(settings.ptr, property, value)
end

function getindex(settings::PdfSettings, property::String)
  pdf_get_global_setting(settings.ptr, property)
end

function pdf_create_global_settings()
  ccall((:wkhtmltopdf_create_global_settings, libwkhtml),
        Ptr{GlobalSettings}, ())
end

function pdf_get_global_setting(gs::Ptr{GlobalSettings}, property::String)
  cval = zeros(UInt8, 100)
  ccall((:wkhtmltopdf_get_global_setting, libwkhtml),
        Int,
        (Ptr{GlobalSettings}, Cstring, Cstring, Int),
        gs, convert(Cstring, pointer(property)),
            convert(Cstring, pointer(cval)), sizeof(cval)-1 )
  unsafe_string(pointer(cval))
end

function pdf_set_global_setting(gs::Ptr{GlobalSettings}, property::String, value::String)
  ccall((:wkhtmltopdf_set_global_setting, libwkhtml),
        Int,
        (Ptr{GlobalSettings}, Cstring, Cstring),
        gs,
        convert(Cstring, pointer(property)),
        convert(Cstring, pointer(value)) )
end

### Object settings ###

"""
Sets the object to be converted parameters by passing pairs `"property" => "values"` (both should be String).

example:
```julia
ps = PdfObject("out" => "page" => "c:/temp/example.html")
```

## Parameters (see https://wkhtmltopdf.org/libwkhtmltox/pagesettings.html#pagePdfGlobal) :

- **toc.useDottedLines** Should we use a dotted line when creating a table of content? Must be either "true" or "false".
- **toc.captionText** The caption to use when creating a table of content.
- **toc.forwardLinks** Should we create links from the table of content into the actual content? Must be either "true or "false.
- **toc.backLinks** Should we link back from the content to this table of content.
- **toc.indentation** The indentation used for every table of content level, e.g. "2em".
- **toc.fontScale** How much should we scale down the font for every toc level? E.g. "0.8"
- **page** The URL or path of the web page to convert, if "-" input is read from stdin.
- **header.\*** Header specific settings see Header and footer settings.
- **footer.\*** Footer specific settings see Header and footer settings.
- **useExternalLinks** Should external links in the HTML document be converted into external pdf links? Must be either "true" or "false.
- **useLocalLinks** Should internal links in the HTML document be converted into pdf references? Must be either "true" or "false"
- **replacements** TODO
- **produceForms** Should we turn HTML forms into PDF forms? Must be either "true" or file".
- **load.\*** Page specific settings related to loading content, see Object Specific loading settings.
- **web.\*** See Web page specific settings.
- **includeInOutline** Should the sections from this document be included in the outline and table of content?
- **pagesCount** Should we count the pages of this document, in the counter used for TOC, headers and footers?
- **tocXsl** If not empty this object is a table of content object, "page" is ignored and this xsl style sheet is used to convert the outline XML into a table of content.

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
type PdfObject
  ptr::Ptr{ObjectSettings}
end

# 0 arg case
PdfObject() = PdfObject(pdf_create_object_settings())

# >= 1 case
function PdfObject(p1::Pair{String,String}, args...)
  obj = PdfObject(pdf_create_object_settings())

  pdf_set_object_setting(obj.ptr, p1.first, p1.second)
  for p in args
    isa(p, Pair{String,String}) || error("argument $p is not Pair{String,String}")
    pdf_set_object_setting(obj.ptr, p.first, p.second)
  end

  obj
end

function setindex!(settings::PdfObject, value::String, property::String)
  pdf_set_object_setting(settings.ptr, property, value)
end

function getindex(settings::PdfObject, property::String)
  pdf_get_object_setting(settings.ptr, property)
end


function pdf_create_object_settings()
  ccall((:wkhtmltopdf_create_object_settings, libwkhtml),
  Ptr{ObjectSettings}, ())
end

function pdf_set_object_setting(os::Ptr{ObjectSettings}, property::String, value::String)
  ccall( (:wkhtmltopdf_set_object_setting, libwkhtml),
        Int,
        (Ptr{ObjectSettings}, Cstring, Cstring),
        os,
        convert(Cstring, pointer(property)),
        convert(Cstring, pointer(value)) )
end

function pdf_get_object_setting(os::Ptr{ObjectSettings}, property::String)
  cval = zeros(UInt8, 100)
  ccall((:wkhtmltopdf_get_object_setting, libwkhtml),
        Int,
        (Ptr{ObjectSettings}, Cstring, Cstring, Int),
        os, convert(Cstring, pointer(property)),
            convert(Cstring, pointer(cval)), sizeof(cval)-1 )
  unsafe_string(pointer(cval))
end

### conversion ###

type PdfConverter
  ptr::Ptr{Converter}
end

function PdfConverter(settings::PdfSettings, args...)
  obj = PdfConverter(pdf_create_converter(settings.ptr))

  finalizer(obj, o -> pdf_destroy_converter(o.ptr))

  for p in args
    isa(p, PdfObject) || error("argument $p is not a PdfObject")
    pdf_add_object(obj.ptr, p.ptr, C_NULL)
  end

  obj
end

function push!(conv::PdfConverter, object::PdfObject)
  pdf_add_object(conv.ptr, object.ptr, C_NULL)
end

function run(conv::PdfConverter)
  pdf_wkconvert(conv.ptr)
end

function pdf_create_converter(gs::Ptr{GlobalSettings})
  ccall((:wkhtmltopdf_create_converter, libwkhtml),
        Ptr{Converter},
        (Ptr{GlobalSettings},),
        gs )
end

function pdf_destroy_converter(conv::Ptr{Converter})
  ccall((:wkhtmltopdf_destroy_converter, libwkhtml),
        Void,
        (Ptr{Converter},),
        conv )
end

function pdf_wkconvert(conv::Ptr{Converter})
  ccall((:wkhtmltopdf_convert, libwkhtml),
        Int, (Ptr{Converter},), conv )
end

function pdf_add_object(conv::Ptr{Converter}, os::Ptr{ObjectSettings},
                    data::Union{String, Ptr{Void}})
  ccall((:wkhtmltopdf_add_object, libwkhtml),
        Void,
        (Ptr{Converter}, Ptr{ObjectSettings}, Cstring),
        conv, os,
        isa(data, String) ? convert(Cstring, pointer(data)) : data)
end
