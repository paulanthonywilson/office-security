# Ds18b20

Reads temperature from a Ds18b20 sensor using the [1Wire](https://en.wikipedia.org/wiki/1-Wire) interface. Needs some Nerves config jujitsu, see http://www.carstenblock.org/post/project-excelsius/.

This is pretty simple, and assumes a single 1Wire device. I'm extracting to its own Repo because I've decided [to give up on the Umbrella Apps](https://furlough.merecomplexities.com/elixir/2022/09/14/leaving-the-umbrella-behind.html) and actually re-use things between projects without (cough) copying and pasting apps. Hey, don't judge me. It's hobby stuff.

I'm not going to bother putting this on hex, as there seems to be a [reasonable looking Ds18b20](https://hex.pm/packages/ds18b20_1w) there now. 


