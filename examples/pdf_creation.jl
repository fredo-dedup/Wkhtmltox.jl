using Wkhtmltox

pdf_init(0)

ps = PdfSettings("out" => "c:\\temp\\example.pdf",
                 "orientation" => "Landscape")

ps = PdfSettings("out" => "c:\\temp\\example.pdf")

ps = PdfSettings()
ps["out"] = "c:\\temp\\example.pdf"
ps["out"] = "c:/temp/google.pdf"

ps["web.background"]
ps["size.pageSize"]


ps["margin.top"] = "50px"
ps["out"]
ps["orientation"]

os = PdfObject()
os["page"] = "https://www.google.fr"
os["page"] = "c:/temp/example.html"

os = PdfObject("page" => "c:\\temp\\example.html")
os["page"]

conv = PdfConverter(ps, os)
push!(conv, os)

run(conv)

conv = nothing
pdf_deinit()

on_error(conv) do
    println("error $ ")
end

conv = create_converter(gs)

add_object(conv, os, C_NULL);

wkconvert(conv)

# wkhtmltopdf_set_progress_changed_callback(c, progress_changed);
# wkhtmltopdf_set_phase_changed_callback(c, phase_changed);
# wkhtmltopdf_set_error_callback(c, error);
# wkhtmltopdf_set_warning_callback(c, warning);

destroy_converter(conv);

deinit();

end
