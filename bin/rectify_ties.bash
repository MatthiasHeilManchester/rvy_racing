#! /bin/bash


# Rectify ties in overall league table post-creation; bit of a hack, but...
# Logic: First table in html file contains ranks and points. Do it. Leave
# the rest alone.

# Specify league table file 
if [ $# -ne 1 ]; then
    echo "Please specify name of league table file "
    exit 1
fi

league_table_file=$1

# https://stackoverflow.com/questions/28878995/check-if-a-field-is-an-integer-in-awk
awk 'function is_integer(x)  { return x+0 == x && int(x) == x } 
BEGIN{prev_rank=0; prev_points=1000000; read_first_start_table=0; read_first_end_table=0;}{
if ($1=="<table"){read_first_start_table=1}
if ($1=="</table>"){read_first_end_table=1}
#print "--------------------- "read_first_start_table " " read_first_end_table
if ((read_first_start_table==0)||(read_first_end_table==1))
{
 print $0
}
else
{
 if (is_integer($3))
{
 col_of_points=NF-2;
 col_of_rank=3;
 points=$col_of_points;
 rank=$col_of_rank;
 display_rank=rank;
 dont_update=0;
 if (points==prev_points)
   {display_rank="="prev_rank; dont_update=1;};
 #print " " display_rank " " points " " prev_points
 for (i=1;i<=NF;i++)
  {
   if (i==col_of_rank)
     {printf display_rank" "}
   else
     {printf $i" "}
}
 prev_points=points;
 if (dont_update==0){prev_rank=rank;};
}
else
{
print $0
}
print "";
}
}' $league_table_file
