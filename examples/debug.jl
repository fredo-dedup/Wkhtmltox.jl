
reload("Wkhtmltox")

module Try
end


module Try
using Wkhtmltox
using Base.Test


using Base.Markdown

md"""
list :
  - **abcs** : dvfqsdf
  - **qsdfs** qsdfsdf
"""


#### conversion to pdf ####

# exfile = joinpath(dirname(@__FILE__),"../examples/index.html")
exfile = joinpath(dirname(@__FILE__),"../examples/example.html")
# outfile = tempname() * ".pdf"
outfile = "c:/temp/img.png"

img_init(1)

is = ImgSettings("in" => exfile,
                 "out" => outfile,
                 "fmt" => "png")

conv = ImgConverter(is)

run(conv)

conv = nothing
img_deinit()

#### conversion to image ####
