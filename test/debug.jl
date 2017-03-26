using Wkhtmltox
using Base.Test

#### conversion to pdf ####

exfile = joinpath(dirname(@__FILE__),"../examples/index.html")
# exfile = joinpath(dirname(@__FILE__),"../examples/example.html")
outfile = tempname() * ".pdf"

pdf_init(0)

ps = PdfSettings("out" => outfile,
                 "orientation" => "Landscape")

@test ps["out"] == outfile
@test ps["orientation"] == "Landscape"

ps["size.pageSize"] = "A4"
@test ps["size.pageSize"] == "A4"

os = PdfObject("page" => exfile,
               "web.javascript" => "true",
               "load.proxy" => "http://proxy-mkt.int.world.socgen:8080")
@test os["page"] == exfile

os["web.defaultEncoding"]

os2 = PdfObject()
@test os2["page"] == ""
os2["page"] = exfile
@test os2["page"] == exfile


conv = PdfConverter(ps)
push!(conv, os)

run(conv) == 1

isfile(outfile)

conv = nothing
pdf_deinit()

# wkhtmltopdf_set_progress_changed_callback(c, progress_changed);
# wkhtmltopdf_set_phase_changed_callback(c, phase_changed);
# wkhtmltopdf_set_error_callback(c, error);
# wkhtmltopdf_set_warning_callback(c, warning);

reload("Wkhtmltox")
reload("VegaLite")

module Try
end

module Try

using VegaLite
using Wkhtmltox

ts = sort(rand(10))
ys = Float64[ rand()*0.1 + cos(x) for x in ts]

v = data_values(time=ts, res=ys) +    # add the data vectors & assign to symbols 'time' and 'res'
      mark_line() +                   # mark type = line
      encoding_x_quant(:time) +       # bind x dimension to :time, quantitative scale
      encoding_y_quant(:res)


tmppath = "/tmp/vegalite.html"
open(io -> VegaLite.writehtml(io, v), tmppath, "w")

png_fn = "/tmp/vegalite.png"

img_init(0)
is = ImgSettings()
is = ImgSettings("in" => tmppath,
                 "out" => png_fn,
                 "fmt" => "png")  # png format output

is["in"]
is["in"] = "http://example.com"
is["out"]

is["fmt"]
is["fmt"]
is["screenHeight"] = "200"
is["screenHeight"]
is["smartWidth"] = "true"
is["smartWidth"]

pars = ["crop.left", "crop.top", "crop.width", "crop.height", "load.cookieJar",
        "transparent", "in", "out", "fmt", "screenWidth", "smartWidth",
        "quality", "web.background", "web.loadImages", "web.enableJavascript",
        "web.enableIntelligentShrinking", "web.minimumFontSize",
        "web.printMediaType", "web.defaultEncoding", "web.userStyleSheet",
        "web.enablePlugins", "load.username", "load.password", "load.jsdelay",
        "load.zoomFactor", "load.customHeaders", "load.repertCustomHeaders",
        "load.cookies", "load.post", "load.blockLocalFileAccess",
        "load.stopSlowScript", "load.debugJavascript", "load.loadErrorHandling",
        "load.proxy", "load.runScript", "header.fontSize", "header.fontName",
        "header.left", "header.center", "header.right", "header.line",
        "header.spacing", "header.htmlUrl"]

is["useGraphics"]


is["left"]

for p in pars
  println("$p => '$(is[p])'")
end

is["load.jsdelay"] = "1000"
is["load.jsdelay"]


is["web.defaultEncoding"]
is["web.defaultEncoding"] = "utf-8"

conv = ImgConverter(is)
run(conv)

out = Array(UInt8, 200_000)

function img_get_output(conv::Ptr{Wkhtmltox.Converter}, output::Vector{UInt8})
  ccall((:wkhtmltoimage_get_output, Wkhtmltox.libwkhtml),
        Int,
        (Ptr{Wkhtmltox.Converter}, Cstring),
        conv, convert(Cstring, pointer(output)))
end

img_get_output(conv.ptr, out)

tmppath = "/tmp/vegalite2.png"
open(io -> write(io, out[1:151930]), tmppath, "w")

out[1:10]
out[0]

[ convert(Int, x) for x in out[1:10]]

len = wkhtmltoimage_get_output(c, &data);
	printf("%ld len\n", len);


conv = nothing
img_deinit()


####################################

ccall((:wkhtmltoimage_extended_qt, Wkhtmltox.libwkhtml),
      Int, ())

img_init(1)
is = ImgSettings("in" => tmppath,
                 "out" => png_fn,
                 "fmt" => "png")  # png format output

conv = ImgConverter(is)
run(conv)
conv = nothing
img_deinit()





#########


reload("Wkhtmltox")
reload("VegaLite")

module Try
end

module Try

using VegaLite
using Wkhtmltox

pdf_init(0)
ps = PdfSettings("out" => "/tmp/example.pdf")   # orientation

ps["size.pageSize"]  # settings can be read like this

os = PdfObject()
# os["page"] = "https://github.com/fredo-dedup/Wkhtmltox.jl"
os["page"] = "/tmp/vegalite.html"
# os["page"] = "/tmp/example.html"
# os["page"] = "http://example.com"
# os["page"] = joinpath(dirname(@__FILE__),"../examples/example.html")

conv = PdfConverter(ps, os) # pass the pdf settings and source settings
run(conv)

conv = nothing
pdf_deinit()



end
#### conversion to image ####
