if [ x"$@" = x"calc" ]; then
    pkill rofi; rofi -show calc -modi calc -no-show-match -no-sort 
else
  echo "calc"
fi
