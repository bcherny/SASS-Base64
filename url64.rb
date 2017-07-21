require "base64"
require "sass"
require "smusher"

module Sass::Script::Functions
    def url64(image)
        assert_type image, :String

        # compute file/path/extension
        base_path = "../../.."
        root = File.expand_path(base_path, __FILE__)
        path = image.to_s[4,image.to_s.length-5]
        fullpath = File.expand_path(path, root)
        absname = File.expand_path(fullpath)
        ext = File.extname(path)

        # optimize image
        if ext == "gif" || ext == "jpg" || ext == "png"
            Smusher::optimize_image(absname)
        elsif ext == "svg"
            `python scour/scour.py -i ` + absname + ` -o ` + absname
        end

        # base64 encode the file
        file = File.open(fullpath, "rb")
        text = file.read
        file.close
        text_b64 = Base64.encode64(text).gsub(/\r/,"").gsub(/\n/,"")
        contents = "url(data:image/" + ext[1,ext.length-1] + ";base64," + text_b64 + ")"

        Sass::Script::String.new(contents)

    end
    declare :url64, :args => [:string]
end
