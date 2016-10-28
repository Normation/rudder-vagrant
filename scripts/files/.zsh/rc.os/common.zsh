
# update screen caption, use the last argument as hostname
ssh () {
	target=$_
	target=${target//*@/}
	set_title $target
	command ssh $*
}

