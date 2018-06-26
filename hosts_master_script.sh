for dest in $(<destfile); do
  scp -i /Users/a00835114/.ssh hosts ${dest}:/etc
done