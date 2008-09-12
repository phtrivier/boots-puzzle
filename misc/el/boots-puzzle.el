;; Skeleton for puzzle files ...
(define-skeleton puzzle-skeleton
  "Insert a header for puzzle class file"
  "Desription of the file : "
  "# Boots Puzzle - " (buffer-name) "\n"
"#\n"
"# " str | " * describe the file * " "\n"
"#
# Copyright (C) 2008 Pierre-Henri Trivier
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA\n")

;; Skeleton for bugs
(define-skeleton puzzle-bug-skeleton
 "Prepare an org file to file a bug for boots puzzle"
 ""
 "* Number\n" (buffer-name)
 "\n* Status\nOpen"
 "\n* How ?\n" _
 "\n* Seen ?\n"
 "\n* Expected ?\n"
 "\n* Comments ?\n"
)

(global-set-key [(control ?c) (?p)] 'puzzle-skeleton)
(global-set-key [(control ?c) (?b)] 'puzzle-bug-skeleton)

(provide 'boots-puzzle)