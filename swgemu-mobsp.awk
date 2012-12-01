#
# NAME
#
#         swgemu-mobsp.awk -- MobileSpawner for SWGEmu
#
# SYNOPSIS
#
#         $ gawk -f swgemu-mobsp.awk [OPTIONS] [FILE]
#
# DESCRIPTION
#
# Command-line options are:
#
#       --assign planet="naboo", "tatooine", 'lok', "endor", ...
# Set the planet where mobile will spawned to. Overridden by the chat command.
#
#       --assign respawn=unisgned_integer
# Set the default mobiles' respawn time. Overriden by the client chat command.
#
#       --assign mobile=creature_template_mobile_path
# Set the default mobiles'  creature template.  Overriden  by the client  chat
# command.
#
# Client chat commands are:
#
#       cellid=unsigned_integer
# A cellid must be provided when spawning an indoor mobile. Unfortunately it's
# not  possible to log  the  world  cellid to the chatbox. Be sure to say this
# command in the chatbox whenever you  want to spawn  a mobile in  a different
# rooms. Setting up a cellid is not  needed  when  spawning an outdoor  mobile
# (cellid is 0).
#
#       planet="naboo", "tatooine", 'lok', "endor", ...
# Set the planet  where mobile  will  spawned to.  Default  spawning planet is
# Tatooine.
#
#       respawn='an_unsigned_integer'
# Set the mobiles'  respawn time. Default  respawn timer is 1 second (immediate
# respawn time).
#
#       mobile='creature_mobile_template_name'
# Set the template for the next mobiles  to be spawned. The  creature  template
# name    is    the    filename   of   the  mobile  that   can be   found under
# /bin/scripts/mobile/. Use  this  command  everytime  you want  to spawn a new
# type of mobile.
#
#       random text
# Output as a LUA code comment.
#
# AUTHOR
#
#         Written by Benoit Marcot, 2012.
#
# USAGE
#
# Launch your SWGEmu client. Once connected to the server, start the logging
# with the '/log' command. Say in the chat box "planet=my_current_planet" to
# set the planet where mobiles will be spawned. Then say
# "respawn=an_unsigned_integer" to set the default respawn time for the mobiles,
# time is in seconds. Finally, set the mobile template by saying
# "mobile=a_mobile_template", each time you want to change mobile, don't forget
# to say this phrase with the new mobile template. Everytime you want to spawn
# a mobile at your location, enter the command '/dumpz'. This command command
# should be binded to a macro. Once all mobiles location has been located with
# the '/dumpz' command, stop the logging by entering again the command '/log' in
# the chatbox. Do not forget to change the cellid when you spawn mobiles in an
# indoor environnement by saying in the chatbox "cellid=my_current_cellid". Get
# your current cellid with CTRL+SHIFT+G (display a UI box with your coords).
# Generate the LUA code from the log file by invoking AWK. Copy/paste the
#  generated code to your screenplay.
#
# REPORTING BUGS
#
#       Please report bugs on https://github.com/bmarcot/swgemu-mobsp.awk,
# change propositions are welcomed.
#

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
    return 2 * acosd(ow)
}
