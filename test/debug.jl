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

#### conversion to image ####
