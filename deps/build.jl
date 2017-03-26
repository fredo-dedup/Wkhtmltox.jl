using BinDeps
using Compat

@BinDeps.setup

@static if is_apple()
  ostype = "apple"
  elseif is_windows()
    ostype = "windows"
  elseif is_linux()
    ostype = "linux"
  else
    error("No wkhtmltox library available for this OS")
  end

ostype *= Int==Int64 ? "64" : "32"


libwkhtml = library_dependency("libwkhtml",
                               aliases=["wkhtmltox.dll",
                                        "libwkhtmltox.so.0.12.4"])

archivemap = Dict(
 "apple32"   => "_osx-carbon-i386.pkg",
 "windows32" => "_mingw-w64-cross-win32.exe",
 "linux32"   => "_linux-generic-i386.tar.xz",
 "apple64"   => "_osx-cocoa-x86-64.pkg",
 "windows64" => "_mingw-w64-cross-win64.exe",
 "linux64"   => "_linux-generic-amd64.tar.xz",
 )


url = "https://downloads.wkhtmltopdf.org/0.12/0.12.4/" *
      "wkhtmltox-0.12.4" *
      archivemap[ostype]

# if Windows .exe file installer, trick Unpacker into seeing a zip file
downloadname = basename(url) * ( is_windows() ? ".zip" : "" )

libmap = Dict(
 "apple32"   => "",
 "windows32" => "bin/wkhtmltox.dll",
 "linux32"   => "wkhtmltox/lib/libwkhtmltox.so.0.12.4",
 "apple64"   => "",
 "windows64" => "bin/wkhtmltox.dll",
 "linux64"   => "wkhtmltox/lib/libwkhtmltox.so.0.12.4",
 )

libpath = libmap[ostype]
libfile = basename(libpath)


libdir = BinDeps.libdir(libwkhtml)
srcdir = BinDeps.srcdir(libwkhtml)
downloadsdir = BinDeps.downloadsdir(libwkhtml)

type FileCopyRule <: BinDeps.BuildStep
    src::AbstractString
    dest::AbstractString
end
Base.run(fc::FileCopyRule) = isfile(fc.dest) || cp(fc.src, fc.dest)

provides(BuildProcess,
	(@build_steps begin
    CreateDirectory(downloadsdir, true)
		FileDownloader(url, joinpath(downloadsdir, downloadname))
		CreateDirectory(srcdir, true)
    FileUnpacker(joinpath(downloadsdir, downloadname), srcdir, libpath)
		CreateDirectory(libdir, true)
    FileCopyRule(joinpath(srcdir,libpath), joinpath(libdir,libfile))
	end), libwkhtml)

# push!(BinDeps.defaults, BuildProcess)

@BinDeps.install Dict(:libwkhtml => :libwkhtml)
