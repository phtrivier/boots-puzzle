str = <<EOF
This package was debianized by Pierre-Henri Trivier <phtrivier-at-yahoo-dot-fr> on
#{Time.new.strftime("%a, %d %b %Y %H:%M:%S +0100")}.

It was downloaded from http://ph.on.things.free.fr/projects/boots-puzzle

Upstream Authors: Pierre-Henri Trivier <phtrivier-at-yahoo-dot-fr>

Copyright 2008-2009 Pierre-Henri Trivier

License:

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public
    License version 2 as published by the Free Software Foundation;

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA

    On Debian Systems, the full text of the license can be found on
    /usr/share/common-licenses/GPL-2
EOF
require "fileutils"
FileUtils.rm_rf("copyright")
f = File.open("copyright", "w")
f << str
f.close

