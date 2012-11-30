# mobsp.awk -- MobileSpawner for SWGEmu, 2012, Benoit Marcot
# NAME
#         mobsp.awk

# SYNOPSIS
#         $ gawk -f mobsp.awk [OPTIONS] [FILE]

# DESCRIPTION

# Command-line options:
# --assign planet="naboo", "tatooine", "endor", ...
# --assign respawn=xxx
# --assign respawn=xxx



# AUTHOR
#         Written by Benoit Marcot.

# REPORTING BUGS
#       Report bugs and propose changes on http://github

# spmob.awk for SWGEmu, 2012 Benoit
# In your SWGEmu client, start loging of the Spatial chat output with
# the command '\log'. Everything that is printed out to the chat output is
# now logged to a file inside your SWG client path, with its filename following
#     the pattern "chatbox-'some_date'.log". When loging feature has been start, travel to the location you want to populate with mobiles.

# Online loging feature

#     The following commands, when entered into the Spatial chat

# The following text patterns extracted from the log file will be processed as follow:

# output of '/dumpz'
# Will spawn a mobile at the current player location.

#     cellid='an_unsigned_integer'
#     A cellid must be provided when spawning indoor mobiles. Unfortunately it's not possible, to log the current cellid to the chatbox. Be sure to say this command in the chatbox whenever you want to spawn mobiles in different rooms. Nothing to do when spawning outdoor.

#     planet="tatooine", "naboo", "lok", "endor", ...
#     Tells spmob.awk on what planet you are going to spawn mobiles.

#     respawn='an_unsigned_integer'
#     Set the respawn time for the next mobiles to be spawned. By default, the respawn time is '1' (immediate respawn).

#     mob='creature_mobile_template_name'
#     Set the template for the next mobiles to be spawned. The creature template name is the filename of the mobile that can be found in /bin/scripts/mobile/. Use this command everytime you want to spawn a new type of mobile.

# Anything else
# Output as a LUA comment.

# # USAGE:
#   $ gawk -f spmob.awk chatlog_file

#|(, ox =)

BEGIN {
    FS = "([ ]+x = )|(, z = )|(, y = )|(, ow = )|(, ox = )|(, cellid = )|( in range)|( object)|(\")"
    if ("" == planet)
        pn = "tatooine"         # planet name
    else
        pn = planet
    if ("" == respawn)
        rt = 1                  # respawn time
    else
        rt = respawn
    mob = "mob_template"        # mobile template
#    cid = -1                    # indoor cellid
}
/^\[Spatial\][ [:digit:]:\t]+ x = / {
    format = "spawnMobile(\"%s\", \"%s\", %u, %4.3f, %4.3f, %4.3f, %4.3f, %u)\n";
# print "6 " $6
# print "7 " $7
#         print cid
    if (0 != $7)
        if (0 != cid)
            printf format, pn, mob, rt, $2, $3, $4, get_heading($5), cid
        else
            print "warning: wrong indoor cellid" > "/dev/stderr"
    else
        printf format, pn, mob, rt, $2, $3, $4, get_heading($5), $7
    c++
}
# /^\[Spatial\][ [:digit:]:\t]+ .+\"planet=/ {
#     pn = $2
# }
# /^\[Spatial\][ [:digit:]:\t]+ .+\"mob=/ {
#     mob = $2
# }
/^\[Spatial\][[:alnum:]\[\]\-,: ]+\"cellid=/ {
    cid = substr($2, length("cellid=") + 1)
}
# /^\[Spatial\][ [:digit:]:\t]+ .+\"respawn=/ {
#     rt = $2
# }
/^\[Spatial\][[:alnum:]\[\]\-,: ]+\"[^(cellid=)]/ {
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
