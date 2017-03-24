__precompile__()

module Wkhtmltox

import Base: getindex, setindex!, push!, run

export getindex, setindex!, push!, run

export PdfSettings, PdfObject, PdfConverter
export pdf_init, pdf_deinit
export ImgSettings, ImgConverter
export img_init, img_deinit


const depfile = joinpath(dirname(@__FILE__),"..","deps","deps.jl")
if isfile(depfile)
    include(depfile)
else
    error("Wkhtmltox not properly installed. Please run Pkg.build(\"Wkhtmltox\")")
end


type GlobalSettings ; end
type ObjectSettings ; end
type Converter; end

include("pdf.jl")
include("image.jl")




end # module
