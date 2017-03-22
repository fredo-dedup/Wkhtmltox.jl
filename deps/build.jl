using BinDeps
using Compat

@BinDeps.setup

libwkhtml = library_dependency("libwkhtml", aliases=["wkhtmltox.dll"])

wktmlhname = "wkhtmltox"

urlbase = "https://downloads.wkhtmltopdf.org/0.12/0.12.4/"
urlfile = "wkhtmltox-0.12.4"

osmap = Dict(
(32, :apple)   => ("_osx-carbon-i386.pkg",        ""),
(32, :windows) => ("_mingw-w64-cross-win32.exe",  "bin/wkhtmltox.dll"),
(32, :linux)   => ("_linux-generic-i386.tar.xz",  "lib/libwkhtmltox.so.0.12.4"),
(64, :apple)   => ("_osx-cocoa-x86-64.pkg",       ""),
(64, :windows) => ("_mingw-w64-cross-win64.exe",  "bin/wkhtmltox.dll"),
(64, :linux)   => ("_linux-generic-amd64.tar.xz", "lib/libwkhtmltox.so.0.12.4"),
 )

urlfile, libfile = osmap[(Int==Int64 ? 64 : 32,
                          is_apple() ? :apple :   )]

if Int==Int64
  @static if is_apple()
      urlfile *= "_osx-cocoa-x86-64.pkg"
    elseif is_windows()
      urlfile *= "_mingw-w64-cross-win64.exe"
    elseif is_linux()
      urlfile *= "_linux-generic-amd64.tar.xz"
    end
else
  @static if is_apple()
      urlfile *= "_osx-carbon-i386.pkg"
    elseif is_windows()
      urlfile *= "_mingw-w64-cross-win32.exe"
    elseif is_linux()
      urlfile *= "_linux-generic-i386.tar.xz"
    end
end


libdir = BinDeps.libdir(libwkhtml)
srcdir = BinDeps.srcdir(libwkhtml)
downloadsdir = BinDeps.downloadsdir(libwkhtml)

extractdir(w) = joinpath(srcdir,"w$w")
destw(w) = joinpath(libdir,"wkhtmltox.dll")

type FileCopyRule <: BinDeps.BuildStep
    src::AbstractString
    dest::AbstractString
end
Base.run(fc::FileCopyRule) = isfile(fc.dest) || cp(fc.src, fc.dest)

provides(BuildProcess,
	(@build_steps begin
		FileDownloader(joinpath(urlbase, urlfile), joinpath(downloadsdir, urlfile))
		CreateDirectory(srcdir, true)
		FileUnpacker(joinpath(downloadsdir, urlfile), srcdir)
		CreateDirectory(libdir, true)
    FileCopyRule(joinpath(extractdir(64),"bin/wkhtmltox.dll"), libdir)
	end), libwkhtml, os = :Windows)

if is_windows()
    push!(BinDeps.defaults, BuildProcess)
end

@BinDeps.install Dict(:libwkhtml => :libwkhtml)
