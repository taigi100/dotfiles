if [ x"$@" = x"!" ]; then
    pkill rofi; rofi -"lines" 10 -"padding" 0 -"show" search -"modi" search:~/.config/rofi/scripts/rofi-web-search.py -i -p "Search:"
else
  echo "!"
fi
