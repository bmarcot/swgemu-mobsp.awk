# swgemu-mobsp.awk: a tool to populate SWGEmu caves, dungeons, POIs.
#
# Copyright (C) 2012 Benoit Marcot - juz4m AT hotmail DOT com
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see
# <http://www.gnu.org/licenses/>.

BEGIN {
    FS = "([ ]+x = )|(, z = )|(, y = )|(, ow = )|(, ox = )|(, cellid = )|( in range)|( object)|(\")"
    if ("" == planet)
        pn = "tatooine"
    else
        pn = planet
    if ("" == respawn)
        rt = 1
    else
        rt = respawn
    if ("" != mobile)
        mob = mobile
}
/^\[Spatial\][ [:digit:]:\t]+ x = / {
    format = "spawnMobile(\"%s\", \"%s\", %u, %4.3f, %4.3f, %4.3f, %4.3f, %u)\n";
    if ("" == mob)
        print "warning: no mobile template" > "/dev/stderr"
    if (0 != $7)
        if (0 != cid)
            printf format, pn, mob, rt, $2, $3, $4, get_heading($5), cid
        else
            print "warning: wrong indoor cellid" > "/dev/stderr"
    else
        printf format, pn, mob, rt, $2, $3, $4, get_heading($5), $7
    c++
}
/^\[Spatial\][[:alnum:]\[\]\-,: ]+\"cellid=/ {
    cid = substr($2, length("cellid=") + 1)
}
/^\[Spatial\][[:alnum:]\[\]\-,: ]+\"planet=/ {
    pn = substr($2, length("planet=") + 1)
}
/^\[Spatial\][[:alnum:]\[\]\-,: ]+\"mobile=/ {
    mob = substr($2, length("mobile=") + 1)
}
/^\[Spatial\][[:alnum:]\[\]\-,: ]+\"respawn=/ {
    rt = substr($2, length("respawn=") + 1)
}
/^\[Spatial\][[:alnum:]\[\]\-,: ]+\"[^((cellid=)|(planet=)|(mobile=)|(respawn=))]/ {
    printf "-- %s\n", $2
}
END {
    print "\ninfo: " c " mobiles spawned" > "/dev/stderr"
}

function acosd(x)
{
    return (atan2((1. - x ^ 2) ^ 0.5, x) * 180.) / atan2(0, -1)
}

function get_heading(ow)
{
    d = 2 * acosd(ow)
    if (d <= 180)
        return 2 * acosd(ow)
    return d - 360
}
