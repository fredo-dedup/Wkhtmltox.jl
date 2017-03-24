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

@test run(conv) == 1

@test isfile(outfile)

conv = nothing
pdf_deinit()

# wkhtmltopdf_set_progress_changed_callback(c, progress_changed);
# wkhtmltopdf_set_phase_changed_callback(c, phase_changed);
# wkhtmltopdf_set_error_callback(c, error);
# wkhtmltopdf_set_warning_callback(c, warning);

reload("VegaLite")

module Try
end

module Try

using VegaLite

ts = sort(rand(10))
ys = Float64[ rand()*0.1 + cos(x) for x in ts]

v = data_values(time=ts, res=ys) +    # add the data vectors & assign to symbols 'time' and 'res'
      mark_line() +                   # mark type = line
      encoding_x_quant(:time) +       # bind x dimension to :time, quantitative scale
      encoding_y_quant(:res)


tmppath = "c:/temp/vegalite.html"
open(io -> VegaLite.writehtml(io, v), tmppath, "w")

png_fn = "c:/temp/vegalite.png"

VegaLite.Wkhtmltox.img_init(1)
is = VegaLite.Wkhtmltox.ImgSettings("in" => tmppath,
                                    "out" => png_fn)  # png format output

is["fmt"] = "svg"

conv = VegaLite.Wkhtmltox.ImgConverter(is)
VegaLite.Wkhtmltox.run(conv)

conv = nothing
VegaLite.Wkhtmltox.img_deinit()


#########

VegaLite.Wkhtmltox.pdf_init(0)

ps = VegaLite.Wkhtmltox.PdfSettings("out" => "c:/temp/example.pdf", # output file
                 "orientation" => "Landscape")   # orientation

ps["out"] = "c:/temp/example.pdf" # can be set also like this
ps["size.pageSize"]  # settings can be read like this

VegaLite.Wkhtmltox.os = PdfObject()
VegaLite.Wkhtmltox.os["page"] = joinpath(dirname(@__FILE__),"../examples/example.html")

conv = VegaLite.Wkhtmltox.PdfConverter(ps, os) # pass the pdf settings and source settings
VegaLite.Wkhtmltox.run(conv)

conv = nothing
VegaLite.Wkhtmltox.pdf_deinit()



end
#### conversion to image ####
