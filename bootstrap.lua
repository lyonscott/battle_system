local __path=function(str) 
    return string.format("%s?.lua;",str);
end
package.path=
    __path("src/")..
    __path("lib/")..
    package.path

require "lib"