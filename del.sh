for i in {1..4}; do
  for j in {1..5}; do
    sudo rm -f /dev/loop$i$j
  done
done
