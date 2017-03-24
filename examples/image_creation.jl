##################################################################
#  html to pdf conversion example
##################################################################

using Wkhtmltox

# Initialize converter
img_init(1)

exfile = joinpath(dirname(@__FILE__),"../examples/example.html")

# Create and populate the settings object
is = ImgSettings("in" => exfile,
                 "out" => outfile,
                 "fmt" => "png")  # png format output

# create the converter object
conv = ImgConverter(is)

# do conversion
run(conv) == 1

# free objects
conv = nothing
img_deinit()
