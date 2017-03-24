##################################################################
#  html to pdf conversion example
##################################################################

using Wkhtmltox

# Initialize conversion setup
pdf_init(0)

# Sets output parameters
ps = PdfSettings("out" => "c:/temp/example.pdf", # output file
                 "orientation" => "Landscape")   # orientation

ps["out"] = "c:/temp/example.pdf" # can be set also like this

ps["size.pageSize"]  # settings can be read like this

# Sets source parameters
os = PdfObject()

# 'page' is the source file
os["page"] = joinpath(dirname(@__FILE__),"../examples/example.html")

# Create the converter
conv = PdfConverter(ps, os) # pass the pdf settings and source settings

# push!(conv, os2) # additional sources can be added with 'push!()'

# Do conversion
run(conv)

# free objects
conv = nothing
pdf_deinit()
