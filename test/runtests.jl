using Wkhtmltox
using Base.Test

#### conversion to pdf ####

exfile = joinpath(dirname(@__FILE__),"../examples/example.html")
outfile = tempname() * ".pdf"

pdf_init(0)

ps = PdfSettings("out" => outfile,
                 "orientation" => "Landscape")

@test ps["out"] == outfile
@test ps["orientation"] == "Landscape"

ps["size.pageSize"] = "A4"
@test ps["size.pageSize"] == "A4"

os = PdfObject("page" => exfile)
@test os["page"] == exfile

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

#### conversion to image ####

exfile = joinpath(dirname(@__FILE__),"../examples/example.html")
outfile = tempname() * ".png"

img_init(1)

is = ImgSettings("in" => exfile,
                 "out" => outfile,
                 "fmt" => "png")

@test is["out"] == outfile
@test is["fmt"] == "png"

conv = ImgConverter(is)

@test run(conv) == 1

@test isfile(outfile)

conv = nothing
img_deinit()
